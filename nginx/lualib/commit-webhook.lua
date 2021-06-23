local _M = {}

local function post_timer(premature, uri, body)
    
    local httpc = require("resty.http").new()
    httpc:request_uri(uri, {
        method = "POST",
        body = body,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
        keepalive_timeout = 30000,
        keepalive_pool = 10
    })
    
end

function _M.post(uri, body)

    local req = ngx.req.get_body_data()
    if req == nil then
        return
    end

    if string.find(req, [[<crs:revise value="false"]], 1, true) then

        local ok, err = ngx.timer.at(0, post_timer, uri, body)

        if not ok then
            ngx.log(ngx.ERR, "error calling ".. uri)
            return
        end
    end
end

return _M
