-- =====================================================================
--  Voltara — запуск по loadstring (всё из druk1489/voltara)
--
--  loadstring(game:HttpGet("https://raw.githubusercontent.com/druk1489/voltara/main/load.lua"))()
--
--  Две важные вещи:
--   1) Библиотека (server/libtest.lua = rbimgui "imgui2") грузится ОДИН РАЗ.
--      При каждой загрузке она Destroy-ит существующий ScreenGui "imgui2",
--      поэтому если её грузить второй раз (как делали MainModule и SecondModule
--      независимо), второе окно стирало первое. Теперь модули получают ОДИН
--      общий экземпляр библиотеки -> оба окна видны.
--   2) Ссылки на старые репо автора (Vyrusspcs/weshkyv2 и
--      federal876887/The-Babft-Archive) переписываются на druk1489/voltara,
--      чтобы не зависеть от чужих репозиториев.
-- =====================================================================

local DRUK     = "https://raw.githubusercontent.com/druk1489/voltara/main/"
local UPSTREAM = {
    "https://raw.githubusercontent.com/Vyrusspcs/weshkyv2/refs/heads/main/",
    "https://raw.githubusercontent.com/federal876887/The-Babft-Archive/refs/heads/main/",
}
local LIB_PATH = "server/libtest.lua"          -- singleton-библиотека
local LIB_STUB = "return _G.__VOLTARA_LIB"      -- что возвращаем при повторном запросе либы

local oldGet = game.HttpGet
local function rawget(url)
    local ok, body = pcall(oldGet, game, url)
    if ok then return body end
    return nil
end

-- какой upstream-префикс (если есть) у url; вернуть относительный путь
local function upstreamRel(url)
    if type(url) ~= "string" then return nil end
    for _, base in ipairs(UPSTREAM) do
        if url:sub(1, #base) == base then
            return url:sub(#base + 1)
        end
    end
    return nil
end

local function get(url)
    local rel = upstreamRel(url)
    if rel then
        if rel == LIB_PATH then
            return LIB_STUB                 -- не пере-выполнять библиотеку
        end
        return rawget(DRUK .. rel) or rawget(url)   -- свой репо, фолбэк на оригинал
    end
    return rawget(url)                        -- сторонние либы (WLib/Fluent/...) как есть
end

-- патчим game:HttpGet, чтобы loadstring(game:HttpGet(...)) внутри модулей шёл через get()
pcall(function()
    game.HttpGet = function(self, u, ...) return get(u) end
end)

-- ===== загрузить библиотеку ОДИН РАЗ =====
local libSrc = rawget(DRUK .. LIB_PATH)
if not libSrc or #libSrc < 100 then
    libSrc = rawget(UPSTREAM[1] .. LIB_PATH)    -- фолбэк, если в твоём репо чего-то нет
end
if not libSrc or #libSrc < 100 then
    warn("[Voltara] library not found, abort")
    return
end
local okLib, libOrErr = pcall(loadstring(libSrc))
if not okLib then
    warn("[Voltara] library load error: " .. tostring(libOrErr))
    return
end
_G.__VOLTARA_LIB = libOrErr
print("[Voltara] library ready (shared)")

-- ===== загрузить модули =====
local function loadEntry(name, relPath)
    local body = rawget(DRUK .. relPath)
    if not body or #body < 50 then
        warn("[Voltara] FAILED: " .. relPath)
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
print("[Voltara] done.")
