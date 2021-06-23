local _M = {}

function _M.send(rootId, api, chatId)

    local req = ngx.req.get_body_data()
    if req == nil then
        return
    end

    local res = ngx.var.resp_body
    if res == nil then
        return
    end

    local user = req:match([[<crs:auth user="(.*)" password]])
    local message = ""
    if string.find(req, [[name="DevDepot_reviseDevObjects"]], 1, true) then
        local nodeRoot = [[<crs:first value="rootId"/>]];
        if string.find(req, nodeRoot:gsub("rootId", rootId), 1, true) then
            if string.find(req, [[<crs:revise value="true"]], 1, true) then
                local allProcessed = res:find([[<crs:unprocessed/>]])
                if not allProcessed then
                    local unprocessed = res:match([[<crs:unprocessed>(.*)</crs:unprocessed]])
                    local valueNotProcessed = [[<crs:value value="rootId"/>]]
                    local rootProcessed = not unprocessed:find(valueNotProcessed:gsub("rootId", rootId), 1, true)
                end
                if allProcessed or rootProcessed then
                    message = user .. " захватил корень конфигурации"
                end
            elseif string.find(req, [[<crs:revise value="false"]], 1, true) then
                message = user .. " освободил корень конфигурации"
            end
        end
    end

    api.send_message(
        chatId,
        message,
        nil,
        true,
        true,
        nil
    )

end

return _M
