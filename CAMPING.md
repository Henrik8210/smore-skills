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

---

# How S'more Skills should work (target design)

Addons cannot scan Ashenvale for fires. Discovery is **opt-in signals** between players who have the addon — never guild chat, never a login dump.

## Example: seeker and host

**Seeker** — level 22 night elf leatherworker leveling in Ashenvale. Wants buffs and might fill an empty camp slot.

**Host** — dwarf blacksmith on the other side of the zone. Sitting alone at his fire with one object placed (anvil). Waiting for company.

When their signals **match**, the night elf sees a **map pin**: a bonfire icon with **three rounded sockets** around it. Filled sockets show the profession (and object when known); empty sockets stay open. She sees `1/3` filled (Blacksmithing), knows she can join with Leatherworking, and that other seekers may have received the same ping.

## Two roles

| Role | Who | Action | Meaning |
| --- | --- | --- | --- |
| **Seeker** | Player looking for a camp | Map button or `/smores find` | “I'm in this zone and looking for a fire I can join.” |
| **Host** | Player at a fire with room | Map button or `/smores host` | “I'm at this fire; want more players (any trade or specific ones).” |

Signals are **addon messages only** — not text anyone reads in chat.

## Map UX (Forever target)

- Small **bonfire button** on the map (corner). Tooltip: *Find campsites in this zone*.
- **Seeker click** → one seek ping; listen for matching host pings; show pins.
- **Host click** (while at/near a fire) → host ping with coords + slot state + who you want.
- **Pin art:** bonfire + three sockets (empty or profession icon). Hover: zone, coords, `2/3`, owner, slot detail.
- A green **G** on a pin or list row means a guildie is on that camp. Hint only — guild is not how data moves.

## Matching (client-side)

Each client keeps a **short-lived cache** of recent signals (TTL ~3 minutes). No server.

A **host** ping is shown to a **seeker** when all of:

1. Same **faction**
2. Same **zone** (map id)
3. Host has at least one **empty slot**, or explicitly wants the seeker's profession
4. Host **want list** is `any`, or includes the seeker's profession
5. Pin count in zone is under the **display cap**

Seekers who click find at the same time may all see the same camp — that is intentional (light urgency).

## Load limits (never freeze the client)

| Limit | Value | Why |
| --- | --- | --- |
| Seek cooldown | 45 s | One click ≠ spam |
| Host rebroadcast | 90 s while “open” | Heartbeat, not flood |
| Signal TTL | 3 min | Stale pins vanish |
| Camp memory | 30 min | Same as today |
| Max pins per zone | 12 | Cap map clutter |
| Payload size | &lt; 250 bytes | WoW addon message limit |
| Share cooldown | 8 s | Per player, all outbound types |

If the channel is busy, drop **oldest** signals first; never queue unbounded work on `CHAT_MSG_ADDON`.

## Wire format (community channel)

Hidden channel: `SmoreSkills`. Prefix: `SmoreSk`. Same faction only.

| Type | Purpose | Shape (concept) |
| --- | --- | --- |
| `C:` | Legacy / manual camp snapshot | `C:map:x:y:fac:own:p1:o1:p2:o2:p3:o3:t` |
| `S:` | Seeker — looking in zone | `S:map:fac:prof:t` |
| `H:` | Host — at fire, wants company | `H:map:x:y:fac:own:want:p1:o1:p2:o2:p3:o3:t` |

- `want` = `any` or profession codes (`bs,lw,tail`, …)
- `prof` = seeker's primary profession code
- `t` = unix timestamp
- Coords use the same fixed-point wire encoding as `C:`

Implement **S** and **H** when building the next slice. **C** stays for backward compatibility and manual shares.

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
| Sit at a campfire | Stand at an agreed spot (inn fire, quest flame, any landmark) |
| Place BS anvil in slot 1 | Host sets slot 1 to Blacksmithing in the UI (or `/smores slot 1 bs`) when we add it |
| “Find camps in zone” | `/smores find` or map button → seek ping |
| “Open camp for visitors” | `/smores host` at your coords |

### Two-client smoke test (Ashenvale)

1. Deploy to `_anniversary_`: `.\scripts\deploy-to-wow.ps1 -Client anniversary`
2. Enable **Load out of date Addons** if needed; `/reload`
3. **Host** (dwarf): `/smores host` — or `/smores here` until host ships
4. **Seeker** (night elf), same zone: `/smores find` — or open window after seek ships
5. Confirm seeker sees host pin/list entry; opposite faction does not
6. Hammer seek repeatedly — cooldown message, no hitch

### Shipped (v0.5.7) vs Forever beta

| Feature | v0.5.7 (TBC testbed) | Forever beta |
| --- | --- | --- |
| `/smores here` camp ping (`C:`) | Yes | Kept |
| Seeker signal `S:` (`/smores find`, minimap, map button) | Yes | Same |
| Host signal `H:` (`/smores host`) | Yes | Same + auto-host setting |
| Manual slot edit (`/smores slot`) | Yes | Auto from game API |
| Client-side matching + rate limits | Yes | Same |
| Map bonfire pin + three socket art | Yes | Same art; verify coords API |
| Custom camp hover tooltip | Yes | Same |
| Settings popup (Host/Seeker filters) | Yes | Same |
| Minimap fire icon | Yes | Same |
| Auto-read placed objects | No | When API exposed |
| Pins at continent/world zoom | No | Optional later |
| Occupancy: sitters vs object slots | Host broadcasts state | May need extra `H:` field |

---

# Host-only broadcast (design note)

If **only the host** has the addon, guests cannot update camp state — the host must rebroadcast slot fills and empties. Seekers with the addon see `N/3` from the host ping when slot data is included.

**Heads at fire** (how many players are sitting) and **three object slots** may differ. Do not extend the wire format for sitter count until Forever beta exposes a reliable API (e.g. `sit` on `H:`).

---

# Later (Forever beta onward)

- Read campfire / placed-object API when exposed
- Fill a slot automatically when you place an object
- Project pins when map is zoomed to continent/world
- Occupancy: sitters at fire vs three object slots (different numbers)
