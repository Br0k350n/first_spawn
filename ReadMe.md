# CodeStudio Intro Cutscene Start with AI Taxi | Standalone

⚠️ Since this is a free open-source script, we don't provide personal support due to time constraints. If you need personalized support, please consider using Tebex for assistance/support.

https://discord.gg/62jqEKz8Sb

1. Event to Trigger the cutscene
```lua
TriggerEvent('cs:introCinematic:start')
```

### It’s not a plug-and-play script. You’ll need to make it compatible with your server based on your needs, whether that’s integrating it with clothing, multicharacter, or a specific location. This script will work with any server

## Plane NPC outfit source
You can choose where non-player plane outfits come from:

- `CodeStudio.PlanePedOutfitSource = 'database'` (recommended with `rcore_clothing_current`)
- `CodeStudio.PlanePedOutfitSource = 'config'` (uses `CodeStudio.PlanePedOutfitPool`)

### Database mode (use outfits from your players)
In database mode, the script reads random rows from `rcore_clothing_current`, converts those outfits, and applies them to cutscene passengers.

Config:
```lua
CodeStudio.PlanePedOutfitSource = 'database'
CodeStudio.PlanePedDatabase = {
  table = 'rcore_clothing_current',
  limit = 128
}
```

Supported SQL resources:
- `oxmysql`
- `mysql-async`

If no SQL resource is running, it falls back to the config pool.


### Simple mode (disable advanced customization)
If you just want random NPC models (no freemode face/hair/overlay customization), disable advanced mode:

```lua
CodeStudio.AdvancedPlanePedCreation = false
CodeStudio.PlanePedModelPool = {
  `a_m_m_business_01`,
  `a_f_y_business_01`,
  `a_m_m_socenlat_01`
}
```

When disabled, passengers spawn from `PlanePedModelPool` only.

## Randomization
These are randomized each run for the plane NPCs (not the player), unless you disable them in `CodeStudio.PlanePedSettings.randomize`:
- race / headblend
- hair color
- blemishes
- eye color
- tattoos

## rcore_clothes integration
Optional export bridge:

```lua
CodeStudio.PlanePedSettings.rcore = {
  enabled = true,
  resource = 'rcore_clothes',
  export = 'setPedClothes'
}
```

The script calls:
```lua
exports[resource][export](ped, outfit)
```

If the outfit came from `rcore_clothing_current`, the raw decoded rcore payload is passed to the export.
