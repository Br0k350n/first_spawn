CodeStudio = {}

CodeStudio.useTaxi = true          --Use AI Taxi or Not?
CodeStudio.SpawnPedLoc = vector3(-1044.91, -2750.2, 21.36)    --If not using AI Taxi then set player spawn location

CodeStudio.Taxi = `dynasty`                                     --Taxi Model
CodeStudio.TaxiPlate = 'CS5M'                                   --Taxi Number Plate
CodeStudio.TaxiModded = true
CodeStudio.TaxiSpawn = vector4(-1058.48, -2713.28, 20.17, 240.05)       --Taxi First Spawn Location
CodeStudio.TaxiDestination = vector4(-1087.01, -271.25, 37.32, 26.0)    --Taxi Destination Location
CodeStudio.SkipToNearestLoc = vector4(-1198.92, -304.74, 37.47, 284.08) --Taxi Skip Nearest Location to destination

CodeStudio.WelcomeMessage = 'Welocome To Endless Dreams!'
CodeStudio.ReachedMessage = "We've reached our destination"

CodeStudio.PlanePedOutfitSource = 'database' -- 'database' (rcore_clothing_current) or 'config'

CodeStudio.PlanePedDatabase = {
    table = 'rcore_clothing_current',
    limit = 128
}


CodeStudio.AdvancedPlanePedCreation = true -- false = use simple ped model pool without freemode customization
CodeStudio.PlanePedModelPool = {
    `a_m_m_business_01`,
    `a_m_m_bevhills_01`,
    `a_m_y_business_01`,
    `a_f_m_business_02`,
    `a_f_y_business_01`,
    `a_f_y_bevhills_01`,
    `a_m_m_socenlat_01`
}

--[[
    Plane NPC outfit/randomization config (non-player plane peds only).

    Outfit schema:
    {
      model = `mp_m_freemode_01` or `mp_f_freemode_01`,
      blend = { shapeFirst = 0, shapeSecond = 21, skinFirst = 0, skinSecond = 21, shapeMix = 0.5, skinMix = 0.5 },
      hair = { style = 9, texture = 0 },
      overlays = {
        beard = { style = 8, opacity = 60, colorType = 1, color = 2, secondColor = 0 },
        eyebrows = { style = 7, opacity = 80, colorType = 1, color = 1, secondColor = 0 }
      },
      faceFeatures = { [0] = 0.1, [1] = -0.2 }, -- Native face features index/value (-1.0 to 1.0)
      components = { { component = 3, drawable = 1, texture = 0 } },
      props = { { prop = 0, drawable = -1, texture = 0 } }
    }

    Randomized every run (unless disabled): race blend ids, hair color, blemishes, eye color, tattoos.
]]
CodeStudio.PlanePedSettings = {
    randomize = {
        race = true,
        hairColor = true,
        blemishes = true,
        eyeColor = true,
        tattoos = true
    },

    random = {
        raceShape = { min = 0, max = 45 },
        raceSkin = { min = 0, max = 45 },
        blendShapeMix = { min = 35, max = 100 },
        blendSkinMix = { min = 35, max = 100 },
        hairColorPrimary = { min = 0, max = 63 },
        hairColorSecondary = { min = 0, max = 63 },
        blemishesStyle = { min = 0, max = 23 },
        blemishesOpacity = { min = 20, max = 90 },
        eyeColor = { min = 0, max = 31 }
    },

    -- Optional rcore_clothes export bridge.
    -- Enable only if you have a matching export in your rcore_clothes version.
    rcore = {
        enabled = false,
        resource = 'rcore_clothes',
        export = 'setPedClothes' -- Change to your exact export name if your rcore_clothes version differs.
    },

    -- Truly random tattoo pools: one random item from each body part has tattooChance roll.
    -- Add/remove entries freely to match your clothing packs.
    tattooChance = 35,
    tattooPool = {
        { collection = 'mpbusiness_overlays', name = 'MP_Buis_M_Neck_000' },
        { collection = 'mpbusiness_overlays', name = 'MP_Buis_M_Chest_000' },
        { collection = 'mphipster_overlays', name = 'FM_Hip_M_Tat_000' },
        { collection = 'mphipster_overlays', name = 'FM_Hip_M_Tat_003' },
        { collection = 'mpbeach_overlays', name = 'MP_Bea_M_Back_000' },
        { collection = 'mpbeach_overlays', name = 'MP_Bea_F_Back_001' },
        { collection = 'mpbiker_overlays', name = 'MP_MP_Biker_Tat_000_M' },
        { collection = 'mpbiker_overlays', name = 'MP_MP_Biker_Tat_000_F' }
    }
}

CodeStudio.PlanePedOutfitPool = {
    {
        model = `mp_m_freemode_01`,
        hair = { style = 9, texture = 0 },
        overlays = {
            beard = { style = 8, opacity = 60, colorType = 1, color = 2, secondColor = 0 },
            eyebrows = { style = 7, opacity = 80, colorType = 1, color = 1, secondColor = 0 }
        },
        components = {
            { component = 3, drawable = 1, texture = 0 },
            { component = 4, drawable = 9, texture = 0 },
            { component = 6, drawable = 4, texture = 0 },
            { component = 8, drawable = 15, texture = 0 },
            { component = 11, drawable = 10, texture = 0 }
        },
        props = {
            { prop = 0, drawable = -1, texture = 0 }
        }
    },
    {
        model = `mp_f_freemode_01`,
        hair = { style = 5, texture = 0 },
        overlays = {
            makeup = { style = 9, opacity = 50, colorType = 2, color = 5, secondColor = 0 },
            eyebrows = { style = 6, opacity = 85, colorType = 1, color = 3, secondColor = 0 }
        },
        components = {
            { component = 3, drawable = 15, texture = 0 },
            { component = 4, drawable = 2, texture = 0 },
            { component = 6, drawable = 4, texture = 0 },
            { component = 8, drawable = 3, texture = 0 },
            { component = 11, drawable = 4, texture = 0 }
        },
        props = {
            { prop = 1, drawable = -1, texture = 0 }
        }
    },
    {
        model = `mp_m_freemode_01`,
        hair = { style = 1, texture = 0 },
        overlays = {
            beard = { style = 2, opacity = 55, colorType = 1, color = 1, secondColor = 0 },
            chestHair = { style = 3, opacity = 70, colorType = 1, color = 1, secondColor = 0 }
        },
        components = {
            { component = 3, drawable = 3, texture = 0 },
            { component = 4, drawable = 5, texture = 0 },
            { component = 6, drawable = 2, texture = 0 },
            { component = 8, drawable = 2, texture = 0 },
            { component = 11, drawable = 3, texture = 0 }
        },
        props = {
            { prop = 6, drawable = -1, texture = 0 }
        }
    }
}

function Notify(msg)
    -- SetNotificationTextEntry('STRING') --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    -- AddTextComponentString(msg)  --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    -- DrawNotification(0,1)  --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    TriggerEvent("QBCore:Notify", msg)
end
