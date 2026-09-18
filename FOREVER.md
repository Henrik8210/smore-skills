# WoW Forever — beta notes

**Product is Forever.** TBC Anniversary is only the two-client share testbed. Do not design for Anniversary and back-port.

**Live first night:** 17–18 Sep 2026 on `_classic_beta_` (game **1.60.1**, Interface **16001**). Servers dropped overnight; they were **up again 18 Sep**. Last CurseForge full file before this pass was **v0.5.62**. This pass is CurseForge **beta** `v0.5.64-beta`.

---

## Live beta log (17–18 Sep, Zephras Isle)

Horde Skyborne shaman **No Bunda**, Shen'dar Village / Zephras wilderness. First night ended before Engineering / Leatherworking trainers and a two-client share test. **18 Sep** trainers were reachable again (blacksmith, leatherworker, tailor, enchanter on the same fire).

### Client

- Battle.net folder is `_classic_beta_` (`WowB.exe`). No `_forever_` folder. Deploy: `.\scripts\deploy-to-wow.ps1 -Client forever`
- Addon API is **Mainline** (secrets, chat lockdown, `JoinPermanentChannel` / `SendChatMessage` / timer `SendAddonMessage` are Blizzard-only).
- First login: `MaximizeMinimizeFrame` is a **Frame** with child buttons. Hooking `OnClick` on the Frame aborted map init (no minimap). Hook the buttons; skip script types the widget does not support.

### Map

- **Map & Quest Log** (map + quest list). Breadcrumb **World > Zephras Isle** (no Kalimdor).
- Zephras is typed like a **Continent** under World but it is the playable camping map. Pins must draw on leaf continent-typed islands; hide EK / Kalimdor overview (many zone children).
- Saved camp example: mapId **2521**, coords like `0.432, 0.239` / player chrome **44.4, 43.4**. Host camp panel on 18 Sep showed **Zephras Isle 46.8, 45.2**.
- Own host pin worked after kit Use (v0.5.55+). Continent-typed hide was why the first kit Use looked like “no pin.”
- Two-client `H:` share and Find-button position on this chrome were **not** confirmed before servers died; still not re-tested on 18 Sep.

### How you place a fire

1. Cooking **Camping** recipe **Basic Campfire** → item **Basic Campfire Kit**. **Create** = bags only, **no pin** (even if the profession window closes mid-craft).
2. **Use** the kit in the wilderness = the fire and the auto-host trigger.
3. Sit / `/sit` does **not** host (tutorial **Welcoming Campfire** / *The Great Outdoors* / **Boosted Rest**).
4. Blizzard: **cannot place a new campfire within 100 yards** of an existing one.
5. Kit tooltip: cooking at the fire; **up to 3 additional camp features**; sit or craft nearby **1 min** for feature benefits. Cooking (1), Flint and Tinder, **1 Simple Wood**.
6. Spell is **not** TBC 818. Learn the Use spell from the item in bags; ignore campfire-named casts while the profession UI is open.

### Nearby awareness

Blizzard’s only “a camp is near you” cue is the player buff **Campfire Nearby** (“pleasant smoke … from somewhere nearby”). **No coords, no map pin.** Do not parse this (or anyone’s auras) for location. Our pins are the finder.

### Sharing (taint)

Forever pops *SmoreSkills has been blocked from an action only available to the Blizzard UI* if we:

- `JoinPermanentChannel` from login, zoning, or the campfire timer
- `SendChatMessage` or `SendAddonMessage` from `UNIT_SPELLCAST`, combat log, `C_Timer`, or `OnUpdate`

**Working rule:** lighting the kit writes a **local pin** only. Join + `H:` / `S:` / `X:` only from **Find** or `/smores host` (hardware). Heartbeat and seek-reply timers must not send. TBC still needs the click for chat `H:` as well.

### Camping objects (trainer **Camping** category, skill 20, 1 hour shared place CD)

Trainer list names are **Name (Tier I)**. Tooltips use the short name. Recipes are **spells** (craft, then Use at a fire) — not bag items.

**Tanning** is Skinning’s *place-skill*, not an object. Cooking’s kit is the fire, not a slot filter.

