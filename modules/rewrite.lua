ngx.req.read_body()

local req = ngx.var.request_body
local errors = {}
if req == nil then
    return
end

ngx.log(ngx.DEBUG, ngx.var.request_body)
if req:match([[DevDepot_commitObjects]]) == nil then
    return -- Интересуют только события помещения в хранилище, если для обработки нужно больше событий, можно их в эту проверку добавлять
end

local CheckFormatComment = true; --Проверка комментария вкл\выкл
local CheckEmptyComment = true; --Проверка пустого комментария вкл\выкл
local CheckVersion = true; --Проверка изменения версии конфигурации

local versionControl = require "modules.versionControl"
versionControl.check_version(CheckVersion, req, errors)

local emptyCommentControl = require "modules.emptyCommentControl"
emptyCommentControl.check_comment(CheckEmptyComment, req, errors)

local formatCommentControl = require "modules.formatCommentControl"
formatCommentControl.check_format_comment(CheckFormatComment, req, errors)

if #errors > 0 then 
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = 'text/plain; charset=utf-8'
    ngx.say(" ")
    for i = 1, #errors do
        ngx.log(ngx.DEBUG, errors[i] .. " <- array")
        ngx.say(errors[i])
    end
          
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end







