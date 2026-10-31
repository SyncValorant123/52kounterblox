--[[ ============================================================
     NEVERBLOX — KeyAuth loader
     Доставка скрипта через keyauth.win (работает в РФ без VPN).
     Флоу: init -> проверка ключа -> скачивание файла -> запуск.
     ============================================================ ]]

-- === ЗАПОЛНИ ЭТИ 4 ЗНАЧЕНИЯ =================================
local Name    = "Pika06931's Application"  -- Application Name (как в панели)
local OwnerId = "0Kr3yMyEca"               -- Account Owner ID
local Version = "1.0"                       -- Application Version
local FileId  = "XXQ9lNewWT"               -- ID файла из вкладки Files
-- ===========================================================

-- Ключ лицензии: юзер задаёт его перед loadstring:
--   getgenv().Key = "XXXX-XXXX-XXXX"
--   loadstring(game:HttpGet("<ссылка на лоадер>"))()
local Key = getgenv().Key or ""

local HttpService = game:GetService("HttpService")

-- универсальный request под разные экзекьюторы (POST нужен для API 1.3)
local httpreq = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

local BASE = "https://keyauth.win/api/1.3/"

local function notify(txt)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "NEVERBLOX", Text = tostring(txt), Duration = 5,
        })
    end)
    warn("[NEVERBLOX] " .. tostring(txt))
end

local function urlenc(s)
    return (HttpService:UrlEncode(tostring(s)))
end

-- HWID устройства (приложение требует Force HWID)
local function getHWID()
    local ok, id = pcall(function()
        if gethwid then return gethwid() end
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and type(id) == "string" and #id > 0 then return id end
    return "NB-" .. tostring(game.PlaceId)
end
local HWID = getHWID()

local function post(body)
    if not httpreq then
        notify("Экзекьютор не поддерживает POST (request). Нужен Synapse/Fluxus/Xeno и т.п.")
        return nil
    end
    local ok, res = pcall(httpreq, {
        Url = BASE,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Body = body,
    })
    if not ok or not res or not res.Body then
        notify("Сеть недоступна (keyauth.win). Проверь соединение.")
        return nil
    end
    local okj, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if not okj then
        notify("Плохой ответ сервера: " .. tostring(res.Body):sub(1, 120))
        return nil
    end
    return data
end

-- 0) есть ли ключ
if Key == "" then
    notify("Нет ключа. Запусти так:\ngetgenv().Key = \"ТВОЙ-КЛЮЧ\"  (перед loadstring)")
    return
end

-- 1) init -> sessionid
notify("Авторизация...")
local init = post(("type=init&ver=%s&name=%s&ownerid=%s"):format(
    urlenc(Version), urlenc(Name), urlenc(OwnerId)))
if not init then return end
if init.success ~= true then
    notify("init: " .. tostring(init.message))
    return
end
local sessionid = init.sessionid

-- 2) проверка ключа лицензии
local lic = post(("type=license&key=%s&hwid=%s&sessionid=%s&name=%s&ownerid=%s"):format(
    urlenc(Key), urlenc(HWID), urlenc(sessionid), urlenc(Name), urlenc(OwnerId)))
if not lic then return end
if lic.success ~= true then
    notify("Ключ: " .. tostring(lic.message))
    return
end
notify("Ключ принят. Загрузка...")

-- 3) скачивание файла
local f = post(("type=file&fileid=%s&sessionid=%s&name=%s&ownerid=%s"):format(
    urlenc(FileId), urlenc(sessionid), urlenc(Name), urlenc(OwnerId)))
if not f then return end
if f.success ~= true then
    notify("Файл: " .. tostring(f.message))
    return
end

-- 4) KeyAuth отдаёт contents в hex -> декодируем в исходник
local hex = f.contents
if type(hex) ~= "string" or #hex < 2 then
    notify("Пустой contents. Проверь File ID / что файл залит.")
    return
end
local buf = {}
for i = 1, #hex, 2 do
    buf[#buf + 1] = string.char(tonumber(hex:sub(i, i + 1), 16))
end
local src = table.concat(buf)

-- 5) запуск
local fn, err = loadstring(src)
if not fn then
    notify("loadstring error: " .. tostring(err))
    return
end
fn()
