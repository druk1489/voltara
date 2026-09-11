-- =====================================================================
--  Voltara LOCAL Loader (test harness)
--  Грузит Вольтару с твоего компьютера через local_test/voltara_host.py,
--  а не с GitHub. Правь файлы в репо и перезапускай скрипт в игре.
--
--  Как работает:
--    1) Патчит game:HttpGet / request / syn.request / http_request.
--    2) URL вида https://raw.githubusercontent.com/Vyrusspcs/weshkyv2/refs/heads/main/<path>
--       если <path> есть в LOCAL_MAP -> переписывается на http://127.0.0.1:8000/<path>.
--    3) Чего в LOCAL_MAP нет -> уходит на оригинальный GitHub (репо живое).
--    4) Грузит source/MainModule.lua и source/SecondModule.lua.
--
--  Порядок: сначала `python local_test/voltara_host.py`, потом этот скрипт.
-- =====================================================================

local HOST      = "http://127.0.0.1:8000"
local GH_BASE   = "https://raw.githubusercontent.com/Vyrusspcs/weshkyv2/refs/heads/main/"
local USE_LOCAL = true   -- false = обычный режим (всё с GitHub)

-- remote path в репо -> тот же путь, но раздаётся локальным хостом
local LOCAL_MAP = {
    ["source/MainModule.lua"]        = "/source/MainModule.lua",
    ["source/SecondModule.lua"]      = "/source/SecondModule.lua",
    ["source/debug_bindings.lua"]    = "/source/debug_bindings.lua",
    ["server/libtest.lua"]           = "/server/libtest.lua",
    ["server/libtest2.lua"]          = "/server/libtest2.lua",
    ["server/library.lua"]           = "/server/library.lua",
    ["server/library2.lua"]          = "/server/library2.lua",
    ["server/listing.lua"]           = "/server/listing.lua",
    ["server/blocklist.lua"]         = "/server/blocklist.lua",
    ["server/discord_message.lua"]   = "/server/discord_message.lua",
    ["special/extras/blockcolors.lua"] = "/special/extras/blockcolors.lua",
    ["special/antiafk.lua"]          = "/special/antiafk.lua",
    ["special/eggcanon.lua"]         = "/special/eggcanon.lua",
    ["others/LZ4.lua"]               = "/others/LZ4.lua",
    ["client/external/discord.lua"]  = "/client/external/discord.lua",
}

-- ===================== HTTP =====================
local rawHttpGet = game.HttpGet
local rawHttp = (syn and syn.request) or request or http_request
    or (fluxus and fluxus.request) or (http and http.request)

local function escapePattern(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end
local GH_PAT = "^" .. escapePattern(GH_BASE) .. "(.+)$"

local function resolve(url)
    if type(url) ~= "string" or not USE_LOCAL then return url end
    local rel = url:match(GH_PAT)
    if rel and LOCAL_MAP[rel] then
        local target = HOST .. LOCAL_MAP[rel]
        print("[VoltaraLoader] local <- " .. rel)
        return target
    end
    return url
end

local function httpGet(url)
    if rawHttp then
        local ok, res = pcall(rawHttp, { Url = url, Method = "GET" })
        if ok then
            if type(res) == "table" and res.Body then return res.Body end
            if type(res) == "string" then return res end
        end
    end
    local ok, body = pcall(rawHttpGet, game, url)
    if ok then return body end
    return nil
end

local function fetch(url) return httpGet(resolve(url)) end

-- патчим точки входа, чтобы loadstring(game:HttpGet(...)) внутри модулей
-- тоже шёл через resolve и доставал localhost (game:HttpGet часто режет localhost)
pcall(function()
    game.HttpGet = function(self, url, ...) return fetch(url) end
end)

if rawHttp then
    local function patched(req)
        if type(req) == "table" and req.Url then
            local copy = {}
            for k, v in pairs(req) do copy[k] = v end
            copy.Url = resolve(req.Url)
            return rawHttp(copy)
        end
        return rawHttp(req)
    end
    pcall(function() _G.request = patched end)
    pcall(function() _G.http_request = patched end)
    pcall(function() if syn then syn.request = patched end end)
    pcall(function() if fluxus then fluxus.request = patched end end)
    pcall(function() if http then http.request = patched end end)
end

-- ===================== LOAD =====================
local function loadEntry(name, remotePath)
    local body = fetch(GH_BASE .. remotePath)
    if not body or #body < 50 then
        warn("[VoltaraLoader] FAILED load: " .. remotePath .. "  (voltara_host.py запущен?)")
        return false
    end
    local fn, err = loadstring(body, "=" .. name)
    if not fn then
        warn("[VoltaraLoader] COMPILE error in " .. name .. ":\n" .. tostring(err))
        return false
    end
    local ok, rerr = pcall(fn)
    if not ok then
        warn("[VoltaraLoader] RUNTIME error in " .. name .. ":\n" .. tostring(rerr))
        return false
    end
    print("[VoltaraLoader] loaded OK: " .. name)
    return true
end

if USE_LOCAL then
    local probe = httpGet(HOST .. "/health")
    if not probe then
        warn("[VoltaraLoader] НЕ вижу хост на " .. HOST)
        warn("[VoltaraLoader] запусти:  python local_test/voltara_host.py")
        return
    end
    print("[VoltaraLoader] host OK -> " .. HOST)
end

loadEntry("VoltaraMain", "source/MainModule.lua")
task.wait(0.3)
loadEntry("VoltaraSecond", "source/SecondModule.lua")

print("[VoltaraLoader] done.")
