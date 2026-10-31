--[[ ============================================================
     NEVERBLOX HUB — универсальный лоадер
     Определяет игру по PlaceId/GameId и грузит нужный скрипт.
     Чтобы добавить игру: впиши строку в таблицу GAMES ниже и
     закоммить этот файл на GitHub. У всех юзеров обновится само.
     ============================================================ ]]

local RAW = "https://raw.githubusercontent.com/SyncValorant123/52kounterblox/refs/heads/main/"

-- Ключ = PlaceId ИЛИ GameId игры. Значение = имя файла в репо.
-- PlaceId/GameId текущей игры лоадер покажет в уведомлении, если игра не в списке.
local GAMES = {
    -- Counter Blox: Remastered (проверь PlaceId — запусти хаб в игре, он покажет реальный)
    [301549746] = "counterblox_obf%20(10).lua",

    -- Rivals (впиши PlaceId и залей файл rivals в репо):
    -- [0000000000] = "rivals_obf.lua",
}

local HttpService = game:GetService("HttpService")

local function notify(txt)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "NEVERBLOX", Text = tostring(txt), Duration = 6,
        })
    end)
    warn("[NEVERBLOX] " .. tostring(txt))
end

local pid, gid = game.PlaceId, game.GameId
local file = GAMES[pid] or GAMES[gid]

if not file then
    notify("Эта игра пока не поддерживается.\nPlaceId: " .. pid .. "  |  GameId: " .. gid)
    return
end

notify("Загрузка...")

local url = RAW .. file
local ok, src = pcall(function() return game:HttpGet(url) end)
if not ok or type(src) ~= "string" or #src < 32 then
    notify("Не удалось скачать скрипт. Проверь соединение / имя файла.")
    return
end

local fn, err = loadstring(src)
if not fn then
    notify("Ошибка загрузки: " .. tostring(err))
    return
end

fn()
