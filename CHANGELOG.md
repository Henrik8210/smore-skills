# Changelog

## v0.5.66

- Hidden `SmoreSkills` channel no longer steals `/1` General (or `/2` Trade / `/3` Local Defense). Join is temporary and not added to a chat window; send still uses the channel name. If we land on 1–3 (or an older join left us there), swap **by channel index** with General / Trade / Local Defense. The edit box leaves `[n. SmoreSkills]`.
- Host camp panel: faint gold hover on chips, sockets, dropdown bar, menu rows, and Pack up (weaker than the selected fill).
- CurseForge **beta** `v0.5.66-beta`.

## v0.5.65

- Indexed all **36** Forever camping objects from Wowhead (Mana Well through Fishing Hut). Faction Banner is two item IDs, one row. Cooking has no skill-20 slot object.
- Dropped placeholder names (fake Tier 2/3, fake 5/10 campfires, unnamed Engineering). Settings camping-object and profession rows use the same 16×16 icons as the host camp panel.
- Host socket (your slot) only lists camping objects this character has learned. Tanning is the Skinning place-skill, not an object; guest sockets can still mark what someone else placed.
- Open sockets pulse the faded S'more icon (inside the ring). Filling a slot stops it. Camping-objects dropdown sits on the left under Looking for.
- CurseForge **beta** `v0.5.65-beta`.

## v0.5.64

- Host camp panel after you place a fire: sockets, profession request chips, camping-objects dropdown, Pack up. Chips start from Host settings (defaults); this fire can differ. Pin tooltip follows the camp.
- Leatherworking Tier 1 is **Camp Tent** (Light Leather ×5, +5% of a level Rest XP). Trainer recipes are **Name (Tier I)**.
- Object icons copy the open trainer row and `C_Spell`. Sharpening Wheel is the gold bar; Faction Banner is **your** faction; Enchanted Lute is not the flute. Camp Tent sack stand-in is still wrong.
- Forever-first: Anniversary is two-client share only. CurseForge **beta** `v0.5.64-beta`.

## v0.5.63

- Host camp panel after you place a fire: three sockets (click yours for profession or a camping object), profession request chips, and a **camping objects** dropdown grouped by trade. Pack up from the panel. Chips start from Host settings (now labeled as defaults); changing them is this camp only. Pin tooltip follows. Filters say **camping objects**.
- Sockets and object lists use **Forever trainer/spell art** (`C_Spell` / trainer scan). Sharpening Wheel is the gold-bar icon; Faction Banner is **your** faction (Horde vs Alliance); Enchanted Lute uses the live lute texture. Leatherworking Tier 1 is **Camp Tent** (+5% rest XP, Light Leather ×5).

## v0.5.62

- Forever first-night notes (Zephras, kit vs craft, 100-yard rule, Campfire Nearby, camping-item table, Mainline taint). CurseForge release for **WoW Forever 1.60.1**.

## v0.5.61

- Camping-item settings tooltips follow the cursor. Alchemy **Mana Well** (+10 mana / 5s, exclusive with Blessing of Wisdom).

## v0.5.60

- First Aid camping item is **First Aid Kit** (+3 Stamina). Forever: do not send addon or chat from timers, combat log, or login (that was still popping the blocked-action dialog). Share only on Find or `/smores host`.

## v0.5.59

- Do not join the hidden channel on login or zoning (Forever treats `JoinPermanentChannel` as Blizzard-only). Join on Find or `/smores host`. Load line says place a **Basic Campfire Kit**.

## v0.5.58

- Skinning camping item is **Camp Chair** (+2% crit). **Tanning** is the skill that lets you place features, not a filter object. Added **Enchanted Lute** and live **Incense Candle**. Hover a camping item in Host/Seeker settings for reagents, use, and exclusive-with.

## v0.5.57

- Auto-host no longer joins the hidden channel from the campfire timer. Forever blocks that as a Blizzard-only UI action. Local pin still appears; click Find or `/smores host` to join and share.

## v0.5.56

- Host/seeker filters say **Camping items**. Live trainer objects: Mining **Lodestone** (+12 melee AP), Blacksmithing **Sharpening Wheel** (+6 Strength), Tailoring **Faction Banner** (+14 Spirit).

