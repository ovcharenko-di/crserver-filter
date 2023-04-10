local CheckFormatComment = false; --Проверка комментария вкл\выкл

ngx.req.read_body()

ngx.log(ngx.ERR, ngx.var.request_body)

local req = ngx.var.request_body
if req == nil then
    return
end

local crs_keys = ngx.shared.crs_keys

local crsName
local crsNamePattern = [[alias="(%a+)"]]
if req:match([[DevDepot_commitObjects]]) ~= nil then
    crsName = req:match(crsNamePattern) -- имя хранилища
else
    crsName = nil
end

local currentVersion
local versionPattern = [[<crs:code value="(.*)"/>]]
if req:match([[DevDepot_commitObjects]]) ~= nil then
    currentVersion = req:match(versionPattern) -- версия хранилища
else
    currentVersion = nil
end

local previousVersion = crs_keys:get(crsName)

if currentVersion ~= nil and crsName ~= nil and currentVersion ~= previousVersion then
    crs_keys:set(crsName, currentVersion)
end

local commentPattern = [[<crs:comment>(.*)</crs:comment>]]

local message
if req:match([[DevDepot_commitObjects]]) ~= nil then
    message = req:match(commentPattern) -- комментарий хранилища
elseif req:match([[DevDepot_changeVersion]]) ~= nil then
    local newVersion = req:match([[<crs:newVersion>(.*)</crs:newVersion>]])
    if newVersion == nil then
        return
    end
    message = newVersion:match(commentPattern)
else
    return
end

-- проверка на пустой комментарий
if message == nil then
    crs_keys:set(crsName, previousVersion)
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = 'text/plain; charset=utf-8'
    ngx.say("ОТСУТСТВУЕТ КОММЕНТАРИЙ")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

if currentVersion == nil and crsName == nil then
    ngx.log(ngx.DEBUG, "Не удалось узнать версию")
    return
elseif previousVersion == nil then
    ngx.log(ngx.DEBUG, "Ранних записей по версии конфигурации не удалось обнаружить. Помещение разрешено.")              
    return
elseif currentVersion ~= previousVersion then
    ngx.log(ngx.DEBUG, "Отлично, версия изменена! Была: " .. previousVersion .. "Стала: " .. currentVersion)
else
    ngx.log(ngx.DEBUG, "Необходимо изменить номер версии! Последняя зарегистрированая: " .. previousVersion)
    crs_keys:set(crsName, previousVersion)
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = 'text/plain; charset=utf-8'
    ngx.say("Необходимо изменить номер версии! Последняя зарегистрированая: " .. previousVersion)
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end

if CheckFormatComment == false then
    ngx.log(ngx.DEBUG, "Проверка формата комментария отключена")
    crs_keys:set(crsName, previousVersion)
    return
end
-- вот здесь можно написать свои проверки
local five_digits = message:match([[^#%d%d%d%d%d]])
local no_task = message:match([[^#нетзадачи]])
local double_n = message:match("\n\n")
if (five_digits ~= nil or no_task ~= nil) and double_n ~= nil then
    return
else
    crs_keys:set(crsName, previousVersion)
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = 'text/plain; charset=utf-8'
    ngx.say("Помещение в хранилище отклонено")
    ngx.say("НЕВЕРНЫЙ ФОРМАТ КОММЕНТАРИЯ")
    ngx.say("комментарий должен:")
    ngx.say("- начинаться на #12345 (где 12345 - номер задачи) или на #нетзадачи")
    ngx.say("- содержать пустую строку, отделяющую заголовок комментария от тела")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end