| Profession | Tier 1 object | Reagents | Sit-nearby | Exclusive with |
| --- | --- | --- | --- | --- |
| Alchemy | **Mana Well** | Peacebloom, Empty Vial | +10 Mana / 5s | Blessing of Wisdom |
| Mining | **Lodestone** | Rough Stone, Copper Bar | +12 melee AP | Blessing of Might |
| Blacksmithing | **Sharpening Wheel** | Rough Stone, Copper Bar | **+6 Strength** (pre-beta tooltip said +34) | Strength of Earth Totem |
| Tailoring | **Faction Banner** | Bolt of Linen Cloth, Coarse Thread | +14 Spirit (**own faction** only) | Divine Spirit |
| Enchanting | **Enchanted Lute** | Simple Wood, Strange Dust | +28 Armor | Mark of the Wild |
| Herbalism | **Incense Candle** | Peacebloom, Silverleaf | +2 Intellect | Arcane Intellect |
| Skinning | **Camp Chair** | Light Leather (3), Simple Wood (2) | +2% crit (spells and attacks) | Moonkin Aura |
| First Aid | **First Aid Kit** | Linen Bandage (3), Refreshing Spring Water | +3 Stamina | Power Word: Fortitude |
| Leatherworking | **Camp Tent** (live 18 Sep) | Light Leather (5) | +5% of a level Rest XP (no extra if already above that) | — |
| Cooking | **Basic Campfire Kit** | Flint and Tinder, 1 Simple Wood | Places the fire | — |
| Engineering | *not seen* | | | |

**Camp Tent** live Use: *Builds a tent that allows you and others sitting nearby to increase Rested experience to 5% of a level. No effect if Rested experience already exceeds that value.* Requires a campfire nearby; all camping features share a 1 hour cooldown. Requires Leatherworking (20). Panel still lists **Tanning Rack** as a later LW object.

Host/Seeker filters and the host camp panel label these **Camping objects**. Hover follows the cursor (reagents, Use, exclusive-with).

### Object icons (18 Sep trainers)

Live trainer art wins. Do not use profession icons when the slot names an object.

| Object | Live trainer | Do not use |
| --- | --- | --- |
| Sharpening Wheel | Gold bar / ingot | Cog / gear (`INV_Misc_Gear_01`) |
| Faction Banner | **Player’s faction** (Horde saw the dark Horde banner) | Alliance lion banner on Horde |
| Enchanted Lute | Pale lute (not a woodwind) | Flute (`INV_Misc_Flute_01`) |
| Camp Tent | Grey tent / canvas | Sack stand-in is wrong — fix later |

Addon: copy the **open trainer row** (`GetTrainerServiceIcon` / trainer button texture) and `C_Spell` by recipe name. Faction Banner falls back to Horde `INV_Banner_03` / Alliance `INV_Banner_02`. Sockets, host-panel dropdown, and settings lists share `SmoreSkills_CampingObjectIcon`.

### Host camp panel (v0.5.63+)

Opens when you host (`/smores camp` or left-click own pin). Socket 1 = your profession or object; guest sockets can be marked by hand (no world API yet). Request chips are **this fire only**; Host settings stay the defaults until you edit them. Pin tooltip follows the camp copy, not settings.

### Still open

- Two-client share on Zephras (both click Find).
- Find button visible on Map & Quest Log.
- Time a **placed** fire for `CAMPFIRE_DURATION` (do not use the 1 hour feature CD or buff).
- Engineering Tier 1 name.
- Camp Tent live icon (addon still shows a sack stand-in).
- Whether Zephras intro is an instance (chat lockdown).
- Auto-read of world objects / slots (still no API).

---

## Addon API (Q&A before beta)

Forever does **not** use the Classic addon API. Pre-beta Q&A: it uses the **modern (retail / Mainline) API and its restrictions**. Blizzard’s UI Discord / press: Forever shares Mainline UI architecture with Midnight (~12.1.5). Think two game types in one code family — Forever (Camelot) and Standard (retail) — not a Classic client with extra zones.

That includes **Midnight addon disarmament**:

- **Secret values** — combat, auras, some unit/cooldown data cannot be read or branched on by tainted addon code
- **AuraContainer / AuraButton** — Blizzard-owned aura display; addons do not parse other players’ auras in combat
- **Communication lockdown** — in encounters, M+, PvP, and some instance maps, chat/addon messaging can be restricted the same way as retail
- **Computational combat addons** are out (auto-assigns, interrupt rotations, live raid parsing). QoL / map / camping UI is the intended remaining class

