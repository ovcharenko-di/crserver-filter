local _M = {}

function _M.check_comment(pattern, errorMessage)

    ngx.req.read_body()

    local req = ngx.req.get_body_data()
    if req == nil then
        return
    end

    local commentNode = [[<crs:comment>(.*)</crs:comment>]]
    local commitMessage
    if req:match([[name="DevDepot_commitObjects"]]) ~= nil then
        commitMessage = req:match(commentNode)
    elseif req:match([[DevDepot_changeVersion]]) ~= nil then
        local newVersion = req:match([[<crs:newVersion>(.*)</crs:newVersion>]])
        if newVersion == nil then
            return
        end
        commitMessage = newVersion:match(commentNode)
    else
        return
    end

    -- проверка на пустой комментарий
    if commitMessage == nil then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.header.content_type = 'text/plain; charset=utf-8'
        ngx.say("ОТСУТСТВУЕТ КОММЕНТАРИЙ")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    if pattern ~= nil then
        local rex = require('rex_pcre')
        local captures = rex.match(commitMessage, pattern)
        if captures == nil then
            ngx.status = ngx.HTTP_BAD_REQUEST
            ngx.header.content_type = 'text/plain; charset=utf-8'
            ngx.say(errorMessage)
            ngx.exit(ngx.HTTP_BAD_REQUEST)
        else
            return
        end
    end
end

return _M
