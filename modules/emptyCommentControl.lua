local _M = {}

-- проверка на пустой комментарий
function _M.check_comment(enabled, request_body)

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
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.header.content_type = 'text/plain; charset=utf-8'
        ngx.say("ОТСУТСТВУЕТ КОММЕНТАРИЙ (check_comment)")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

end

return _M