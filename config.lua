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

CodeStudio.PlanePedOutfitSource = 'config' -- Legacy option kept for compatibility; plane passengers now use pre-made ped models only.

CodeStudio.PlanePedDatabase = {
    table = 'rcore_clothing_current',
    limit = 128
}


CodeStudio.AdvancedPlanePedCreation = false -- Plane passengers use simple pre-made ped models (no freemode customization).
CodeStudio.PlanePedModelPool = {
    `a_m_m_business_01`,
    `a_m_m_bevhills_01`,
    `a_m_y_business_01`,
    `a_f_m_business_02`,
    `a_f_y_business_01`,
    `a_f_y_bevhills_01`,
    `a_m_m_socenlat_01`
}

function Notify(msg)
    -- SetNotificationTextEntry('STRING') --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    -- AddTextComponentString(msg)  --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    -- DrawNotification(0,1)  --- DELETE ME IF YOU ARE USING ANOTHER SYSTEM
    TriggerEvent("QBCore:Notify", msg)
end
