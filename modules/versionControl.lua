local _M = {}


function _M.check_version(enabled, request_body)

    if enabled == false then
        ngx.log(ngx.DEBUG, "Проверка изменения версии конфигурации отключена")
        return
    end

    local crs_keys = ngx.shared.crs_keys

    local crsName
    local crsNamePattern = [[alias="(%a+)"]]
    if request_body:match([[DevDepot_commitObjects]]) ~= nil then
        crsName = request_body:match(crsNamePattern) -- имя хранилища
    else
        return
        ngx.log(ngx.DEBUG, "Не удалось идентифицировать имя хранилища")
    end
    ngx.log(ngx.DEBUG, "Идентифицировано хранилища: " .. crsName)
    
    local currentVersion
    local versionPattern = [[<crs:code value="(.*)"/>]]
    if request_body:match([[DevDepot_commitObjects]]) ~= nil then
        currentVersion = request_body:match(versionPattern) -- версия хранилища
        ngx.log(ngx.DEBUG, "Определена версия конфигурации хранилища: " .. currentVersion)
    else
        currentVersion = nil
        ngx.log(ngx.DEBUG, "Не удалось определить версию конфигурации хранилища")
    end

    if request_body:match([[debug]]) ~= nil then --для выводи текста запроса в окно сообщения 1с надо написать в тексте комментария 'debug'
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.header.content_type = 'text/plain; charset=utf-8'
        ngx.say(request_body)
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    
    local previousVersion = crs_keys:get(crsName)

    if previousVersion == nil then
        ngx.log(ngx.DEBUG, "Не определена предыдущая версия хранилища" )
    else
        ngx.log(ngx.DEBUG, "Определена предыдущай версия хранилища: " .. previousVersion)
    end

    if currentVersion ~= nil and previousVersion ~= nil then
        local currentV = currentVersion:match([[(%d+%.?%d*%.?%d*)$]])
        local prevV = previousVersion:match([[(%d+%.?%d*%.?%d*)$]])
        if currentV ~= nil and prevV ~= nil then
            local v = require 'modules.semver'
            local vCur = v(currentV)
            local vPrev = v(prevV)
            ngx.log(ngx.DEBUG, " - - - - - - : " .. prevV .. " - - " ..currentV)
            if vCur == vPrev then
                ngx.log(ngx.DEBUG, "Необходимо изменить номер версии! Твоя версия: " .. currentV)

                crs_keys:set(crsName, previousVersion)
                ngx.status = ngx.HTTP_BAD_REQUEST
                ngx.header.content_type = 'text/plain; charset=utf-8'
                ngx.say("Необходимо изменить номер версии! Твоя версия: " .. currentV)
                ngx.exit(ngx.HTTP_BAD_REQUEST)
                return                            
            elseif vCur < vPrev then
                ngx.log(ngx.DEBUG, "Понижение версии запрещено! Твоя версия: " .. currentV .. " Последняя зарегистрированная : " ..prevV) 

                crs_keys:set(crsName, previousVersion)
                ngx.status = ngx.HTTP_BAD_REQUEST
                ngx.header.content_type = 'text/plain; charset=utf-8'
                ngx.say("Понижение версии запрещено! Твоя версия: " .. currentV .. " Последняя зарегистрированная : " ..prevV)
                ngx.exit(ngx.HTTP_BAD_REQUEST)
                return  
            else
                ngx.log(ngx.DEBUG, "Красавчик, версию поднял! " .. prevV .. "  -> : " ..currentV) 
            end
        end
    end
   
     
    if currentVersion ~= nil and crsName ~= nil and currentVersion ~= previousVersion then
        crs_keys:set(crsName, currentVersion)
        ngx.log(ngx.DEBUG, "Для хранилища: " .. crsName .. " записано соответствие верисии : " .. currentVersion)
    end
    
    if currentVersion == nil and crsName == nil then
        ngx.log(ngx.DEBUG, "Не удалось узнать версию")
        return
    elseif previousVersion == nil then
        ngx.log(ngx.DEBUG, "Ранних записей по версии конфигурации не удалось обнаружить. Помещение разрешено.")              
        return
    elseif currentVersion ~= previousVersion then
        ngx.log(ngx.DEBUG, "Отлично, версия изменена! Была: " .. previousVersion .. " Стала: " .. currentVersion)
    else
        ngx.log(ngx.DEBUG, "Необходимо изменить номер версии! Последняя зарегистрированая: " .. previousVersion)
        crs_keys:set(crsName, previousVersion)
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.header.content_type = 'text/plain; charset=utf-8'
        ngx.say("Необходимо изменить номер версии! Последняя зарегистрированая: " .. previousVersion)
        ngx.exit(ngx.HTTP_BAD_REQUEST)
        return
    end

end

return _M