# Changelog

## v0.6.9

Joining a dungeon group and walking up to party members no longer floods Lua errors.

Forever (Mainline secrets) treats `UnitExists` / `UnitIsPlayer` / `UnitGUID` on party tokens and player nameplates as secrets. Using those values in an `if` throws. The layer watch was doing that on every `NAME_PLATE_UNIT_ADDED` plus a 3-second ticker — so approaching the group in a dungeon meant a spam of errors.

- Layer detection is **open-world NPC GUIDs only**. Party, raid, and player nameplates are never read (they cannot carry a creature `zoneUID` anyway).
- The watch stays **off** in party / raid / arena / pvp. There are no camps there, and instance chat is locked down.
- Remaining unit and map-position reads stay inside `pcall` so a secret cannot leak into a boolean. `GetXY` is type-checked before use.
- Open-world layer from nearby NPCs is unchanged. Layer may stay unknown in a dungeon — that is expected.

## v0.6.8

- World-map **Find campsites** is visible again: it parents to the map window at pin overlay strata, not as a `ScrollContainer` child under the parchment. Minimap pin setup can no longer abort map init.

## v0.6.7

Beta since **v0.5.78**. Forever 1.60.1 (`_classic_beta_`).

### Host camp panel

- **Announce camp in General** sits bottom-right, opposite **Pack up**. That click is the **only** way `/1` is sent — not kit Use, not the fire landing, not Find, not `/smores host`, not a settings checkbox.
- Hover the button to preview the exact line (fire type, camping object or profession, coords, zone, who you want, minutes left, layer, and that you use S'more Skills).
- Example: `I am hosting a Basic campfire with "Camp Tent" now at 64.5, 48.9 in The Barrens. Looking for anyone. About 15 min left. Layer 2. I am using the S'more Skills addon to automatically broadcast this message.`

### Settings survive `/reload`

Forever often drops nested `SmoreSkillsDB.settings`. Every General / Host / Seeker option is now snapshotted to CVars (`SmoreSkillsSS` / `SmoreSkillsST`) plus flat account fields whenever you change it, and restored after `/reload`. That includes auto-host, chat, minimap show/lock/angle, guild mark, cross-layer, pin scale, host profession/object, both filters, and both want lists.

### Hosted fire across `/reload`

- Your pin stays until pack-up, a full fire, a **new** fire, or the live **15 minute** Forever clock (not 20). Same remaining time for every seeker.
- Ownership uses `hostCampId`, not `UnitName` (`Unknown`, `No Bunda` vs `No-Bunda`).
- Do not create an empty `SmoreSkillsDB` before SavedVariables apply (that makes Forever skip the file).
- Slot edits are snapshotted when you change them. Restore prefers the full `HPv1` blob, then `HPc2` (coords + item-id sockets). Heartbeat no longer stamps default profession over socket 1.
- When time runs out the pin packs **locally** (no `X:` from a timer). Denmark PC vs US realm (~9 h) is a clock jump, not burnout.

### Forever taint

- Kit Use no longer joins the hidden channel or posts `/1` in that same click — that was *Interface action failed because of an AddOn*.
- Lighting a kit writes a **local** pin. Seekers see it after **their** Find (`S:` → addon-whisper `H:`). Channel-chat `H:` on Find / `/smores host` is the backup.

### Host defaults

- Host settings include learned camping objects. A new fire uses that object on your socket. The General line names `"Camp Tent"` or, if you only picked a trade, `"Leatherworking"`.

### Older notes (this beta)

- v0.6.6 — announce moved from a setting to the camp-panel button.
- v0.6.3 — all settings persisted like announce used to be.
- v0.6.0–0.6.2 — announce text and the old checkbox persist (checkbox is gone).
- v0.5.99 — pin lifetime 15 minutes.
- v0.5.95–0.5.98 — persist / socket / pack-up-nil fixes.

## v0.6.6

- General announce is a camp-panel button (**Announce camp in General**, bottom right, opposite Pack up), not a settings checkbox. It only sends `/1` when you click it.

## v0.6.5

- General announce waits until the campfire is actually lit. Clicking the kit (or cancelling the place) does not send `/1`.

## v0.6.4

- General announce actually posts after you light a fire. Kit Use no longer joins the hidden channel in the same click (that was the *Interface action failed* toast), and a blocked send is retried when you click the camp panel or minimap button.

## v0.6.3

- General, Host, and Seeker settings all survive `/reload` the same way Announce in General does: a CVar snapshot plus flat account fields, written whenever any of those options change.

## v0.6.2

- Unchecking Announce in General survives `/reload`. The choice is stored in a CVar (`1`/`0`) so a missing settings table cannot turn it back on.

## v0.6.1

- Announce in General (/1) stays on after `/reload` (saved as a flat account field) and is **on by default**.

## v0.6.0

- General announce names your default socket: a camping object (`with "Camp Tent"`) or, if you only picked a profession, `with "Leatherworking"`.

## v0.5.101

- Host defaults include learned camping objects. A new fire uses that object on your socket, and the General announce names it (`with "Camp Tent"`).

## v0.5.100

- General camp announce uses the 15-minute fire clock and includes the host's layer when we know it.

## v0.5.99

- Campfire pin lifetime is **15 minutes** (the live Forever fire), not 20.

## v0.5.98

- Slot edits survive `/reload`: the CVar backup now stores sockets (`HPc2` item ids), restore does not rewrite SavedVariables with the default host profession, and the host heartbeat no longer stamps settings over your sockets. When the 20 minutes run out the pin is packed locally (no `X:` from a timer).

## v0.5.97

- Slot edits (host socket or other sockets) are snapshotted when you change them, not only on logout. `/reload` was restoring the camp as it looked when you first hosted because share-from-click never wrote the new sockets, and restore then stamped the default host profession back onto socket 1.

## v0.5.96

- Pack-up then `/reload` no longer errors when `SmoreSkillsDB` is still nil (`EnsureSettings` used a session table until SavedVariables apply). Restored host camps take your default host profession/socket again — the short CVar clock blob had coords but no slots.

## v0.5.95

- Host persist after `/reload`: the saved fire is still yours even when UnitName is `Unknown`, the CVar blob has no owner, or the name is `No Bunda` vs `No-Bunda`. We no longer create an empty `SmoreSkillsDB` that makes Forever skip the file on disk. Own-pin remaining counts down with `GetTime()` for the rest of the session so a jumped realm clock cannot hide the pin.

## v0.5.94

- Host persist: a dead leftover snapshot no longer blocks saving the current fire, and restore no longer gives up when remaining looks empty. Snapshot always writes this camp's countdown. `/smores status` no longer talks about channel #5 — H: to a seeker is a hidden addon whisper; the named `SmoreSkills` bus is only how we hear Find.

## v0.5.93

- General settings: announce-in-General is item 2, under Auto host. The pin-size slider sits below it (it had been laid out on top of that checkbox when Auto host hid the Host camp button).

## v0.5.92

- Persist no longer hides a live host pin because a stale `litAt` looks older than 20 minutes. Saved `remaining` wins when `litAt` would burn the camp. Login text says any Campfire Kit, not only Basic. `/smores status` labels the hidden channel and prints whether the HP blob is still there.

## v0.5.91

- General setting **Announce your camp in General chat (/1)** (off by default). When you host, sends a public line with fire type, coordinates, who you want, time left, and that you use S'more Skills. Sent from the kit Use or Host click so Forever does not block it.

## v0.5.90

- Host pin remaining counts down from when the fire was **lit**, not from the last `/reload`. The CVar backup was truncated and had no `litAt`, so restore stamped a fresh 20 minutes (19 min left after another reload). CVar/macro now store a short clock blob (`remaining` + `litAt`).

## v0.5.89

- Lighting a fire still hosts **locally** (your pin and camp panel). When a seeker clicks Find in that zone, the host automatically answers with `H:` (addon whisper to that player — the TBC two-client path). Channel chat `H:` from a click stays the backup if that reply is blocked.

## v0.5.88

- Host persist writes the camp to **five independent places**: account string `SmoreSkillsHP`, `SmoreSkillsDB.hp`, `settings.hp` (the settings table that already survives), a `SmoreSkillsHP` CVar, and a character macro `S~Camp`. Restore uses the first that comes back. Addon SavedVariables alone are no longer trusted on this client.

## v0.5.87

- Host persist no longer depends on nested `SmoreSkillsDB.camps` or a per-character table coming back after `/reload`. The camp is also saved as a single account string (`SmoreSkillsHP` / `SmoreSkillsDB.hp`). That global is never created empty on load (so a late SavedVariables apply can still fill it). Restore retries through `VARIABLES_LOADED` and the first few seconds.

## v0.5.86

- Persist uses **GetServerTime() only** in WTF (`remaining` + `server`) and for both world-map and minimap pins. `GetTime()` / PC `time()` are not part of the pin clock. A 9-hour Denmark/US gap is not subtracted.

## v0.5.85

- Owned camp TTL no longer uses `GetServerTime()` or `time()`. Those are 9 hours apart (US realm 2pm vs Denmark 11pm) and wiped the pin on `/reload`. Remaining now counts down with `GetTime()` (client uptime), which survives `/reload` and does not move with timezones.

## v0.5.84

- Host persist actually puts the fire back after `/reload` for Basic, Journeyman, and Expert (saved `fireType` + 3 / 5 / 10 sockets). Restore uses saved `remaining` only; a 9-hour Denmark/US gap is ignored. Chat names the fire type, the zone map is switched to the pin, and the host panel opens. `/smores persist` reprints that state.

## v0.5.83

- Host persist no longer treats the Denmark PC clock vs the US realm clock (~9 hours) as a burned-out fire. `/reload` counts down saved `remaining`, not `now - litAt`. A gap larger than 3 hours is a clock jump and keeps the pin.

## v0.5.82

- Host persist no longer dies after `/reload` when a session `GetTime()` check, a full fire, or a failed remaining write wiped the snapshot. Your pin, host panel, and remaining time come back from the flat account snapshot.
- Minimap campfire pins stay locked to the fire’s map position (east/north). Walking moves *you* on the disc; the pin no longer slides off in a wrong direction.

## v0.5.81

- Minimap pin refresh can no longer abort host restore or wipe a live fire. Snapshot remaining comes from the live `litAt` (realm clock), not a stale leftover; a `0` clock after `/reload` waits instead of treating the camp as burned out.

## v0.5.80

- Campfire pins show on the **minimap** when you are close enough for the fire to sit on the disc. Hover and click match the world map (tooltip, whisper, host panel, pack-up).
- Minimap pin no longer errors when reading the fire’s world Y (`cwy` was dropped by a Lua `and`).

## v0.5.79

- Host panel and pin tooltip grow with the fire: Basic stays three large sockets; Journeyman is five half-size (2+3); Expert is ten (5+5). Empty sockets still pulse. The socket grid is centered on the host panel.
- Auto host is any Campfire Kit (Basic, Journeyman, or Expert), not only Basic.
- `/smores host basic|journeyman|expert` (aliases `jm`, `exp`) stamps the fire type so we can test 5/10 without those kits. Bare `/smores host` still just re-shares. `H:` sends 3, 5, or 10 slot pairs (old clients still read the first three).

## v0.5.78

- A hosted pin more than 20 minutes old (realm time) no longer comes back after `/reload` as a fresh 20-minute camp. Saved `remaining` subtracts time since the snapshot clock; leftover snapshots are cleared when that hits 0.
- CurseForge **beta** `v0.5.78-beta`.

## v0.5.77

- After `/reload`, Forever often does not reload nested `camps` or the per-character host file into memory, even though they sit on disk. Restore now uses **flat account fields** (`hostCampId` + `hostSnapRemaining`, and `hostSnap_*` coords) so the pin comes back without reading `litAt` from the nested table.
- Kit **Use** hosts; Cooking **Create** does not. Pin TTL for your fire is seconds remaining + session `GetTime()`, not Denmark `time()` vs the US realm clock.
- How `/reload` keeps the pin: [HOST-PERSIST.md](HOST-PERSIST.md).
- CurseForge **beta** `v0.5.77-beta`.

## v0.5.76

- Campfire TTL no longer mixes your PC clock with the US realm clock. Denmark vs US (`time()` vs `GetServerTime()`) is a 9 hour jump — enough to make a 20 minute fire look burned out after `/reload`.
- Your hosted pin now counts down from **seconds remaining** + `GetTime()` (session timer), which does not care about time zones.

## v0.5.75

- Do not rebuild the hosted camp until the game clock is a real unix time. A `0` clock after `/reload` was writing a negative `litAt`, so the pin looked expired for the rest of the session.
- Restore retries over the first few seconds, and chat only says the fire is still yours after hosting is actually restored.

## v0.5.74

- `/reload` keeps the hosted camp when Forever's clock changes unit. The snapshot now stores **seconds remaining**; restore rewrites `litAt` onto this session's clock instead of treating the fire as already burned out.
- Restore runs again on entering the world, and a clock jump no longer expires a fire that was still lit a moment ago.

## v0.5.73

- Login says what happened to your fire: **"Your campfire in <zone> is still yours (X min left)"**, or **"Saved campfire dropped: <reason>"** when the snapshot is turned down.
- A failing UI or Settings init can no longer skip the host restore — each login step runs on its own and reports its error instead of stopping the rest.
- Only the 20 min clock or a pack-up may delete the saved snapshot. Stale-camp cleanup and a failed restore leave it alone so the next try can still find it.

## v0.5.72

- Lighting a campfire hosts again. A kit **Use** whose spell id we never learned is now caught by the cast name, and the craft check reads the profession window live instead of a `TRADE_SKILL_CLOSE` flag that could stay stuck on.
- `/smores castdebug` prints what each campfire cast looks like (spell id, name, profession window state, decision) and lists the place-fire spell ids it knows.

## v0.5.71

- Back to the v0.5.69 `/reload` persistence that worked: the per-character `SmoreSkillsHostDB` snapshot is restored on load with no extra guards in the way.
- Crafting a **Basic Campfire Kit** no longer hosts a camp. Create and Use share one cast, so the profession window decides: window open on cast start means craft, closed means you lit a fire.
- Tooltip shows a met skill requirement in green instead of red.

## v0.5.70

- Map Find button sits left of the **Map & Quest Log** hide tab so that toggle stays clickable.
- CurseForge **beta** `v0.5.70-beta`.

## v0.5.69

- Hosted camp persists across `/reload` in a per-character snapshot (`SmoreSkillsHostDB`). The pin and `/smores camp` stay until the **20 min** clock, pack-up, or 3/3.
- CurseForge **beta** `v0.5.69-beta`.

## v0.5.68

- Tried to keep the hosted camp in `SmoreSkillsDB.camps` across `/reload`; that table was still written empty, so the pin dropped.

## v0.5.67

- World-map pin tooltip lists the short benefit after each known camping object (`Camp Chair — +2% crit`), so seekers can see what they gain by sitting down.
- Pin TTL is **20 minutes from when that fire was lit** (Forever camp was still up after 10).
- CurseForge **beta** `v0.5.67-beta`.

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
