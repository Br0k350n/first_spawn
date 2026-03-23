local taxiVeh
local isTaxi = false
local Active = false

math.randomseed(GetGameTimer())

local sub_b0b5 = {
    "MP_Plane_Passenger_1", "MP_Plane_Passenger_2", "MP_Plane_Passenger_3",
    "MP_Plane_Passenger_4", "MP_Plane_Passenger_5", "MP_Plane_Passenger_6", "MP_Plane_Passenger_7"
}

local overlayIndexMap = {
    blemishes = 0,
    facialHair = 1,
    eyebrows = 2,
    aging = 3,
    makeup = 4,
    blush = 5,
    complexion = 6,
    sunDamage = 7,
    lipstick = 8,
    molesFreckles = 9,
    chestHair = 10,
    bodyBlemishes = 11,
    addBodyBlemishes = 12,
    beard = 1
}

local pendingOutfitRequests = {}
local databaseOutfitPool = {}

local function randomInRange(range, fallbackMin, fallbackMax)
    local min = range and range.min or fallbackMin
    local max = range and range.max or fallbackMax

    if min > max then
        min, max = max, min
    end

    return math.random(min, max)
end

local function randomFloatFromPercentRange(range, fallbackMin, fallbackMax)
    return randomInRange(range, fallbackMin, fallbackMax) / 100.0
end

local function parseRcorePiece(value)
    if type(value) ~= 'string' then
        return nil, nil, nil
    end

    local component, drawable, texture = value:match('.+%-%-(%-?%d+)%-%-(%-?%d+)%-%-(%-?%d+)')
    if not component then
        return nil, nil, nil
    end

    return tonumber(component), tonumber(drawable), tonumber(texture)
end

local function resolvePedModel(modelValue)
    if type(modelValue) == 'number' then
        return modelValue
    end

    if type(modelValue) == 'string' and modelValue ~= '' then
        local numeric = tonumber(modelValue)
        if numeric then
            return numeric
        end

        return GetHashKey(modelValue)
    end

    return nil
end

local function convertRcoreOutfitToPreset(entry)
    if not entry or not entry.outfit then
        return nil
    end

    local decoded = type(entry.outfit) == 'string' and json.decode(entry.outfit) or entry.outfit
    if type(decoded) ~= 'table' then
        return nil
    end

    local preset = {
        model = resolvePedModel(entry.model) or resolvePedModel(entry.ped_model) or `mp_m_freemode_01`,
        components = {},
        props = {},
        overlays = {},
        rcoreOutfitData = decoded
    }

    local headblend = decoded.headblend or {}
    preset.blend = {
        shapeFirst = tonumber(headblend.maleModel) or 0,
        shapeSecond = tonumber(headblend.femaleModel) or 0,
        skinFirst = tonumber(headblend.maleTone) or 0,
        skinSecond = tonumber(headblend.femaleTone) or 0,
        shapeMix = tonumber(headblend.modelBlend) or 0.5,
        skinMix = tonumber(headblend.toneBlend) or 0.5
    }

    local hair = decoded.hair or {}
    local _, hairDrawable, hairTexture = parseRcorePiece(hair.id)
    preset.hair = {
        style = hairDrawable or 0,
        texture = hairTexture or 0,
        colorPrimary = tonumber(hair.color1) or 0,
        colorSecondary = tonumber(hair.color2) or 0
    }

    for _, piece in pairs(decoded.components or {}) do
        local component, drawable, texture = parseRcorePiece(piece)
        if component ~= nil and drawable ~= nil and texture ~= nil then
            if component >= 0 and component <= 11 then
                preset.components[#preset.components + 1] = {
                    component = component,
                    drawable = drawable,
                    texture = texture
                }
            elseif component >= 100 then
                preset.props[#preset.props + 1] = {
                    prop = component - 100,
                    drawable = drawable,
                    texture = texture
                }
            end
        end
    end

    return preset
end

RegisterNetEvent('cs:introCinematic:receivePlaneOutfits', function(requestId, rows)
    local cb = pendingOutfitRequests[requestId]
    if cb then
        pendingOutfitRequests[requestId] = nil
        cb(rows or {})
    end
end)

