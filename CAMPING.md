# Forever camping (what we know)

A player campfire becomes a **campsite**. Same-faction players sit at the fire. Buffs come from **placed objects**, not from “this camp is Tailoring.”

## Rules (BlizzCon / panel)

- A basic campfire allows **up to three** special crafted objects.
- Each player can place **one** object.
- Each tradeskill has its own objects (unique buff or utility).
- First objects at the **associated skill level**, then a **quest**. Better ones come from **blueprint** recipes found during adventures.
- Camping features share a **1 hour** cooldown.
- Objects require a **campfire / campsite nearby**.
- Buffs are variants of, and **exclusive with**, class buffs (Blessing of Might, Arcane Intellect, Strength of Earth, …).

## Deep Dive panel recap (official)

Source: [World of Warcraft: Forever Deep Dive Panel Recap](https://news.blizzard.com/en-us/article/24303313/world-of-warcraft-forever-deep-dive-panel-recap) (Clay Stone, Josh Greenfield / Aggrend, 14 Sep 2026). Wowhead blue-tracker mirror of the same post.

This is the panel write-up. **Live item text wins** where they disagree (Sharpening Wheel is **Strength**, not Attack Power).

- Placing a **Basic Campfire** creates a campsite. Sit for a few moments to get **rested**, then leave. Benefits named: **vendors, repairs, profession workspaces, and one-hour buffs**. Refreshing food buffs is part of the stop.
- **Location matters:** “some parts of Azeroth are better suited for a quiet rest than others.” Matches Camping 101 (wilderness, not town square).
- Basic fire: **up to three** crafted objects, **one per player**. Those objects share a **one-hour cooldown** (same as live item text).
- Each profession has **three objects at different skill levels**. The profession’s **buff or utility is the same no matter which of those three is placed** (Anvil/Forge keeping the wheel’s Strength fits this). Extra objects can still add a **station** (lab, rack, forge).
- First object at **skill 20**, from a camping NPC or the profession trainer. Later objects: **Blueprint recipes from specific dungeon bosses** (quest text said “during your adventures”; this recap names dungeon bosses).
- Named examples beyond BS/tailor/herb:
  - Alchemy: **Alchemy Lab**
  - Leatherworking: **Tanning Rack** (needed for advanced LW recipes)
  - Cooking: **upgraded campfires** that allow **five or ten** objects — not a Basic 3-slot camp. `SmoreSkills.MAX_SLOTS = 3` is Basic only; do not extend the `H:` wire until we see a 5/10 fire on beta.
- Panel examples still say Sharpening Wheel = **Attack Power**. Live tooltip is **+34 Strength**. Keep Strength.

**Addon notes from this recap**

- Seekers may want a pin for **vendor / repairs / workspace**, not only a matching trade. Find currently expects a profession; revisit if people camp with cooking-only.
- **One-hour buffs** (after sitting) and **one-hour place cooldown** can both be true. Still **not** how long the fire stays up.
- Cooking 5/10 capacity would break three sockets and `p1:o1:p2:o2:p3:o3`. Stay at three until we measure it.
- Forever **two-part character names** (e.g. `Ana Forever`) make `own` on the wire longer. Keep the payload under 250 bytes.

## Sep 2026 blurb (profession items)

Source: trade-skill / campsite copy shared 15 Sep 2026. Treat as current marketing; **beta must confirm** where it disagrees with the panel notes above.

- Place a campfire in the **wilderness** while questing (cities like Stormwind are probably not the intended site).
- Meet people and share **one-hour buffs**.
- **Every profession gets three unique items** they can place for themselves and fellow campers.
  - First item: reach the **associated skill level** and complete a quest (Blacksmithing: *Camping 101* from Smith Argus, reward Sharpening Wheel). Marketing said “level 20”; live requirements and this quest are **skill**, not character level.
  - The other two: **Blueprint recipes from specific dungeon bosses** (panel recap). Quest text only said “during your adventures.”
- Blacksmithing examples in this blurb:
  - **Sharpening wheel** — marketing said AP; **live tooltip is Strength** (see below).
  - **Anvil** — marketing said repairs; **live tooltip** only says wheel benefits + replace the wheel.

Do not confuse **three items per profession** (your personal unlocks) with **three object slots on a camp** (three different players, one object each). The camp still has three slots.

**Buffs vs camp lifetime:** the Deep Dive recap says sit a moment, then leave with **one-hour buffs**. Live item tooltips instead spell a **1 hour cooldown** on placing camping features. Those can both be true. Neither is how long the campsite stays lit. TBC Anniversary pin TTL is **10 min** (`SmoreSkills.CAMPFIRE_DURATION`) so two-client tests have room; Classic cooking fire is still 5 min in-game. On Forever beta, time the **campsite** itself.

## Blacksmithing (live tooltips)

In-game item text (pre-beta client, Sep 2026). This overrides Camping 101 numbers where they differ.

| Object | Requires | Use |
| --- | --- | --- |
| Sharpening Wheel | Blacksmithing (20) | Constructs a wheel; you and others **sitting nearby** get **+34 Strength**, exclusive with Strength of Earth Totem. Campfire nearby. |
| Anvil | Blacksmithing (**140**) | Places an anvil; **all Sharpening Wheel benefits**. May be placed over a wheel to replace it. Campfire nearby. Tooltip does **not** mention repairs. |
| Master Forge | Blacksmithing (300) | Usable for recipes that require it, **plus all wheel benefits**. May replace a wheel. Campfire nearby. |

All three: **All camping features share a cooldown of 1 hour.**

Camping 101 had Anvil at skill **160** and Strength **+4**. Live text is **140** and **+34**.

### Camping 101: Blacksmithing (quest)

Smith Argus. Completing it **teaches Sharpening Wheel** (cast on you) plus a little XP.

Quest text that matters for the addon:

- Test the wheel in the **wilderness**. “Most folk don't care much for camps being set up in the center of town.”
- **No camp without a campfire.** Place the fire first, then the object.
- **Cooks** teach the basic campfire. If you cannot cook yet, find culinary training.

## Other examples (panel / recap)

| Profession | Object | Buff / utility |
| --- | --- | --- |
| Tailoring | Faction banner | Spirit |
| Herbalism | Incense candle | Intellect |
| Alchemy | Alchemy Lab | Workspace (buff unknown) |
| Leatherworking | Tanning Rack | Required for advanced LW recipes |
| Cooking | Upgraded campfires | **5 or 10** object slots (not Basic 3) |

Cooking also teaches the **Basic Campfire** that *starts* a site. That is separate from the upgraded 5/10 fires.

## Zockify camping roundup

Source: [WoW Forever Camping System](https://www.zockify.com/forever/camping-system/) (updated 14 Sep 2026). Secondary compilation of the Deep Dive recap plus live BS tooltips — not a primary Blizzard post.

**Matches what we already have:** vendors / repairs / workspaces; Basic 3 vs cooking 5/10; one object per player; 1 hour place cooldown; sit to receive **1 hour buffs**; skill 20 then dungeon-boss blueprints; Alchemy Lab, Tanning Rack, Faction Banner, Incense Candle; BS Wheel **20** / Anvil **140** / Forge **300**.

**Use with care:**

- Their object table correctly says Sharpening Wheel = **+34 Strength**. Their buffs section still lists **Attack Power**. Keep Strength (live tooltip).
- They skip **Field Guide**. Talent tooltip still has it (−8% place cooldown, 3 ranks).
- They write Permanence as **50% per rank**. Unspent tooltip only shows **50%**; later ranks unverified.

No new named objects beyond the recap.

## Legacy perks (camping)

Sources: [Legacy perks](https://classicwowforever.com/professions/legacy-perks/), [Camping](https://classicwowforever.com/professions/camping/) (pre-release tooltips). [Zockify](https://www.zockify.com/forever/camping-system/) lists Permanence and Reagent Economy only.

These are **the host's (or seeker's) personal Legacy spends**. Tooltip language is “your cooldown”, “your Tier 1 features”, “benefits **you** gain from resting”. Do **not** treat them as camp-wide until beta proves otherwise.

| Perk | Ranks | Camping part | Who it actually helps |
| --- | --- | --- | --- |
| **Reagent Economy** | 1 | Tier 1 camping features cost no reagents to craft | The **crafter**. Visitors do not get free crafts from sitting at that fire. |
| **Field Guide** | 3 | −8% cooldown on **adding** camp features (per rank; stacking unconfirmed) | The **person placing**. A seeker filling a slot uses *their* cooldown, not the host's. |
| **Permanence** | 2 | Benefits **you** gain from resting at a camp last 50% longer (per rank; stacking unconfirmed). Also lengthens some long-duration party/raid class buffs. | The **person with the perk**, at any camp. Host Permanence does not (from this text) make *your* Strength last longer at their fire. |

Permanence extends the **buff**, not how long you must sit, and not how long the fire stays up.

Deeper in Resourcefulness, the recap only names **Reagent Economy** as removing reagents from **class abilities**. The camping “Tier 1 features cost no reagents” line is from the talent tooltip, not this article.

**Pin / tooltip:** optional compact line once Forever exposes a readable API (`Host Legacy: Permanence 2` — not “this camp’s buffs last 50% longer”). Opt-in. Do not add extra `H:` colon fields. Skip on TBC.

## How S'more Skills should work (target design)

Addons cannot scan Ashenvale for fires. Discovery is **opt-in signals** between players who have the addon — never guild chat, never a login dump.

## Example: seeker and host

**Seeker** — level 22 night elf leatherworker leveling in Ashenvale. Wants buffs and might fill an empty camp slot.

**Host** — dwarf blacksmith on the other side of the zone. Sitting alone at his fire with one object placed (anvil). Waiting for company.

When their signals **match**, the night elf sees a **map pin**: a bonfire icon with **three rounded sockets** around it. Filled sockets show the profession (and object when known); empty sockets show a faded greyscale S'more. She sees `1/3` filled (Blacksmithing), knows she can join with Leatherworking, and that other seekers may have received the same ping.

**World map pins are hosts only.** Seekers never appear on the map. A pin means someone is **hosting** (`/smores host` or Auto host on campfire). **Your own** hosted pin is local (no Find needed). **Other** host pins appear only after you click **Find** — leftover location snapshots are not pins.

**One camp at a time.** Lighting a **new** campfire (Auto host) packs up the previous pin (`X:`) and hosts the new site — Elwynn then Stormwind does not leave both pins. Walking away, or `/smores host` without a new fire, keeps the **original fire coords**. Pack-up (right-click own pin or `/smores pack`) also ends the camp. There is no `/smores here` snapshot command; sharing a fire is host only.

**The host's pin is local.** Lighting a fire writes the camp into *your* addon and draws it on *your* map. Slot 1 and the Host tooltip line use the Host-tab profession. A seeker only draws that pin after **their** client receives your host ping (`H:`). Standing next to each other is not enough.

## Two roles

| Role | Who | Action | Meaning |
| --- | --- | --- | --- |
| **Seeker** | Player looking for a camp | Map button or `/smores find` | “I'm in this zone and looking for a fire I can join.” |
| **Host** | Player at a fire with room | Map button or `/smores host` | “I'm at this fire; want more players (any trade or specific ones).” |

Signals are **addon messages** on the hidden `SmoreSkills` channel (not guild/party/raid). If CHANNEL addon messages are dropped, the same hidden channel carries a prefixed chat fallback (`SmoreSk …`). That is still not visible guild chat.

When a host answers a seek, `H:` is sent on that hidden channel **0.15 s later** (Classic cannot `SendChatMessage` from the `CHAT_MSG_*` handler itself). Addon **whisper** is only if the channel is not joined — TBC Anniversary often prints *Unable to whisper … Blizzard services may be unavailable* for addon whispers even when `/w` works. Do not skip the channel chat when dropping whisper (0.5.34 did that; seekers never got the pin).

## Map UX (Forever target)

- Small **bonfire button** on the map (corner). Tooltip: *Find campsites in this zone*.
- **Seeker click** → one seek ping; listen for matching **host** pings; show those pins only. Seekers never get a pin of their own. Switches the map to the **player's zone** (not a nested city map).
- **Host click** (while at/near a fire) → host ping with coords + slot state + who you want. Walking away does **not** move or drop the pin; we keep broadcasting the **fire's original coords**. Lighting a **new** campfire does move it: the old pin is packed (`X:`) and the new fire is the only campsite.
- **Find right-click** → clear *other* people's markers. Your own hosted pin stays until the fire ends, the camp is full, or you pack up.
- **Own pin right-click** or `/smores pack` → confirm pack-up. Sends `X:` so seekers drop that pin immediately (overrides the 10 min / 3/3 lifetime).
- **Pin art:** bonfire + three sockets (profession icon, or faded greyscale S'more if empty). Hover: zone, coords, layer, `2/3`, owner, slot detail. Left-click whispers the host.
- A green **G** on a pin or list row means a guildie is on that camp. Hint only — guild is not how data moves. You do not see **G** on your own hosted pin.
- **`/smores list`** prints the same set as the map: hosted camps you can see, **max 12** per zone (not every camp still in memory).

## Matching (client-side)

Each client keeps a **short-lived cache** of recent signals (TTL ~3 minutes). No server.

A **host** ping is shown to a **seeker** when all of:

1. Same **faction**
2. Same **zone** (map id)
3. Host has at least one **empty slot**, or explicitly wants the seeker's profession
4. Host **want list** is `any`, or shares **at least one** profession with the seeker. Extra trades on the seeker do not matter (Engineering+Mining host vs Engineering+Mining+Cooking seeker is a match). If the host filter is on and **no professions are ticked**, want is `none` — **nobody** sees the camp. Empty item picks still mean any item. The host's **own** camp profession (slot 1) is separate — a blacksmith can still tick Blacksmithing in Host wants if they want another BS to place an object. Forever beta will tell us how stacking same-trade objects works; do not hide that checkbox.
5. Pin count in zone is under the **display cap**
6. **Layer:** default is **include other layers**. Uncheck Settings → **Include camps on other layers** to only match your current layer. If either side has not detected a layer yet, the camp still shows.

Seekers who click find at the same time may all see the same camp — that is intentional (light urgency).

## Load limits (never freeze the client)

| Limit | Value | Why |
| --- | --- | --- |
| Seek cooldown | 45 s | One click ≠ spam |
| Host rebroadcast | 90 s while “open” | Heartbeat, not flood |
| Signal TTL | 3 min | Seek listen window; stale seek/host *signals* |
| Campfire pin lifetime | **10 min from `litAt`** (when that fire was lit) | Same clock for every seeker — Find at minute 7 means **3 min left**, not a new 10. Heartbeats do not restart it. Hide when time is up, 3/3, pack-up, or a **new** fire (`X:`). **Forever:** time the campsite on beta before changing `CAMPFIRE_DURATION`. |
| Camp memory | 30 min | Same as today |
| Max pins per zone | 12 | Cap map clutter. `/smores list` uses this same cap. |
| Payload size | &lt; 250 bytes | WoW addon message limit. If `H:` would exceed it, **shrink** rather than drop the ping: (1) host item list, (2) object display names (keep profession codes), (3) shorten `own` to 24 characters. Host gets one chat line. **Revisit if Forever two-part names + full item lists still clip useful tooltip data** — seekers would still see the pin, but miss item/object names. Do not split one camp across two messages. |
| Share cooldown | 8 s | Per player, all outbound types except pack-up `X:` (must go out immediately) |

If the channel is busy, drop **oldest** signals first; never queue unbounded work on `CHAT_MSG_ADDON`.

## Wire format (community channel)

Hidden channel: `SmoreSkills`. Prefix: `SmoreSk`. Same faction only.

| Type | Purpose | Shape (concept) |
| --- | --- | --- |
| `C:` | Legacy camp snapshot (receive only; we do not send) | `C:map:x:y:fac:own:p1:o1:p2:o2:p3:o3:t` |
| `S:` | Seeker — looking in zone | `S:map:fac:prof:t[:codes]:layer` |
| `H:` | Host — at fire, wants company | `H:map:x:y:fac:own:want:p1:o1:p2:o2:p3:o3:t:layer` |
| `X:` | Packed up — drop this camp pin now | `X:map:x:y:own:t` |

- `want` = `any` or profession codes (`bs,lw,tail`, …)
- `prof` = seeker's profession code(s); extra learned trades may follow for matching
- `t` = unix timestamp. On **`H:`** this is when the fire was **lit** (pin TTL); heartbeats send the same `t`, not "now". On `S:` / `X:` it is when the ping was sent.
- `layer` = `zoneUID` or `zoneUID/N` on the wire. Tooltip: own pin **Layer N — Your camp**; others **Layer N — same as you** / **Layer N — you are on Layer M**. N is the host's display number so both clients agree. `0` or omitted if unknown.
- Coords use the same fixed-point wire encoding as `C:`

A late seeker (logged in after the fire is already up) does **not** get a dump on login. They click Find → `S:` → the host replies with `H:` on the hidden channel (0.15 s timer; Classic cannot `SendChatMessage` from `CHAT_MSG_*`). Addon **whisper** is only if that channel is not joined. Host heartbeat every 90 s is the backup. Walking away from the fire does not stop hosting; we keep the **original fire coords**.

Do **not** call `ChatFrame_RemoveChannel` from this addon (login, ping, or channel events). That taints Blizzard chat and shows *Interface action failed because of an AddOn*. Hide `SmoreSk` payloads with a chat filter. Auto-host must not `SendChatMessage` from `UNIT_SPELLCAST`; after the fire **lands**, a **0.25 s** timer sends the same hidden-channel `H:` as `/smores host`. Do not hook WorldFrame / UIParent or steal the keyboard to flush. Interrupted casts never host. Other players still only get a pin after **Find**. Continent / world zoom has no pins — stay on the **zone** map.

**Sibling zones:** an Elwynn pin must not appear on Duskwood at the same 39,70-style fractions (same-name map ids like Elwynn 37 vs 1429 still share a pin; nested city maps still draw).

If the seeker has **no profession** yet, Find does nothing useful (`Set your profession first`). Matching uses **this character's learned trades**. `/smores prof` is **session-only** (testing) and clears on reload/logout. Host **Want:** Engineering, Mining (etc.) hides the camp from seekers who share none of those trades — use **Anyone** for a clean two-client test. Find’s “N other camp(s)” does **not** count your own fire.

## What we store per camp

Map id, x/y, zone name, faction, host/owner, **three slots** (player, profession, object name when known), last updated, optional want list.

---

# TBC Anniversary testbed (until Forever beta)

**Forever beta:** 17 Sep 2026 — swap `## Interface:` and install path to `_forever_` then. Map layout, breadcrumb hierarchy, and beta checklist: [FOREVER.md](FOREVER.md).

TBC Anniversary has **no camping mechanic**. We still use it to prove:

- Hidden `SmoreSkills` channel join and addon messages between two clients
- Zone + faction filtering
- Seek/host matching and pin list (even if slots are **hand-picked** for the test)
- Rate limits and TTL under real latency

### What to simulate on TBC

| Forever behavior | TBC stand-in |
| --- | --- |
| Sit at a campfire | Light **Basic Campfire** (Cooking) — placeholder host ping at your coords |
| Place BS anvil in slot 1 | Host sets slot 1 to Blacksmithing in the UI (or `/smores slot 1 bs`) when we add it |
| “Find camps in zone” | `/smores find` or map button → seek ping |
| “Open camp for visitors” | Lighting Basic Campfire (if Auto host is on) or `/smores host` |

**Placeholder (until Forever campsite API):** we cannot read a real campsite. Lighting the Cooking spell **Basic Campfire** (spell **818**) is treated as “I placed a fire here.” If **Auto host when lighting a campfire** is on, the addon sends a host signal (`H:`) at your **zone** map coords so seekers can see a pin on that **zone** map (not continent/world zoom). Map pins use the **Basic Campfire** icon. Slot 1 is the host’s chosen profession (Host tab) until placed objects exist. Same spell hook should still fire on Forever if Cooking keeps that spell; swap it for the real campfire/object event when Blizzard exposes one.

### Two-client smoke test (Elwynn — retest 16 Sep 2026)

v0.5.47 is GitHub-only (no CurseForge tag). Last session: Find printed “sharing yours” but the seeker never got `H:` (0.5.34 dropped channel chat with whisper). Seeker “1 match” was their **own** camp. Map view **Eastern Kingdoms** has no pins. A second fire in Stormwind still showed the Elwynn pin until 0.5.47.

1. Deploy: `.\scripts\deploy-to-wow.ps1 -Client anniversary` — both `/reload`, load line **v0.5.47**
2. Both: `/smores status` — Channel joined, Cross-layer on, Host want **Anyone**, Seeker filter Anyone
3. **Host:** light **Basic Campfire** (Auto host on). Wait for `Hosting in Elwynn Forest`. Do not interrupt the cast. Optional: `/smores host` if you need to re-share
4. **Seeker:** open the world map, **zoom to Elwynn Forest** (not Eastern Kingdoms / continent), click **Find**
5. Seeker chat: `Camp found` and **1 other camp** (not their own fire). Pin on Elwynn only — **not** Duskwood
6. Host walks ~10 yards — pin stays on the fire; Find still answers
7. Find right-click clears the seeker's other markers, not the host's own pin
8. Host packs up → seeker pin vanishes (`X:`)
9. If **Interface action failed because of an AddOn** appears when lighting the fire, note it — do not click-catch the whole UI to work around it
10. Optional: light a **second** fire in Stormwind before the 10 min is up. Host chat should pack Elwynn; the forest pin is gone. A pin on the Elwynn map in the Stormwind corner is the **new** city camp (nested map), not the old forest site.

**Elwynn / nested city maps:** Stormwind City is a child of Elwynn Forest. The map *art* can still be Elwynn (Stormwind in the corner) while `WorldMapFrame:GetMapID()` reports Stormwind City. Pins must still draw at **Elwynn** coords. Same family: Ironforge on Dun Morogh, Orgrimmar on Durotar. **Ashenvale has no nested capital**, so that glitch does not apply there. `/smores status` prints `Zone:` vs `Map view:` so you can see a mismatch.

`/smores status` — channel joined, hosting/seeking, trades, zone, map view, seeker filter.

### Shipped (v0.5.47) vs Forever beta

| Feature | v0.5.47 (TBC testbed) | Forever beta |
| --- | --- | --- |
| Seeker signal `S:` (`/smores find`, map Find button) | Yes | Same |
| Host signal `H:` (`/smores host`) | Yes | Same + auto-host on Basic Campfire (placeholder) |
| Auto host on Basic Campfire (spell 818) | Yes (placeholder) | Keep until real campsite API; then replace |
| Manual slot edit (`/smores slot`) | Yes | Auto from game API |
| Client-side matching + rate limits | Yes | Same |
| Map bonfire pin + three socket art | Yes | Same art; verify coords API |
| Custom camp hover tooltip | Yes | Same |
| Settings popup (Host/Seeker filters) | Yes | Same |
| Minimap fire icon | Yes | Same |
| Auto-read placed objects | No | When API exposed |
| Pin lifetime | **10 min from lit fire**, 3/3, pack-up, or a **new** fire (`X:`) | **Unknown.** Copy says **buffs** last 1 hour; that is not camp/pin length. Measure the campsite on beta. |
| Nested city maps | Draw zone coords if the widget reports the city (Elwynn/Stormwind) | Confirm Forever breadcrumb / GetMapID |
| Pins at continent/world zoom | Hidden — zone map only (nested city still draws zone coords) | Same |
| Occupancy: sitters vs object slots | Host broadcasts state | May need extra `H:` field |

---

# Host-only broadcast (design note)

If **only the host** has the addon, guests cannot update camp state — the host must rebroadcast slot fills and empties. Seekers with the addon see `N/3` from the host ping when slot data is included.

**Heads at fire** (how many players are sitting) and **three object slots** may differ. Do not extend the wire format for sitter count until Forever beta exposes a reliable API (e.g. `sit` on `H:`).

---

# Later (Forever beta onward)

- Read campfire / placed-object API when exposed
- **Pin lifetime:** TBC testbed pin is **10 min from when that fire was lit** (Find at minute 7 = 3 min left). Forever copy says **buffs** last 1 hour — that is not the campsite duration. Time a real fire on beta, then set `SmoreSkills.CAMPFIRE_DURATION`. Pins also drop when **3/3**, the host packs up (`X:`), or they light a **new** fire.
- Fill a slot automatically when you place an object
- Occupancy: sitters at fire vs object slots (different numbers)
- **Cooking 5/10-slot campfires:** pin sockets and `H:` slot fields are built for Basic **3**. Measure before extending the wire.
- **Two-part character names** on `own` — keep messages under 250 bytes
- **Learned camp objects:** if Forever exposes recipes in the profession spellbook (or a camping API), hard-filter host/seeker item picks to what that character can actually place. TBC has no camping recipes to scan.
