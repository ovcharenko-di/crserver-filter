local _M = {}

-- проверка на пустой комментарий
function _M.check_format_comment(enabled, request_body, errors)

    if enabled == false then
        ngx.log(ngx.DEBUG, "Проверка формата комментария отключена")
        return
    end

    local commentPattern = [[<crs:comment>(.*)</crs:comment>]]

    local message

    if request_body:match([[DevDepot_commitObjects]]) ~= nil then
        message = request_body:match(commentPattern) -- комментарий хранилища
    else
        return
    end
    if message == nil then
        return
    end

    -- вот здесь можно написать свои проверки
    local five_digits = message:match([[^.+-%d+]])
    local no_task = message:match([[^#нетзадачи]])
    local double_n = message:match("\n\n")

    if (five_digits ~= nil ) then
        ngx.log(ngx.DEBUG, "Номер задачи : Указан")
    else    
        ngx.log(ngx.DEBUG, "Номер задачи : Не Указан") 
    end
  
    if (no_task ~= nil ) then
        ngx.log(ngx.DEBUG, "Нет задачи  : Тег указан")
    else    
        ngx.log(ngx.DEBUG, "Нет задачи : Тег не указан") 
    end
    if (double_n ~= nil ) then
        ngx.log(ngx.DEBUG, "Перенос строки  : Есть ")
    else    
        ngx.log(ngx.DEBUG, "Перенос строки : Отсутствует") 
    end
 


    if (five_digits ~= nil or no_task ~= nil) and double_n ~= nil then
        return
    else
        table.insert(errors, "Неверный форма комментария (comment_control)")
        table.insert(errors, "комментарий должен:")
        table.insert(errors, "- начинаться на P1C-12345 (где 12345 - номер задачи) или на #нетзадачи")
        table.insert(errors, "- содержать пустую строку, отделяющую заголовок комментария от тела")
    end

end

return _M