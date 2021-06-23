-- этот файл предназначен для подключения пользовательских действий,
-- которые НЕ предполагают внесение изменений в запросы и ответы
-- сервера хранилища (например, отправка уведомлений, вызов вебхуков)

local root_id = "example"
local tg_api_token = "example"
local tg_api = require('telegram-bot-lua.core').configure(tg_api_token)
local chat_id = "example"
local tg_notification = require("v8.tg-notification")
tg_notification.send(root_id, tg_api, chat_id)

local uri = "http://example.org"
local commit_webhook = require("v8.commit-webhook")
commit_webhook.post(uri, nil)
