# CodeStudio Intro Cutscene Start with AI Taxi | Standalone

⚠️ Since this is a free open-source script, we don't provide personal support due to time constraints. If you need personalized support, please consider using Tebex for assistance/support.

https://discord.gg/62jqEKz8Sb

1. Event to Trigger the cutscene 
```lua 
TriggerEvent('cs:introCinematic:start')
```

### It’s not a plug-and-play script. You’ll need to make it compatible with your server based on your needs, whether that’s integrating it with clothing, multicharacter, or a specific location. This script will work with any server


## Plane NPC outfit pool (rcore_clothes ready)
You can now define a preset clothing pool for non-player peds used in the intro plane scene in `config.lua`:

- `CodeStudio.PlanePedOutfitPool`: list of outfits (model, hair, overlays, clothing components, props).
- `CodeStudio.PlanePedSettings.random`: controls ranges for truly randomized race, hair colors, blemishes, eye color, and tattoo collections.
- `CodeStudio.PlanePedSettings.useRcoreClothes`: set to `true` to trigger your rcore_clothes event after native application.
- `CodeStudio.PlanePedSettings.rcoreApplyEvent`: event name to trigger for rcore_clothes integration.

Each plane ped picks a random preset on every cutscene run, while random traits are regenerated each time.
