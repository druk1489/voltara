-- =====================================================================
--  Voltara — запуск по loadstring (всё из druk1489/voltara)
--  Перехватывает ссылки на старый репозиторий автора и переключает их
--  на твой, чтобы не зависеть от наличия/смены чужого репо.
--
--  loadstring(game:HttpGet("https://raw.githubusercontent.com/druk1489/voltara/main/load.lua"))()
-- =====================================================================

local SRC = "https://raw.githubusercontent.com/Vyrusspcs/weshkyv2/refs/heads/main/"
local DST = "https://raw.githubusercontent.com/druk1489/voltara/main/"

local function rewrite(url)
    if type(url) == "string" and url:sub(1, #SRC) == SRC then
        return DST .. url:sub(#SRC + 1)
    end
    return url
end

-- переписываем game:HttpGet, чтобы внутренние loadstring(game:HttpGet(...)) модулей
-- (library, listing, blockcolors, LZ4, discord, antiafk, eggcanon) шли в твой репо
local oldGet = game.HttpGet
local function get(url)
    return oldGet(game, rewrite(url))
end
pcall(function()
    game.HttpGet = function(self, url, ...) return get(url) end
end)

local function loadEntry(name, path)
    local body = get(DST .. path)
    if not body or #body < 50 then
        warn("[Voltara] FAILED: " .. path)
        return false
    end
    local fn, err = loadstring(body, "=" .. name)
    if not fn then
        warn("[Voltara] compile error " .. name .. ":\n" .. tostring(err))
        return false
    end
    local ok, rerr = pcall(fn)
    if not ok then
        warn("[Voltara] runtime error " .. name .. ":\n" .. tostring(rerr))
        return false
    end
    print("[Voltara] loaded " .. name)
    return true
end

loadEntry("VoltaraMain", "source/MainModule.lua")
task.wait(0.3)
loadEntry("VoltaraSecond", "source/SecondModule.lua")
