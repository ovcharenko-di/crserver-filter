-- Прототип коммит-хука при помещении в хранилище
-- вызывает произвольный сервис при коммите.
-- Удобен для запуска gitsync при помещении в хранилище

-- Основан на работе https://github.com/asosnoviy/commitHook

-- TODO 
-- * переписать под resty.http вместо luacurl https://github.com/ledgetech/lua-resty-http
-- * обеспечить единоразовое чтение request_body всеми плагинами, а не каждым по отдельности



-- local data = ngx.var.request_body
        
--                if string.find(data, "DevDepot_commitObjects") then
               
--                 local cURL = require("luacurl")
--                 local api_http = "http://192.168.10.144"
--                 local api_key = "123"
--                 local api_paste = "testapi"
--                 c = cURL.new()
--                 c:setopt(curl.OPT_URL, api_http)
--                 c:setopt(curl.OPT_POST, true)
--                 c:setopt(curl.OPT_POSTFIELDS, "api_option=paste&api_dev_key="..api_key.."&api_paste_code="..api_paste.."&api_paste_private=0&api_paste_format=php")
--                 c:setopt(curl.OPT_TRANSFERTEXT, true)
--                 c:setopt(curl.OPT_VERBOSE, true)
--                 c:setopt(curl.OPT_NOBODY, false)
--                 c:perform()
--                 c:close()
--               end
--             ';