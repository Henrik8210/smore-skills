# Forever camping (what we know)

A player campfire becomes a **campsite**. Same-faction players sit at the fire. Buffs come from **placed objects**, not from “this camp is Tailoring.”

## Rules (BlizzCon / panel)

- A basic campfire allows **up to three** special crafted objects.
- Each player can place **one** object.
- Each tradeskill has its own objects (unique buff or utility).
- First objects at **20 skill**. Better ones come from **blueprint** recipes.
- Camping features share a **1 hour** cooldown.
- Objects require a **campfire / campsite nearby**.
- Buffs are variants of, and **exclusive with**, class buffs (Blessing of Might, Arcane Intellect, Strength of Earth, …).

## Blacksmithing (floor / quest)

From *Camping 101: Blacksmithing* (Sharpening Wheel as the quest reward):

| Object | Skill | Notes |
| --- | --- | --- |
| Sharpening Wheel | 20 | +4 Strength, exclusive with Strength of Earth Totem |
| Anvil | 160 | All Sharpening Wheel benefits; can replace the wheel |
| Master Forge | 300 | Usable for recipes that need it, plus wheel benefits; can replace the wheel |

## Other examples (panel)

| Profession | Object | Buff (example) |
| --- | --- | --- |
| Tailoring | Faction banner | Spirit |
| Herbalism | Incense candle | Intellect |

Cooking can teach a basic campfire (quest text). That is how you **start** a site, not a third-slot specialty.

## What this addon stores

Per camp: map, x/y, zone, faction, who shared it, **three slots** (profession + object name when we have it).

We cannot query every fire in Ashenvale. Someone at the fire (or `/smores here`) shares coordinates. Others merge the ping.

## Later

- Read a real campfire / object API in beta
- Fill slot from the object you just placed
- Map pins
- A public channel if guild-only is too small
- Occupancy of sitters vs the three object slots (different numbers)
