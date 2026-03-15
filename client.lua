local taxiVeh
local isTaxi = false
local Active = false

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

local function randomInRange(range, fallbackMin, fallbackMax)
    local min = range and range.min or fallbackMin
    local max = range and range.max or fallbackMax
    return math.random(min, max)
end

local function applyOverlay(ped, overlayName, overlayData, randomCfg)
    local overlayId = overlayIndexMap[overlayName]
    if not overlayId then return end

    local style = overlayData.style or 0
    local opacity = (overlayData.opacity or 100) / 100.0

    if overlayName == 'blemishes' then
        style = randomInRange(randomCfg.blemishesStyle, 0, 23)
        opacity = randomInRange(randomCfg.blemishesOpacity, 20, 90) / 100.0
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

local function applyRandomizedPedAppearance(ped, outfit)
    local settings = CodeStudio.PlanePedSettings or {}
    local randomCfg = settings.random or {}

    local raceShape = randomInRange(randomCfg.raceShape, 0, 45)
    local raceSkin = randomInRange(randomCfg.raceSkin, 0, 45)
    local shapeMix = math.random(35, 100) / 100.0
    local skinMix = math.random(35, 100) / 100.0

    SetPedHeadBlendData(
        ped,
        raceShape,
        raceShape,
        0,
        raceSkin,
        raceSkin,
        0,
        shapeMix,
        skinMix,
        0.0,
        false
    )

    local hairData = outfit.hair or {}
    local hairStyle = hairData.style or 0
    local hairPrimary = randomInRange(randomCfg.hairColorPrimary, 0, 63)
    local hairSecondary = randomInRange(randomCfg.hairColorSecondary, 0, 63)
    SetPedComponentVariation(ped, 2, hairStyle, hairData.texture or 0, 0)
    SetPedHairColor(ped, hairPrimary, hairSecondary)

    local eyeColor = randomInRange(randomCfg.eyeColor, 0, 31)
    SetPedEyeColor(ped, eyeColor)

    applyOverlay(ped, 'blemishes', {}, randomCfg)
    for overlayName, overlayData in pairs(outfit.overlays or {}) do
        applyOverlay(ped, overlayName, overlayData, randomCfg)
    end

    if #(randomCfg.tattooCollection or {}) > 0 then
        ClearPedDecorations(ped)
        local tattooCollection = randomCfg.tattooCollection[math.random(1, #randomCfg.tattooCollection)]
        AddPedDecorationFromHashes(ped, GetHashKey(tattooCollection), 0)
    end

    applyComponents(ped, outfit.components)
    applyProps(ped, outfit.props)

    if settings.useRcoreClothes and settings.rcoreApplyEvent then
        TriggerEvent(settings.rcoreApplyEvent, ped, outfit)
    end
end

local function getRandomPlanePedOutfit()
    local pool = CodeStudio.PlanePedOutfitPool or {}
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

    local ped = {}
    for i = 0, 6 do
        local outfit = getRandomPlanePedOutfit()
        local model = outfit.model or `mp_m_freemode_01`

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        ped[i] = CreatePed(26, model, -1117.7778, -1557.6249, 3.3819, 0.0, false, false)
        SetEntityAsMissionEntity(ped[i], true, true)
        applyRandomizedPedAppearance(ped[i], outfit)
        RegisterEntityForCutscene(ped[i], sub_b0b5[i], 0, 0, 64)
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