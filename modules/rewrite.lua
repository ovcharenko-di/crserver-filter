ngx.req.read_body()

local req = ngx.var.request_body
if req == nil then
    return
end

ngx.log(ngx.DEBUG, ngx.var.request_body)
if req:match([[DevDepot_commitObjects]]) == nil then
    return -- Интересуют только события помещения в хранилище, если для обработки нужно больше событий, можно их в эту проверку добавлять
end

local CheckFormatComment = false; --Проверка комментария вкл\выкл
local CheckEmptyComment = false; --Проверка пустого комментария вкл\выкл
local CheckVersion = true; --Проверка изменения версии конфигурации

local versionControl = require "versionControl"
versionControl.check_version(CheckVersion, req)

local emptyCommentControl = require "emptyCommentControl"
emptyCommentControl.check_comment(CheckEmptyComment, req)

local formatCommentControl = require "formatCommentControl"
formatCommentControl.check_format_comment(CheckFormatComment, req)







