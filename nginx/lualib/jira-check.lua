local _M = {}

local function jira_get_timer(premature, uri)
    
    local httpc = require("resty.http").new()
    httpc:request_uri(uri, {
        method = "GET",
        keepalive_timeout = 30000,
        keepalive_pool = 10
    })
    
end

local function parse_json_body(body)
    local json = require("v8.JSON") 
    local luaBody = json:decode(body)
    return luaBody.fields.status.name
end

function _M.get_task_status(task)
    local uri = "https://jira.melonfashion.ru/rest/api/2/issue/"+task+"?fields=status&fieldsByKeys=false"
    local res, err = ngx.timer.at(0, jira_get_timer, uri)

    if not res then
        ngx.log(ngx.ERR, "error calling ".. uri)
        return nil
    end
    local status = res.status
    local body   = res.body
    if not status == 200 then
        ngx.log(ngx.ERR, "Jira api responce status is not OK".. status)
        return nil
    end
    
    local status = parse_json_body(body)
    return status
end

return _M
