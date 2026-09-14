# Changelog

## v0.5.9

- Draw camp pins at zone coords when WoW reports a nested city map (Elwynn canvas titled Stormwind City).
- Find switches the world map to your zone; chat hint if you are viewing a different map.
- Empty tooltip sockets use a faded greyscale S'more instead of a hollow circle.

## v0.5.8

- Keep hosting the **fire's original coords** if you step away (do not look up the camp at your current feet).
- Match a seeker on any of their learned professions, not only the first skill-list trade.
- Reply to Find even during the 8 s send cooldown; retry joining the hidden channel.
- Pack-up: right-click own pin, confirm, send `X:` so seekers drop it now. Find right-click no longer packs your own fire.
- Chat tells you when a camp was heard but filtered. `/smores status` shows channel/host/seek/map view.

## v0.5.7

Release candidate for Forever beta — **GitHub only** (no CurseForge tag until beta validates).

- Replace logo with Forever-style S'MORE SKILLS artwork; cropped icon for minimap/map buttons.
- Map pins, custom camp tooltip (gold-ring sockets), settings popup, minimap seek/settings — see v0.4.x–0.5.6 entries below.

## v0.5.6

- Custom logo: three s'mores over a bonfire (top-down WoW style); used for addon, minimap, and map icons.

## v0.5.5

- Revert camp tooltip sockets to circular gold-ring style (drop portrait frame textures).

## v0.5.4

- Camp tooltip sockets use unit-frame portrait ring + SetPortraitToTexture for profession icons.

## v0.5.3

- Fix chat prefix showing raw |cffff00 color escape.

## v0.5.2

- Minimap fire icon pulses while seeking (same fade as world map find button).

## v0.5.1

- Fix yellow title color codes showing literal "00" prefix.

## v0.5.0

- Settings: renamed title, yellow headers, General simplified, Host/Seeker prof grids fixed (no scrollbars).
- Camp tooltip: circular gold-ring sockets, settings-matching dialog background.

## v0.4.9

- Fix custom camp tooltip (TBC-safe socket colors); no silent rollback to text-only GameTooltip.

## v0.4.8

- Restore minimap button (independent init + retry); camp tooltip sockets use thin gold borders.

## v0.4.7

- Camp tooltip sockets 20% smaller; settings panel solid Forever-style dialog background.

## v0.4.6

- Fix camp map hover tooltip (TBC-safe APIs, parent to world map, GameTooltip fallback).

## v0.4.5

- Settings popup: opaque panel, sidebar icons seated inside tracking rings, inactive tabs faded.
- Camp map tooltip: three ring sockets (2× pin size) show filled professions; seek opens world map.

## v0.4.4

- Minimap settings popup restyled (Forever Legacy Tree–inspired): dark panel, gold trim, sidebar tabs.

## v0.4.3

- Detect all player professions; map TBC specs (Spellfire Tailoring, etc.) to base trades.
- Settings shows every detected profession; `/smores prof tail` picks which one you seek as.

## v0.4.2

- Removed camp list button; camps show on the world map only.
- Fixed settings checkbox labels (truncated “A / O / O” text).
- Minimap left-click finds camps; right-click opens settings.

## v0.4.1

- Settings popup anchors to the minimap button (GearQuest-style): left-click camp list, right-click settings, drag to move.

## v0.4.0

- Map pins show bonfire only; hover lists host + two open spots.
- Minimap button opens settings: auto-host toggle (Forever), host/seeker profession filters.
- Host and seeker filters gate which camps appear on the map and in the list.

## v0.3.12

- Camp pins scaled up 50%; sockets pushed outward with a small gap from the bonfire.

## v0.3.11

- Camp pins back to 100% base size; bonfire remains 50% larger than socket icons.

## v0.3.10

- Camp pins scaled to 200%; bonfire icon is 50% larger than trade-skill socket icons.

## v0.3.9

- Camp pins 3× larger; tracking ring uses Questie TOPLEFT layout (fixes ring offset).
- Map find button ring restored to Questie layout.

## v0.3.8

- Camp bonfire uses the same circular background + masked icon as sockets; pin anchor sits on the exact campsite coords.
- Map find button bonfire is circular and centered (matches camp pin style).

## v0.3.7

- Filled socket icons are circular; all three sockets sit at equal distance from the bonfire (triangle layout).
- Right-click the map find button to clear camp markers and stop seeking.

## v0.3.6

- Camp map pins show a larger bonfire with three profession sockets in a triangle (host on top, two guest slots below).

## v0.3.5

- World map pins for visible camps (fire icon on the zone map while browsing).
- Test camp uses per-character random coords in Ashenvale (stored in settings).

## v0.3.4

- Toggle seek off/on resumes listening without a new ping until the 3 min window ends; 45 s cooldown only applies to new signals.
- TBC test camp in Ashenvale when seeking (`/smores test off` to disable).

## v0.3.2

- Seeking map icon uses smooth fade in/out (no hard blink).
- Stopping seek keeps discovered camps in the list until they expire (30 min).

## v0.3.1

- Map find button pulses while actively searching (icon blink + soft glow).

## v0.3.0

- Map find button uses Questie/Krowi layout: minimap background, icon, tracking ring on ScrollContainer.

## v0.2.6

- Map find button parented to map border frame; icon masked circular under tracking ring.

## v0.2.4

- Map find button uses minimap tracker layout: fire icon centered inside the ring.

## v0.2.3

- Map button: fire icon centered inside tracking ring (TBC-safe texture).
- Click again while searching toggles seek off.
- Tooltip shows search time left or click cooldown countdown.

## v0.2.2

- Map find button: lower-right corner, visible in minimized and full-screen map.

## v0.2.1

- Bonfire button on the world map (top-right) — tooltip *Find campsites in this zone*, click runs seek.

## v0.2.0

- Seeker signal (`/smores find`, **Find camps** button): `S:` ping, 45 s cooldown, 3 min listen window.
- Host signal (`/smores host`, **Host camp** button): `H:` ping with want list, 90 s rebroadcast while hosting.
- Client-side matching: same zone, same faction, empty slot, want list (`/smores want any` or `bs,lw`).
- Manual slots for TBC testing: `/smores slot 1 bs Anvil`, `/smores prof lw`.
- UI shows seeking/hosting status, zone-filtered list, **H** marker for host pings.

## Unreleased

- Map bonfire button and socket pins (Forever beta).
- Auto-read placed camp objects from game API.

## v0.1.0

- Foundation for Forever camping: community-shared coordinates, three object slots, profession labels.
- Share location is opt-in (`/smores here`) to other S'more Skills users. No login dump.
- Optional guild mark when a guildie is on a camp.
- CurseForge upload is GitHub Actions on version tags. Create a new project before the first tag.