## v0.5.55

- Zephras-style maps typed **Continent** still show camp pins (leaf island under World). Kalimdor / EK overview stay empty.
- Auto-host learns the **Basic Campfire Kit** use spell from the item in bags, and watches combat-log create/success, so Using a kit can pin even when it is not Cooking 818. Failed place inside **100 yards** of another fire does not host.

## v0.5.54

- Cooking **Create** of Basic Campfire Kit never hosts (profession cast is tracked even if the window closes mid-craft). **Use** the kit in the world to pin.

## v0.5.53

- Skinning’s first camp object is live **Tanning** (not a Leatherworking rack). Blizzard’s only nearby cue is the **Campfire Nearby** buff — no coords; we still do not read auras for location.

## v0.5.52

- Forever **Basic Campfire Kit** is crafted, then **Used** to place the fire. Auto-host ignores campfire spells while the profession window is open so cooking the kit does not pin the trainer.

## v0.5.51

- Auto-host treats any player spell whose name contains **campfire** as a placed fire (Forever **Welcoming Campfire**, not only Cooking 818). Sitting at a fire still does not host. Click Find or `/smores host` for the channel `H:`.

## v0.5.50

- Forever map init no longer HookScripts `OnClick` on the maximize/minimize **Frame** (that error aborted init and hid the minimap button). Hook the child buttons, and skip script types the widget does not support.
- Profession scan uses retail `GetProfessions` on Forever, with Classic skill lines as fallback.

## v0.5.49

- Settings sidebar credits are back under the three icons: Created by Weber8210 / Tested by Stik.
- CurseForge beta targets **WoW Forever 1.60.1** (previous file was TBC 2.5.x from Interface 20505).

## v0.5.48

- Campfire / Find-reply no longer `SendChatMessage` from a timer (that was *Interface action failed*, and `H:` never left). Click **Find** or `/smores host` once to put the pin on the channel. Find is not blocked by the 8 s send cooldown.
- Two-client Elwynn test **passed** (16 Sep 2026). First CurseForge file is **beta** (`v0.5.48-beta`).

## v0.5.47

- Lighting a new campfire packs the previous pin (`X:`) and hosts the new site. Walking away still keeps the old fire coords.
- Pin TTL is **10 minutes from when that fire was lit** for everyone — Find at minute 7 leaves 3 minutes, not a new 10.

## v0.5.46

- QA before retest: Elwynn pins no longer project onto Duskwood via map translate or “player is in Elwynn”; nested city maps still work. Find replies / campfire still send hidden-channel chat.
- Two-client retest is **16 Sep 2026** (documented in CAMPING.md). No CurseForge tag.

## v0.5.45

- Find replies and campfire host send hidden-channel chat again (0.5.34 had stopped that when it dropped addon-whisper). Zoom to the zone map; continent view has no pins. Duskwood no longer gets a copy of an Elwynn pin.

## v0.5.34

- Hosts answering Find no longer addon-whisper when the community channel is joined. That whisper was printing **Unable to whisper … Blizzard services may be unavailable** on TBC Anniversary.

## v0.5.33

- If a host ping would exceed 250 bytes, shrink it (item list, then object names, then shorten the name) and still send the pin. Revisit if Forever names + item lists clip tooltip data.
- `/smores prof` lasts until reload only (testing). Matching uses this character's learned trades after logout.

## v0.5.32

- Camp pin lasts **10 minutes from when the fire was lit**. Host heartbeats no longer keep the pin up past that.
- Other players' camp markers appear only after you click **Find** (your own hosted pin is still local).
- Pins already found still respect profession / layer / seeker filters (turning a filter off later hides them).
- Camp tooltip height grows with wrapped "host wants" lines.
- Removed the Ashenvale sample test camp (`/smores test`).

## v0.5.31

- Do not nag “zoom the map to that zone” for your own camp, or unless you are seeking.

## v0.5.30

- **Include camps on other layers** is on by default.

## v0.5.29

- Camp pin hover shows a yellow **Left-click to whisper the host for an invite.** line (own pin still says right-click to pack up).

## v0.5.28

- Settings: **Include camps on other layers**. Off (default) = Find/Host only match your layer. On = show and answer other layers too.
- Zoning into a new zone scans nameplates (like Nova) and prints your layer in chat when known — no target required if nameplates are on.

