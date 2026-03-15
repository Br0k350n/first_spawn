local function queryOutfitRows(limit)
    local dbCfg = CodeStudio.PlanePedDatabase or {}
    local tableName = dbCfg.table or 'rcore_clothing_current'
    local maxRows = tonumber(limit) or tonumber(dbCfg.limit) or 128
    maxRows = math.max(1, math.min(maxRows, 500))

    local query = ('SELECT ped_model, outfit FROM `%s` WHERE outfit IS NOT NULL AND outfit != "" ORDER BY RAND() LIMIT ?'):format(tableName)

    if GetResourceState('oxmysql') == 'started' and exports.oxmysql then
        local result = exports.oxmysql:query_sync(query, { maxRows }) or {}
        return result
    end

    if GetResourceState('mysql-async') == 'started' then
        local p = promise.new()
        MySQL.Async.fetchAll(query, { maxRows }, function(rows)
            p:resolve(rows or {})
        end)

        return Citizen.Await(p)
    end

    print('[cs_intro] No supported SQL resource found (oxmysql/mysql-async). Falling back to config pool.')
    return {}
end

RegisterNetEvent('cs:introCinematic:requestPlaneOutfits', function(requestId)
    local src = source
    local sourceMode = (CodeStudio.PlanePedOutfitSource or 'config'):lower()
    local useAdvanced = CodeStudio.AdvancedPlanePedCreation ~= false

    if not useAdvanced or sourceMode ~= 'database' then
        TriggerClientEvent('cs:introCinematic:receivePlaneOutfits', src, requestId, {})
        return
    end

    local rows = queryOutfitRows((CodeStudio.PlanePedDatabase or {}).limit)
    local payload = {}

    for i = 1, #rows do
        local row = rows[i]
        payload[#payload + 1] = {
            model = tonumber(row.ped_model),
            outfit = row.outfit
        }
    end

    TriggerClientEvent('cs:introCinematic:receivePlaneOutfits', src, requestId, payload)
end)
