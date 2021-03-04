local _M = {}

function _M.apply(pattern)

    ngx.req.read_body()

    local req = ngx.var.request_body
    if req == nil then
        return
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
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say("Empty comment is not allowed")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    -- вот здесь можно написать свои проверки
    if pattern ~= nil then
        local matches = message:match(pattern)
        if matches ~= nil then
            return
        else
            ngx.status = ngx.HTTP_BAD_REQUEST
            ngx.say("Comment is not matched our team standards")
            ngx.exit(ngx.HTTP_BAD_REQUEST)
        end
    end
end

return _M