**What this means for S'more Skills**

We are a **map + channel QoL** addon, not a combat calculator. We should stay allowed. Do not add combat aura/health/cooldown logic.

Beta still has to prove the retail-restriction surface:

| Area | TBC Anniversary (what we tested) | Forever (retail API) — check first login |
| --- | --- | --- |
| Profession scan | Classic `GetNumSkillLines` / `GetSkillLineInfo` | Likely `GetProfessions` / `GetProfessionInfo` (retail). If empty, Find says set `/smores prof` |
| Hidden channel `H:` / `S:` | Prefixed chat + addon CHANNEL; chat only from Find / `/smores host` click | Same taint rules, plus **chat lockdown in instances**. First Skyborne test is **Zephras Isle** (open world). Do not test share inside a dungeon |
| Map coords | `C_Map.GetPlayerMapPosition` | Confirm coords are **not** secret in open world. If they are secret in combat, host while standing at the fire out of combat |
| Layer from nameplates | Unit GUID / nameplate scan | Unit APIs may return secrets; layer may stay “unknown” more often |
| Spell hook 818 | `UNIT_SPELLCAST_SUCCEEDED` | Keep until a real campsite event exists; retail spell APIs (`C_Spell`) already have a fallback |
| UI frames | Classic textures / Backdrop | Mainline FrameXML — map Find button, minimap, settings may need new anchors |

Classic-only addons often need a rewrite. Midnight addons port more easily. We were written against TBC Anniversary, so treat Forever as a **new client pass**, not a toc bump.

Do **not** try to bypass secrets or chat lockdown. If a host ping cannot send in an instance, that is the game rule — share in the open world.

---

## Install

Battle.net installs Forever beta as `_classic_beta_` (product `wow_classic_beta`, `WowB.exe`). There is no `_forever_` folder.

```powershell
.\scripts\deploy-to-wow.ps1 -Client forever
```

After first login on Forever:

1. FrameXML is packed in CASC — there is no loose `Interface\FrameXML\FrameXML.toc`. Confirm Interface with `/dump select(4, GetBuildInfo())` (expected **16001** for game **1.60.1.69893**).
2. Update `SmoreSkills/SmoreSkills.toc` `## Interface:` if Forever reports a different number.
3. Enable **Load out of date AddOns** if needed; `/reload`.

---

## Art assets

| File | Use |
| --- | --- |
| `Art/SmoreSkillsLogo.tga` | Addon list icon (`## Icon:` in toc) |
| `Art/SmoreSkillsIcon.tga` | Minimap button, map Find button, pin texture |

PNG sources live beside the TGA files for editing. In-game paths: `SmoreSkills.LOGO`, `SmoreSkills.ICON` in `Core.lua`.

---

## World map UI (Forever)

The map frame is titled **Map & Quest Log** — map and quest log share one window (quest list on the right when open).

### Map hierarchy (breadcrumb, top-left)

Navigation drills down in layers, e.g.:

```text
World  >  Eastern Kingdoms
World  >  Kalimdor
```

(Zone-level breadcrumb expected when zoomed further, e.g. `World > Eastern Kingdoms > Elwynn Forest` — confirm on beta.)

| Level | What you see |
| --- | --- |
| **World** | Both continents on one parchment: **Kalimdor** (west), **Eastern Kingdoms** (east), **The Maelstrom** between them. Decorative sea, compass rose, ship art. |
| **Continent** | Single continent fill the canvas (e.g. full Eastern Kingdoms with The Great Sea / Forbidding Sea labels). |
| **Zone** | Individual zone map (standard gameplay view) — **this is where camp pins should appear.** |

### Coordinates (bottom-left of map)

Forever shows live coords on the map chrome:

```text
Cursor: 83.0, 62.3
Player: 42.6, 23.6 (Zephras Isle)
```

- Same **0–100** style as our stored `camp.x` / `camp.y` (we wire as 0–1 internally).
- Zone name in parentheses on the player line — useful to cross-check `C_Map` / `GetRealZoneText()` against `camp.zone`.

