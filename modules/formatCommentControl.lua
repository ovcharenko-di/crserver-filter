local _M = {}

-- проверка на пустой комментарий
function _M.check_format_comment(enabled, request_body)

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

    -- вот здесь можно написать свои проверки
    local five_digits = message:match([[^P1C-%d%d%d%d%d]])
    local no_task = message:match([[^#нетзадачи]])
    local double_n = message:match("\n\n")
    if (five_digits ~= nil or no_task ~= nil) and double_n ~= nil then
        return
    else
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.header.content_type = 'text/plain; charset=utf-8'
        ngx.say("Помещение в хранилище отклонено")
        ngx.say("НЕВЕРНЫЙ ФОРМАТ КОММЕНТАРИЯ")
        ngx.say("комментарий должен:")
        ngx.say("- начинаться на #12345 (где 12345 - номер задачи) или на #нетзадачи")
        ngx.say("- содержать пустую строку, отделяющую заголовок комментария от тела")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

end

return _M