local function requestDatabaseOutfits(timeoutMs)
    local requestId = ('%s:%s:%s'):format(GetPlayerServerId(PlayerId()), GetGameTimer(), math.random(1000, 9999))
    local received = false
    local response = {}

    pendingOutfitRequests[requestId] = function(rows)
        response = rows or {}
        received = true
    end

    TriggerServerEvent('cs:introCinematic:requestPlaneOutfits', requestId)

    local expireAt = GetGameTimer() + (timeoutMs or 2000)
    while not received and GetGameTimer() < expireAt do
        Wait(0)
    end

    pendingOutfitRequests[requestId] = nil

    if not received then
        return {}
    end

    return response
end

local function ensureDatabaseOutfitPool()
    local sourceMode = (CodeStudio.PlanePedOutfitSource or 'config'):lower()
    if sourceMode ~= 'database' then
        return
    end

    local rows = requestDatabaseOutfits(2500)
    databaseOutfitPool = {}

    for i = 1, #rows do
        local converted = convertRcoreOutfitToPreset(rows[i])
        if converted then
            databaseOutfitPool[#databaseOutfitPool + 1] = converted
        end
    end
end

local function isAdvancedPlanePedCreationEnabled()
    return CodeStudio.AdvancedPlanePedCreation ~= false
end

local function getRandomSimplePlanePedModel()
    local simplePool = CodeStudio.PlanePedModelPool or {}
    if #simplePool == 0 then
        return `a_m_m_business_01`
    end

    return simplePool[math.random(1, #simplePool)]
end

local function applyOverlay(ped, overlayName, overlayData, randomCfg, randomizeCfg)
    local overlayId = overlayIndexMap[overlayName]
    if not overlayId then return end

    local style = overlayData.style or 0
    local opacity = (overlayData.opacity or 100) / 100.0

    if overlayName == 'blemishes' and randomizeCfg.blemishes then
        style = randomInRange(randomCfg.blemishesStyle, 0, 23)
        opacity = randomFloatFromPercentRange(randomCfg.blemishesOpacity, 20, 90)
    end

    SetPedHeadOverlay(ped, overlayId, style, opacity)

    if overlayData.color or overlayData.secondColor then
        local colorType = overlayData.colorType or 1
        local color = overlayData.color or 0
        local secondColor = overlayData.secondColor or 0
        SetPedHeadOverlayColor(ped, overlayId, colorType, color, secondColor)
    end
end

local function applyComponents(ped, components)
    for _, component in ipairs(components or {}) do
        SetPedComponentVariation(
            ped,
            component.component,
            component.drawable or 0,
            component.texture or 0,
            component.palette or 0
        )
    end
end

local function applyProps(ped, props)
    for i = 0, 8 do
        ClearPedProp(ped, i)
    end

    for _, prop in ipairs(props or {}) do
        if (prop.drawable or -1) < 0 then
            ClearPedProp(ped, prop.prop)
        else
            SetPedPropIndex(ped, prop.prop, prop.drawable, prop.texture or 0, true)
        end
    end
end

local function applyFaceFeatures(ped, faceFeatures)
    if not faceFeatures then return end

    for index, value in pairs(faceFeatures) do
        local featureIndex = tonumber(index)
        local featureValue = tonumber(value)
        if featureIndex and featureValue then
            SetPedFaceFeature(ped, featureIndex, featureValue)
        end
    end
end

local function applyRandomTattoos(ped, settings)
    local tattooPool = settings.tattooPool or {}
    if #tattooPool == 0 then
        return
    end

    ClearPedDecorations(ped)

    local chance = settings.tattooChance or 35
    if math.random(1, 100) > chance then
        return
    end

    local tattooEntry = tattooPool[math.random(1, #tattooPool)]
    if tattooEntry and tattooEntry.collection and tattooEntry.name then
        AddPedDecorationFromHashes(ped, GetHashKey(tattooEntry.collection), GetHashKey(tattooEntry.name))
    end
end

local function applyRcoreAppearanceIfEnabled(ped, outfit, settings)
    local rcoreCfg = settings.rcore or {}
    if not rcoreCfg.enabled then
        return
    end

    local resourceName = rcoreCfg.resource or 'rcore_clothes'
    local exportName = rcoreCfg.export

    if not exportName or exportName == '' then
        return
    end

    local resourceState = GetResourceState(resourceName)
    if resourceState ~= 'started' then
        print(('[cs_intro] rcore bridge skipped: resource %s is %s'):format(resourceName, resourceState))
        return
    end

    local payload = outfit.rcoreOutfitData or outfit

    local ok, err = pcall(function()
        exports[resourceName][exportName](ped, payload)
    end)

    if not ok then
        print(('[cs_intro] rcore bridge failed (%s:%s): %s'):format(resourceName, exportName, err))
    end
end

local function applyRandomizedPedAppearance(ped, outfit)
    local settings = CodeStudio.PlanePedSettings or {}
    local randomCfg = settings.random or {}
    local randomizeCfg = settings.randomize or {}

    local blend = outfit.blend or {}
    local raceShapeFirst = blend.shapeFirst or 0
    local raceShapeSecond = blend.shapeSecond or raceShapeFirst
    local raceSkinFirst = blend.skinFirst or 0
    local raceSkinSecond = blend.skinSecond or raceSkinFirst
    local shapeMix = blend.shapeMix or 0.5
    local skinMix = blend.skinMix or 0.5

    if randomizeCfg.race ~= false then
        raceShapeFirst = randomInRange(randomCfg.raceShape, 0, 45)
        raceShapeSecond = randomInRange(randomCfg.raceShape, 0, 45)
        raceSkinFirst = randomInRange(randomCfg.raceSkin, 0, 45)
        raceSkinSecond = randomInRange(randomCfg.raceSkin, 0, 45)
        shapeMix = randomFloatFromPercentRange(randomCfg.blendShapeMix, 35, 100)
        skinMix = randomFloatFromPercentRange(randomCfg.blendSkinMix, 35, 100)
    end

    SetPedHeadBlendData(
        ped,
        raceShapeFirst,
        raceShapeSecond,
        0,
        raceSkinFirst,
        raceSkinSecond,
        0,
        shapeMix,
        skinMix,
        0.0,
        false
    )

    local hairData = outfit.hair or {}
    local hairStyle = hairData.style or 0
    local hairPrimary = hairData.colorPrimary or 0
    local hairSecondary = hairData.colorSecondary or hairPrimary

    if randomizeCfg.hairColor ~= false then
        hairPrimary = randomInRange(randomCfg.hairColorPrimary, 0, 63)
        hairSecondary = randomInRange(randomCfg.hairColorSecondary, 0, 63)
    end

    SetPedComponentVariation(ped, 2, hairStyle, hairData.texture or 0, 0)
    SetPedHairColor(ped, hairPrimary, hairSecondary)

    local eyeColor = outfit.eyeColor or 0
    if randomizeCfg.eyeColor ~= false then
        eyeColor = randomInRange(randomCfg.eyeColor, 0, 31)
    end
    SetPedEyeColor(ped, eyeColor)

    applyOverlay(ped, 'blemishes', outfit.blemishes or {}, randomCfg, randomizeCfg)
    for overlayName, overlayData in pairs(outfit.overlays or {}) do
        applyOverlay(ped, overlayName, overlayData, randomCfg, randomizeCfg)
    end

    applyFaceFeatures(ped, outfit.faceFeatures)

    if randomizeCfg.tattoos ~= false then
        applyRandomTattoos(ped, settings)
    end

    local components = outfit.components or {}
    if #components == 0 then
        if IsPedModel(ped, `mp_f_freemode_01`) then
            components = {
                { component = 3, drawable = 15, texture = 0 },
                { component = 4, drawable = 15, texture = 0 },
                { component = 6, drawable = 35, texture = 0 },
                { component = 8, drawable = 3, texture = 0 },
                { component = 11, drawable = 15, texture = 0 }
            }
        else
            components = {
                { component = 3, drawable = 15, texture = 0 },
                { component = 4, drawable = 14, texture = 0 },
                { component = 6, drawable = 34, texture = 0 },
                { component = 8, drawable = 15, texture = 0 },
                { component = 11, drawable = 15, texture = 0 }
            }
        end
    end

    applyComponents(ped, components)
    applyProps(ped, outfit.props)
    applyRcoreAppearanceIfEnabled(ped, outfit, settings)
end

local function getRandomPlanePedOutfit()
    local sourceMode = (CodeStudio.PlanePedOutfitSource or 'config'):lower()
    local pool = sourceMode == 'database' and databaseOutfitPool or (CodeStudio.PlanePedOutfitPool or {})

    if #pool == 0 then
        pool = CodeStudio.PlanePedOutfitPool or {}
    end

    if #pool == 0 then
        return {
            model = `mp_m_freemode_01`,
            hair = { style = 0 },
            overlays = {},
            components = {
                { component = 3, drawable = 1, texture = 0 },
                { component = 4, drawable = 0, texture = 0 },
                { component = 6, drawable = 1, texture = 0 },
                { component = 8, drawable = 15, texture = 0 },
                { component = 11, drawable = 0, texture = 0 }
            },
            props = {}
        }
    end

    return pool[math.random(1, #pool)]
end

RegisterNetEvent('cs:introCinematic:start', function()
    local plyrId = PlayerPedId()
    local gender = IsPedModel(plyrId, "mp_m_freemode_01")
    
    PrepareMusicEvent("FM_INTRO_START")
    TriggerMusicEvent("FM_INTRO_START")

    local cutsceneType = gender and 31 or 103
    RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", cutsceneType, 8)

    while not HasCutsceneLoaded() do Wait(10) end
    
    local entityModel = GetEntityModel(plyrId)
    local cutsceneEntity = gender and 'MP_Male_Character' or 'MP_Female_Character'
    
    RegisterEntityForCutscene(0, cutsceneEntity, 3, entityModel, 0)
    RegisterEntityForCutscene(plyrId, cutsceneEntity, 0, 0, 0)
    SetCutsceneEntityStreamingFlags(cutsceneEntity, 0, 1)
    
    local oppositeGenderEntity = RegisterEntityForCutscene(0, gender and "MP_Female_Character" or "MP_Male_Character", 3, 0, 64)
    NetworkSetEntityInvisibleToNetwork(oppositeGenderEntity, true)

    local useAdvanced = isAdvancedPlanePedCreationEnabled()
    if useAdvanced then
        ensureDatabaseOutfitPool()
    end

    local ped = {}
    for i = 0, 6 do
        local outfit = useAdvanced and getRandomPlanePedOutfit() or nil
        local model = useAdvanced and (outfit.model or `mp_m_freemode_01`) or getRandomSimplePlanePedModel()

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        ped[i] = CreatePed(26, model, -1117.7778, -1557.6249, 3.3819, 0.0, false, false)
        SetEntityAsMissionEntity(ped[i], true, true)

        if useAdvanced and outfit then
            applyRandomizedPedAppearance(ped[i], outfit)
        end

        -- sub_b0b5 is a 1-based Lua array while this loop is 0-based.
        -- Shift index so each spawned ped is registered to the proper cutscene seat.
        RegisterEntityForCutscene(ped[i], sub_b0b5[i + 1], 0, 0, 64)
    end
    
    NewLoadSceneStartSphere(-1212.79, -1673.52, 7, 1000, 0)
    SetWeatherTypeNow("EXTRASUNNY")
    StartCutscene(4)

    Wait(34520) -- Cutscene duration

    for i = 0, 6 do
        DeleteEntity(ped[i])
    end

    PrepareMusicEvent("AC_STOP")
    TriggerMusicEvent("AC_STOP")
    StopCutsceneImmediately()

    DoScreenFadeOut(250)
    Wait(2500)

    ClearPedWetness(plyrId)

    if CodeStudio.useTaxi then
        CreateTaxi(CodeStudio.TaxiSpawn)
    else
        SetEntityCoords(plyrId, CodeStudio.SpawnPedLoc)
        DoScreenFadeIn(250)
    end
end)


function createTaxiPed(vehicle)
    local model = GetHashKey("a_m_y_stlat_01")
    if DoesEntityExist(vehicle) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end
        
        local taxiPed = CreatePedInsideVehicle(vehicle, 26, model, -1, true, false)
        SetAmbientVoiceName(taxiPed, "A_M_M_EASTSA_02_LATINO_FULL_01")
        SetBlockingOfNonTemporaryEvents(taxiPed, true)
        SetEntityAsMissionEntity(taxiPed, true, true)
        SetModelAsNoLongerNeeded(model)

        return taxiPed
    end
end

function CreateTaxi(x, y, z)
    local taxiModel = CodeStudio.Taxi
    if IsModelValid(taxiModel) and IsThisModelACar(taxiModel) then
        RequestModel(taxiModel)
        while not HasModelLoaded(taxiModel) do Wait(1) end

        taxiVeh = CreateVehicle(taxiModel, x, y, z, CodeStudio.TaxiSpawn.w, true, false)
        SetVehicleNumberPlateText(taxiVeh, CodeStudio.TaxiPlate)
        SetEntityAsMissionEntity(taxiVeh, true, true)
        SetVehicleEngineOn(taxiVeh, true, true, false)

        if CodeStudio.TaxiModded then
            SetVehicleColours(taxiVeh, 0, 88)
            SetVehicleModKit(taxiVeh, 0)
            SetVehicleMod(taxiVeh, 10, 1, 0)
        end

        SetVehicleOnGroundProperly(taxiVeh)
        local taxiPed = createTaxiPed(taxiVeh)
        local blip = AddBlipForEntity(taxiVeh)
        SetBlipSprite(blip, 198)
        SetBlipFlashes(blip, true)
        SetBlipFlashTimer(blip, 5000)
        SetHornEnabled(taxiVeh, true)
        StartVehicleHorn(taxiVeh, 1000, GetHashKey("NORMAL"), false)
        SetPedIntoVehicle(PlayerPedId(), taxiVeh, 2)

        -- YOU CAN ADD YOUR FUEL EVENT HERE FOR EXAMPLE: 
        --exports['cdn-fuel']:SetFuel(taxiVeh, 100)
        -- exports['LegacyFuel']:SetFuel(taxiVeh, 100)

        if IsPedInVehicle(PlayerPedId(), taxiVeh, 1) then
            DoScreenFadeIn(250)
            Notify(CodeStudio.WelcomeMessage)
            SetVehicleDoorsLocked(taxiVeh, 4)
            TaskVehicleDriveToCoord(taxiPed, taxiVeh, CodeStudio.TaxiDestination.x, CodeStudio.TaxiDestination.y, CodeStudio.TaxiDestination.z, 200.0, 0, GetEntityModel(taxiVeh), 786859, true)
            SetPedKeepTask(taxiPed, true)

            Active = true
            isTaxi = true
            TaxiRunning(taxiPed)
        end
    end
end

function TaxiRunning(taxiPed)
    local sleep = 200
    while Active do
        local dist = #(GetEntityCoords(PlayerPedId()) - vector3(CodeStudio.TaxiDestination.x, CodeStudio.TaxiDestination.y, CodeStudio.TaxiDestination.z))
        if dist <= 10 then
            local player = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(player, false)

            for i = 19, 6, -4 do
                SetVehicleForwardSpeed(vehicle, i)
                Wait(200)
            end
            SetVehicleForwardSpeed(vehicle, 0.0)

            Notify(CodeStudio.ReachedMessage)
            SetVehicleDoorsLocked(vehicle, 1)

            TaskLeaveVehicle(player, vehicle, 0)
            Wait(2500)
            DeleteTaxi(vehicle, taxiPed)

            Active = false
            isTaxi = false
        end

        if isTaxi then
            sleep = 3
            DisplayHelpText('Press ~INPUT_FRONTEND_RRIGHT~ Skip Drive')

            if IsControlJustPressed(1, 194) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                isTaxi = false
                sleep = 200
                DoScreenFadeOut(2500)
                Wait(3000)
                SetEntityCoords(vehicle, vector3(CodeStudio.SkipToNearestLoc.x, CodeStudio.SkipToNearestLoc.y, CodeStudio.SkipToNearestLoc.z))
                SetEntityHeading(vehicle, CodeStudio.SkipToNearestLoc.w)
                DoScreenFadeIn(250)
            end
        end
        Wait(sleep)
    end
end


function DeleteTaxi(vehicle, driver)
    if DoesEntityExist(vehicle) and DoesEntityExist(driver) then
        if IsPedInVehicle(PlayerPedId(), vehicle, false) then
            TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
            Wait(2000)
        end

        TaskVehicleDriveWander(driver, vehicle, 60.0, 786859)
        local blip = GetBlipFromEntity(vehicle)
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end

        SetEntityAsNoLongerNeeded(vehicle)
        SetPedAsNoLongerNeeded(driver)

        Wait(5000)

        if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
        if DoesEntityExist(driver) then DeleteEntity(driver) end
    end
end


-- Display help text function
function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


RegisterCommand('test_scene', function()
    TriggerEvent('cs:introCinematic:start')
end)
