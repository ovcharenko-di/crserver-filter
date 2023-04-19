local _M = {}

-- проверка на пустой комментарий
function _M.check_comment(enabled, request_body, errors)

    if enabled == false then
        ngx.log(ngx.DEBUG, "Проверка пустого комментария отключена")
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
        table.insert(errors, "Отсутствует комментарий (comment_check)")
    end

end

return _M