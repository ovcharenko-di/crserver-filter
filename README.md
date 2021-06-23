# Набор инструментов для сервера хранилища конфигураций 1С

Это прокси-сервер nginx, который с помощью кода на языке Lua анализирует http-трафик сервера хранилища 1С и выполняет различные действия при возникновении определенных событий.

Работоспособность решения проверена на конфигурациях размера ERP 2.4 при активной работе 10+ разработчиков, в том числе в режиме подключения пустой конфигурации к хранилищу и при захвате \ помещении большого количества объектов.

## Стандартный набор инструментов

### commit-filter

Этот инструмент позволяет блокировать помещение изменений в хранилище без комментария, а также позволяет задать шаблон, которому должен соответствовать комментарий. Проверка осуществляется не только при помещении новых изменений, но и при редактировании закладок хранилища "задним числом". Если комментарий не соответствует формату, разработчик прямо в конфигураторе увидит ошибку с поясняющим сообщением.

Место срабатывания: `./data/nginx/rewrite.lua`

Реализация: `./nginx/lualib/commit-filter.lua`

Параметры:

- шаблон комментария (в формате PCRE)
- текст сообщения об ошибке

Формат комментария по умолчанию:

- начинается на `#`, после чего должны следовать либо 5 цифр, либо строка `"нетзадачи"`
- содержит два перевода строки
- содержит тело комментария

> Примеры корректных комментариев:
>
> ```md
> #12345 Обработка заполнения ТЧ "Товары"
>
> Добавлена обработка заполнения ТЧ "Товары" документа "Реализация товаров и услуг"
> ```
>
> ```md
> #нетзадачи
>
> Тех. долг
> ```

### tg-notification

Этот инструмент позволяет направить в указанный чат Telegram сообщение при успешном захвате или освобождении корня конфигурации:

- `<USERNAME> захватил корень конфигурации`
- `<USERNAME> освободил корень конфигурации`

Место срабатывания: `./data/nginx/log.lua`

Реализация: `./nginx/lualib/tg-notification.lua`

Параметры:

- GUID корня конфигурации
- токен для Telegram API
- идентификатор чата Telegram

### commit-webhook

Этот инструмент позволяет направить POST-запрос на произвольный адрес с произвольным телом при успешном помещении изменений в хранилище.
Например, его можно задействовать, чтобы gitsync запускался только тогда, когда нужно, а не по расписанию.

Место срабатывания: `./data/nginx/log.lua`

Реализация: `./nginx/lualib/commit-webhook.lua`

Параметры:

- uri
- тело запроса

## Установка

- клонировать репозиторий
- указать адрес текущего сервера хранилища в `conf.d/crserver-filter.conf`
- указать свои параметры обработчиков в `./data/nginx`
- если необходимо, изменить порт по умолчанию `3333`
- выполнить `docker-compose up -d`
- открыть Конфигуратор, закрыть хранилище, открыть хранилище, но вместо адреса текущего хранилища указать `http://<proxy-host>:<port>`

> Пример
>
> БЫЛО: `http://srv-app-01/CRServer/repository.1ccr/ERP_Master`
>
> СТАЛО: `http://srv-ci-01:3333/CRServer/repository.1ccr/ERP_Master`

После проверки работоспособности необходимо выполнить одно из двух действий:

- закрыть порт, на котором опубликован текущий сервер хранилища
- изменить порт, на котором опубликован текущий сервер хранилища, а затем обновить его в `conf.d/crserver-filter.conf` и перезапустить контейнер.

## Как добавить свой инструмент?

- определить директиву [lua-nginx-module](https://github.com/openresty/lua-nginx-module#directives), в которой должен срабатывать ваш инструмент

> уже реализована поддержка директив `rewrite_by_lua` и `log_by_lua`

Как добавить директиву:

- в `./data/nginx/*.lua` добавить обработчик директивы
- в файле `conf.d/crserver-filter.conf` дописать вызов этого обработчика

При необходимости в каталог `./nginx/lualib` можно добавить свою библиотечную функцию, которую можно вызывать в обработчиках директив через `require`

## Используемое ПО

Проект реализован на базе образа [OpenResty](https://openresty.org/).
Прототип, который был взят за основу: [commitHook](https://github.com/asosnoviy/commitHook).

Задействованны внешние библиотеки:

- [resty.http](https://github.com/ledgetech/lua-resty-http)
- [telegram-bot-lua](https://github.com/wrxck/telegram-bot-lua)
- [lrexlib](https://github.com/rrthomas/lrexlib)

## Спасибо

- [Алексею Сосновому](https://github.com/asosnovy), автору проекта-прототипа [commitHook](https://github.com/asosnoviy/commitHook)
- [Андрею Овсянкину](https://github.com/EvilBeaver), за помощь в развитии проекта
- [Олегу Тымко](https://github.com/OTymko), за помощь с разбором протокола хранилища
