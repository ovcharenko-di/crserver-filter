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
    local five_digits = message:match([[^P1C-%d%d%d%d%d]])
    local no_task = message:match([[^#нетзадачи]])
    local double_n = message:match("\n\n")
    if (five_digits ~= nil or no_task ~= nil) and double_n ~= nil then
        return
    else
        table.insert(errors, "Неверный форма комментария (comment_control)")
        table.insert(errors, "комментарий должен:")
        table.insert(errors, "- начинаться на #12345 (где 12345 - номер задачи) или на #нетзадачи")
        table.insert(errors, "- содержать пустую строку, отделяющую заголовок комментария от тела")
    end

end

return _M