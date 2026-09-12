-- =====================================================================
--  Voltara — запуск по loadstring (всё из druk1489/voltara)
--
--  loadstring(game:HttpGet("https://raw.githubusercontent.com/druk1489/voltara/main/load.lua"))()
--
--  Что лечит:
--   1) rbimgui-либа ("imgui2") — синглтон: жёстко ищет ScreenGui по имени
--      "imgui2" и при загрузке Destroy-ит прошлый. Из-за этого Main-окно
--      исчезало, когда Second грузил ту же либу. Каждой загрузке либы
--      подсовываем УНИКАЛЬНОЕ имя гуи (меняем только строковый литерал
--      "imgui2", локальная переменная не трогается) -> окна сосуществуют.
--   2) Ссылки на чужие репо (Vyrusspcs/weshkyv2, federal876887/...) -> твой.
-- =====================================================================

local DRUK     = "https://raw.githubusercontent.com/druk1489/voltara/main/"
local UPSTREAM = {
    "https://raw.githubusercontent.com/Vyrusspcs/weshkyv2/refs/heads/main/",
    "https://raw.githubusercontent.com/federal876887/The-Babft-Archive/refs/heads/main/",
}
local LIB_PATH = "server/libtest.lua"

local oldGet = game.HttpGet
local function rawget(url)
    local ok, body = pcall(oldGet, game, url)
    if ok then return body end
    return nil
end

local function upstreamRel(url)
    if type(url) ~= "string" then return nil end
    for _, base in ipairs(UPSTREAM) do
        if url:sub(1, #base) == base then return url:sub(#base + 1) end
    end
    return nil
end

-- оригинальный исходник либы берём один раз, потом переименуем под каждую загрузку
local _libTemplate = nil
local function libTemplate()
    if _libTemplate then return _libTemplate end
    _libTemplate = rawget(DRUK .. LIB_PATH)
    if not _libTemplate or #_libTemplate < 100 then
        _libTemplate = rawget(UPSTREAM[1] .. LIB_PATH)
    end
    return _libTemplate
end
local _libLoadCount = 0

local function get(url)
    local rel = upstreamRel(url)
    if rel then
        if rel == LIB_PATH then
            local tpl = libTemplate()
            if not tpl or #tpl < 100 then return nil end
            _libLoadCount = _libLoadCount + 1
            local uniq = '"imgui2_V' .. _libLoadCount .. '"'
            -- меняем только строковый литерал "imgui2" (Name + FindFirstChild + Destroy)
            return (tpl:gsub('"imgui2"', uniq))
        end
        return rawget(DRUK .. rel) or rawget(url)
    end
    return rawget(url)
end

pcall(function()
    game.HttpGet = function(self, u, ...) return get(u) end
end)

-- патчим и request-точки (на случай если модули зовут их, а не HttpGet)
local rawHttp = (syn and syn.request) or request or http_request or (fluxus and fluxus.request) or (http and http.request)
if rawHttp then
    local function patched(req)
        if type(req) == "table" and req.Url then
            local copy = {}
            for k, v in pairs(req) do copy[k] = v end
            copy.Url = upstreamRel(req.Url) and (DRUK .. upstreamRel(req.Url)) or req.Url
            local ok, res = pcall(rawHttp, copy)
            if ok then return res end
        end
        return rawHttp(req)
    end
    pcall(function() _G.request = patched end)
    pcall(function() _G.http_request = patched end)
    pcall(function() if syn then syn.request = patched end end)
    pcall(function() if fluxus then fluxus.request = patched end end)
    pcall(function() if http then http.request = patched end end)
end

local function loadModule(name, relPath)
    local body = rawget(DRUK .. relPath)
    if not body or #body < 50 then
        warn("[Voltara] FAILED: " .. relPath); return false
    end
    local fn, err = loadstring(body, "=" .. name)
    if not fn then warn("[Voltara] compile error " .. name .. ":\n" .. tostring(err)); return false end
    local ok, rerr = pcall(fn)
    if not ok then warn("[Voltara] runtime error " .. name .. ":\n" .. tostring(rerr)); return false end
    print("[Voltara] loaded " .. name)
    return true
end

-- 2-й модуль открывается кнопкой в Main-окне (load один раз, повторно — показ окна)
_G.VoltaraOpenSecond = function()
    if _G.__VOLTARA_SECOND_LOADED then
        print("[Voltara] 2nd module already loaded")
        return
    end
    _G.__VOLTARA_SECOND_LOADED = true
    loadModule("VoltaraSecond", "source/SecondModule.lua")
end

loadModule("VoltaraMain", "source/MainModule.lua")
print("[Voltara] done. Открой 2-й модуль кнопкой в Main > Modules.")