### Other chrome

- **World** button (top-left) — jump to world map from deeper levels.
- **Search** (quest log side) — quest log filter; unrelated to camps.
- **Minimize** control (top-left of map canvas).
- **Help** (`?`, bottom-right of map area).

### Implications for S'more Skills

| Topic | Current behaviour | Beta check |
| --- | --- | --- |
| **Pin visibility** | Zone pins only; hide at World / Continent / Outland zoom. If `GetMapID()` is a nested city (Stormwind while standing in Elwynn), still draw **zone** coords. | Confirm nested-city breadcrumb vs TBC. |
| **Find button** | Anchored to map canvas (`ScrollContainer` / `GetCanvas()`). | Confirm button still visible at zone + continent + world. |
| **Map hooks** | `OnShow`, `OnMapChanged`, canvas `OnSizeChanged`. | Log `GetMapID()` at each breadcrumb level; note ids for test zones. |
| **Camp tooltip** | Custom frame (not GameTooltip): opaque dialog background, three circular gold-ring profession sockets. | Verify TBC-safe color APIs still work; no silent fallback to text-only tooltip. |
| **Seek pulse** | World map Find button fades while seeking. | Confirm animation on Forever map frame. |
| **New zones** | Pins follow `C_Map` (no Elwynn-only list). Sibling zones must not share fractions. | **Skyborne starts on Zephras Isle (1–12).** Also Hyjal, Shen'dralas, Riverglades. Record mapId + mapType from `/smores status`. If the isle map is typed Continent, pins hide — that is a bug to fix. |

---

## New zones (Skyborne first)

Pins are **not** hardcoded to Elwynn or Ashenvale. Host/Find use the player's current `C_Map` zone. Forever still has new canvases we have never seen:

| Zone | Who / when | What to watch |
| --- | --- | --- |
| **Zephras Isle** | Skyborne starting zone, **levels 1–12**. Elemental / Skywall-inspired island. Horde or Alliance from creation (Horde Shaman / Alliance Mage). | First camp test. `/smores status` with the map open: **Zone** vs **Map view**, map **id**, **type** (Zone / Micro / Continent / Orphan), **pins** yes/no. A Zephras pin must not appear on Elwynn or Kalimdor at the same fractions. |
| **Mount Hyjal** | Restored / expanded after Archimonde | Nested maps, continent parent |
| **Shen'dralas** | Between Mulgore and Desolace | New zone vs old neighbours — sibling-zone rule |
| **Riverglades** | Mid-30s to mid-40s frontier | Same |

If Zephras is an **instance** for the intro, retail **chat lockdown** may block `H:` until you are in open world. Note that; do not work around it.

If the isle map `mapType` is **Continent** (or World), treat that canvas like a zone when it has few/no zone children (Zephras under World). Kalimdor / EK still hide pins.

`/smores status` prints `id`, map type, and `pins` / `no pins` so you can paste it from Zephras without guessing.

---

## Camping (Forever vs TBC)

| | TBC Anniversary | Forever |
| --- | --- | --- |
| Basic campfire / campsite | **Cooking Basic Campfire** as a **placeholder** host ping (not a Forever campsite) | Real kit: **Create** = bags; **Use Basic Campfire Kit** = fire + local pin (see [CAMPING.md](CAMPING.md)) |
| Three object slots | Manual `/smores slot` | Auto-read when API exposed |
| Auto host on campfire | Lights **Basic Campfire** → local pin; Find/`/smores host` for `H:` | **Create** kit = bags only. **Use** kit = local pin. Sit does not host. Find/`/smores host` for `H:`. |
| Chat messages | General toggle; off mutes automatic addon chat. `/smores` still replies | Same |
| Pin lifetime | Hide after **10 min from the lit fire** (same remaining time for every seeker), **3/3** slots, pack-up, or a **new** fire | **Unknown.** Live items: 1 hour is a **camping-feature cooldown**, not camp length. Marketing also said 1 hour **buffs**. Time the campsite on beta before changing `CAMPFIRE_DURATION`. |
| Nearby awareness | None (our pins) | Player buff **Campfire Nearby** (no coords). Do not aura-scan. Pins are the finder. |
| Skinning camp object | n/a | **Tanning** = place-skill. Object is **Camp Chair**. Also live: Lute, Incense, Lodestone, Wheel, Banner, **Camp Tent**, **First Aid Kit**. |
| Socket icons | Same Forever art (trainer/spell lookup; stand-ins if the client has no spell) | Live `C_Spell` / trainer icon. Banner = your faction. Camp Tent sack is a known miss. |
| Who updates camp state | Host rebroadcasts (guests without addon cannot) | Host + addon users at fire when API allows |

