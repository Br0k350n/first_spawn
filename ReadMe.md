# CodeStudio Intro Cutscene Start with AI Taxi | Standalone

⚠️ Since this is a free open-source script, we don't provide personal support due to time constraints. If you need personalized support, please consider using Tebex for assistance/support.

https://discord.gg/62jqEKz8Sb

1. Event to Trigger the cutscene
```lua
TriggerEvent('cs:introCinematic:start')
```

### It’s not a plug-and-play script. You’ll need to make it compatible with your server based on your needs, whether that’s integrating it with clothing, multicharacter, or a specific location. This script will work with any server

## Plane NPC outfit pool (rcore_clothes ready)
You can define a preset outfit pool for non-player peds used in the intro plane scene in `config.lua`:

- `CodeStudio.PlanePedOutfitPool`:
  - `model`
  - `blend` (optional manual race blend if race randomization is disabled)
  - `hair`
  - `overlays`
  - `faceFeatures`
  - `components` and `props`
- `CodeStudio.PlanePedSettings.randomize` toggles true random traits:
  - race
  - hair color
  - blemishes
  - eye color
  - tattoos
- `CodeStudio.PlanePedSettings.random` sets min/max ranges used by randomization.
- `CodeStudio.PlanePedSettings.tattooPool` is used for random tattoo picks.

Each plane ped picks a random outfit preset each cutscene run, and random traits are regenerated every run.

## rcore_clothes integration
`CodeStudio.PlanePedSettings.rcore` is an optional export bridge:

```lua
CodeStudio.PlanePedSettings.rcore = {
  enabled = true,
  resource = 'rcore_clothes',
  export = 'YOUR_EXPORT_NAME'
}
```

When enabled, the script calls:

```lua
exports[resource][export](ped, outfit)
```

Set `export` to the exact function name from your `rcore_clothes` API docs/version.
