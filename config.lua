CodeStudio = {}


CodeStudio.useTaxi = true          --Use AI Taxi or Not?
CodeStudio.SpawnPedLoc = vector3(-1044.91, -2750.2, 21.36)    --If not using AI Taxi then set player spawn location 

CodeStudio.Taxi = `dynasty`                                     --Taxi Model
CodeStudio.TaxiPlate = 'CS5M'                              --Taxi Number Plate
CodeStudio.TaxiModded = true
CodeStudio.TaxiSpawn = vector4(-1058.48, -2713.28, 20.17, 240.05)       --Taxi First Spawn Location   
CodeStudio.TaxiDestination = vector4(-1087.01, -271.25, 37.32, 26.0)         --Taxi Destination Lcoation 
CodeStudio.SkipToNearestLoc = vector4(-1198.92, -304.74, 37.47, 284.08)       --Taxi Skip Nearest Location to destination


CodeStudio.WelcomeMessage = 'Welocome To My Server'
CodeStudio.ReachedMessage = "We've reached our destination"

--[[
    Plane ped clothing pool
    - Every cutscene passenger picks one entry at random.
    - Model defaults to freemode peds so they can be fully customized.
    - Set `useRcoreClothes` to true if you want to call an rcore_clothes export after native application.
      Update `rcoreApplyEvent` to the event your server uses if needed.
]]
CodeStudio.PlanePedSettings = {
    useRcoreClothes = false,
    rcoreApplyEvent = 'rcore_clothes:applyOutfitToPed',

    random = {
        raceShape = { min = 0, max = 45 },
        raceSkin = { min = 0, max = 45 },
        hairColorPrimary = { min = 0, max = 63 },
        hairColorSecondary = { min = 0, max = 63 },
        blemishesStyle = { min = 0, max = 23 },
        blemishesOpacity = { min = 20, max = 90 },
        eyeColor = { min = 0, max = 31 },
        tattooCollection = {
            'mpbusiness_overlays',
            'mphipster_overlays',
            'mpbeach_overlays',
            'mpbiker_overlays'
        }
    }
}

CodeStudio.PlanePedOutfitPool = {
    {
        model = `mp_m_freemode_01`,
        hair = { style = 9 },
        overlays = {
            beard = { style = 8, opacity = 60, color = 2, secondColor = 0 },
            eyebrows = { style = 7, opacity = 80, color = 1, secondColor = 0 }
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
        hair = { style = 5 },
        overlays = {
            makeup = { style = 9, opacity = 50, color = 5, secondColor = 0 },
            eyebrows = { style = 6, opacity = 85, color = 3, secondColor = 0 }
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
        hair = { style = 1 },
        overlays = {
            beard = { style = 2, opacity = 55, color = 1, secondColor = 0 },
            chestHair = { style = 3, opacity = 70, color = 1, secondColor = 0 }
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
    SetNotificationTextEntry('STRING') --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    AddTextComponentString(msg)  --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    DrawNotification(0,1)  --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
end