## v0.5.27

- Hosts do not see the green **G** on their own camp pin (it still shows for other players when a guildie is there).

## v0.5.26

- Seeker tooltip also shows the layer number: **Layer N — same as you** (N is the host's number, so it matches **Layer N — Your camp**).

## v0.5.25

- Seeker pin drop after hearing a host: do not treat the layer id as a timestamp (that made the camp look expired/packed). A live `H:` unpacks a previously packed camp. Chat says the real hide reason.

## v0.5.24

- Own camp tooltip is **Layer N — Your camp** so you can see which layer you are hosting on.

## v0.5.23

- Own camp tooltip says **Your camp** (not "same as you").
- Other camps say **Same layer as you** or **Different layer**. Local Layer 1/2/3 numbers are gone — they cannot match between players (or Nova) without a shared layer table.

## v0.5.22

- Layer stays in the pin tooltip only (no number on the fire).
- Tooltip shows Layer 1, 2, 3… from unique shard ids in that zone. The GUID field is a large id (e.g. 15654), not the layer count.

## v0.5.21

- Host's own campfire pin now shows the layer id on the fire (outlined number). Your pin is local, so it no longer waits for a seeker ping.
- If the layer is still unknown, the pin shows `?` until you target/mouseover a nearby NPC (or a nameplate appears).

## v0.5.20

- Layer is detected in this addon from nearby NPC GUIDs (no Nova World Buffs). Pin is green if you are on the host's layer, orange if not.

## v0.5.19

- Camp pins show the host's layer (from NPC GUIDs in this addon). Green if you are on that layer, orange if not.
- Left-click a pin to whisper the host for an invite.

## v0.5.18

- Fullscreen and windowed map: camp pin art draws above the map tiles (hover already worked; the fire icon was underneath).

## v0.5.17

- Find button sits on the visible map window (ElvUI / Leatrix zoom and shrink no longer leave it on the screen corner).
- Fullscreen Blizzard map: pins and Find stay with the map (match map strata, relayout on maximize).

## v0.5.16

- Camp pins only draw on the zone map (and nested city maps). They hide when zoomed out to continent, world, or Outland.

## v0.5.15

- Host/seeker match is any shared profession. Extra trades on the seeker are fine (Engineering+Mining vs Engineering+Mining+Cooking+First Aid).
- Resume Find after clearing pins re-discovers camps already heard in this zone.

## v0.5.14

- Stop calling `ChatFrame_RemoveChannel` and `SendChatMessage` from campfire auto-host (that is the "Interface action failed" taint).
- Auto-host waits on a frame created at login, then sends addon CHANNEL + whisper-on-seek only.
- Channel chat is used only from a click or slash (Find / Host / pack).

## v0.5.13

- Host answers a seek with an addon whisper of `H:` (Classic blocks channel chat from a chat event, so the seeker never got the camp).
- Channel chat fallback is sent on the next frame, not from the `CHAT_MSG_*` handler.
- If a host ping arrives but does not match, always say so (not only when map ids are identical).

## v0.5.12

- General settings: camp pin size, show/lock minimap button, chat messages, guild mark on pins.
- Chat toggle mutes automatic addon messages (seek/host/found). `/smores` still replies.
- Settings close button is clickable on the whole X (header no longer steals the click).
- Drop `/smores here` and the Share button. Sharing a fire is `/smores host` (or Auto host on campfire).
- World map pins are **hosts only**. Seekers do not appear on the map.
- One camp at a time: wait for the 10 min expiry, or pack up from the map pin or `/smores pack`.
- `/smores list` matches the map: hosted camps you can see, max 12 per zone.
- `/smores pack` uses the same Yes/No confirm as right-clicking your map pin.
- Do not strip the hidden channel from chat on every host ping (that could taint Blizzard UI).

## v0.5.11

- Camp pin lasts **10 minutes** (was 5) so two-client tests have more time.

## v0.5.10

- Settings window is larger and centered on screen (not stuck to the minimap icon). Host/Seeker filters can also pick up to 3 profession items.
- Host `H:` want field may include items (`bs,lw/bs1,bs2`) without extra colon fields.

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
