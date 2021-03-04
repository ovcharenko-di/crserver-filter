-- Прототип коммит-хука при помещении в хранилище
-- вызывает произвольный сервис при коммите.
-- Удобен для запуска gitsync при помещении в хранилище

-- Основан на работе https://github.com/asosnoviy/commitHook

-- TODO 
-- * обеспечить единоразовое чтение request_body всеми плагинами, а не каждым по отдельности

local _M = {}

function call(url, body)

    local data = ngx.var.request_body

    ngx.req.read_body()

    local req = ngx.var.request_body
    if req == nil then
        return
    end

    if string.find(req, "DevDepot_commitObjects") then
        local http = require "resty.http"
        local httpc = http.new()
        local res, err = httpc:request_uri(url, {
            method = "POST",
            body = body,
            headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            },
            keepalive_timeout = 30000,
            keepalive_pool = 10
        })

        if not res then
            ngx.log(ngx.WARN, "error calling "..url)
            return
        end
    end
end