---

## Thursday beta smoke test (checklist)

Use **two same-faction characters** in the **same zone**.

### Setup

- [ ] Deploy: `.\scripts\deploy-to-wow.ps1 -Client forever`
- [ ] Fix `## Interface:` in toc if addon is red
- [ ] `/reload` both clients
- [ ] Set professions: `/smores prof alch` / `/smores prof tail` (or your trades)
- [ ] `/smores status` shows learned trades (not empty). If empty, professions API changed — use `/smores prof` and note it
- [ ] Open-world Find/host still puts `H:` on the channel (not inside a dungeon/raid)
- [ ] Camping while in combat: pin/share still works, or document if coords/chat are locked

### Map & pins

- [ ] Open **zone** map (not only World/continent)
- [ ] Host: **Use** a **Basic Campfire Kit** (Auto host on) or `/smores host` at a fire. Create at the trainer must not pin. Walk **100 yards** from another fire first.
- [ ] Seeker: map **Find** button (or `/smores find`); minimap S'more icon opens map only
- [ ] Bonfire pin appears at host coords on **zone** map
- [ ] Seeker does **not** get a pin of their own — only hosted camps appear
- [ ] Hover pin: custom tooltip with host line, three gold-ring sockets (camping object icon, profession if unnamed, faded S'more if empty), coords
- [ ] Minimap and Find button pulse while seeking
- [ ] Right-click map Find button clears **other** pins; **own hosted pin stays**
- [ ] Right-click own pin or `/smores pack` → pack-up confirm; seekers lose that pin immediately (`X:`)
- [ ] Host lights a **second** fire elsewhere — old pin packs (`X:`); only the new site is hosted
- [ ] Host walks away from the fire — pin stays on the fire; late Find still gets a reply
- [ ] Nested city (Elwynn/Stormwind): pin still shows on the Elwynn canvas; `/smores status` Zone vs Map view
- [ ] Seeker chat: `Camp found` when the ping arrived (host seeing the pin is **not** enough)
- [ ] Zoom out to continent/world — note whether pins hide (document map ids)
- [ ] Time a real Forever campsite (how long the fire/site stays up). Do **not** treat the **1 hour buff** as pin lifetime. Set `SmoreSkills.CAMPFIRE_DURATION` from the measured camp, then also note buff length separately. Pins still drop on 3/3, pack-up, or a new fire. Find at minute 7 must leave 3 min, not a new 10.

### Matching & settings

- [ ] Host: enable **Only invite specific professions**, pick trades in grid
- [ ] Seeker with wrong trade does **not** see pin
- [ ] Seeker: `/smores prof <matching trade>` then sees pin
- [ ] Seeker filter: **Only show matching camps** hides irrelevant hosts

### Sync

- [ ] Opposite faction does **not** see pin
- [ ] Seek cooldown (~45 s) and host rebroadcast (~90 s) feel sane
- [ ] `/smores want` / settings host list agree with host signal
- [ ] Host-only client: slot changes visible to seekers after host rebroadcast

### Log for follow-up

Record in issue or chat:

```text
Interface version: 
Addon API notes (secrets / chat lockdown / professions): 
Race / start: Skyborne / Zephras Isle?
Zone name / mapId / mapType at camp: 
World mapId: 
Continent mapId: 
Pin visible at zone? Y/N
Pin leaked onto Elwynn or another zone? Y/N
Pin visible at continent? Y/N
Find button anchored? Y/N
Custom tooltip OK? Y/N
Campfire API available? Y/N
Auto-read object slots? Y/N
```

---

## Related docs

- [CAMPING.md](CAMPING.md) — protocol, matching, load limits
- [GUIDELINES.md](GUIDELINES.md) — deploy paths, commands
- [README.md](README.md) — project overview
