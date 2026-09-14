# S'more Skills

Find **WoW Forever** campsites while you level: see fires near you, which of the **three object slots** are filled, and whether your profession is useful there.

**Testing now:** TBC Anniversary (`_anniversary_`) until Forever beta (17 Sep). Cooking **Basic Campfire** is a **placeholder** host ping (not a Forever campsite). See [CAMPING.md](CAMPING.md). **Forever map UI + beta checklist:** [FOREVER.md](FOREVER.md).

**CurseForge:** project exists but **no public release yet** — we validate on Forever beta first. When ready: `CF_API_KEY` secret + version tag via GitHub Actions (webhook stays off). See [GUIDELINES.md](GUIDELINES.md).

## The idea

You're a leatherworker in Ashenvale and want buffs. You click the map **Find campsites in this zone** button — that sends a **seek signal** only other addon users receive.

Meanwhile a blacksmith sits alone at a fire across the zone and sends a **host signal** (*open for company*). When you match (same faction, same zone, room for your trade), a **map pin** appears: bonfire with **three circular sockets** (filled or empty). Hover shows host, open spots, and coords. You see Blacksmithing in slot 1, two open, and know to hurry before other seekers do.

All opt-in. No login dump. Community channel, not guild chat.

## Status (v0.5.9)

| | |
| --- | --- |
| **Sync** | Seek/host/camp/pack (`S:` / `H:` / `C:` / `X:`), matching, rate limits, same-faction filter. Host keeps the **fire coords** if you walk away. |
| **Map** | Zone pins (bonfire + sockets), Find button, custom hover tooltip, seek fade pulse. Nested city maps (Elwynn/Stormwind) still draw zone pins. |
| **Minimap** | S'more icon opens world map; right-click settings; drag to move |
| **Settings** | General: auto-host on Basic Campfire (placeholder). Host/Seeker profession grids |
| **Professions** | Auto-detect all trades; TBC specs map to base (Spellfire → Tailoring, etc.) |
| **Art** | Forever-style logo (`SmoreSkillsLogo`) + cropped icon (`SmoreSkillsIcon`) |
| **Forever beta** | Real campfire/object API, auto-fill slots, continent/world pin projection |

## UI

| Control | Action |
| --- | --- |
| **Minimap (S'more icon)** | Left-click: open world map. Right-click: settings. Drag: reposition. |
| **Map Find button** | Left-click: seek in zone (switches to your zone map). Right-click: clear **other** pins; your hosted pin stays. |
| **Own camp pin** | Right-click: pack up (confirm). Seekers drop it via `X:`. |
| **Settings popup** | General: auto-host when lighting **Basic Campfire** (placeholder until Forever API). Host/Seeker profession grids. |
| **Camp pin hover** | Custom tooltip: host, three gold-ring sockets (profession or faded S'more if empty), coords, guild hint if applicable. |

## Commands

| Command | Action |
| --- | --- |
| `/smores`, `/sms`, `/smoreskills` | Toggle settings popup |
| `/smores here` | Share camp snapshot at your location |
| `/smores list` | Print stored camps |
| `/smores find` | Seek camps in this zone |
| `/smores host` | Signal you're at a fire and want company |
| `/smores stop` | Stop hosting rebroadcasts |
| `/smores status` | Channel, hosting/seeking, trades, zone, map view |
| `/smores slot 1 bs` | Set slot 1 (TBC testing) |
| `/smores prof lw` | Set profession used for seeker matching |
| `/smores want any` | Host accepts any profession |
| `/smores test on\|off` | Toggle Ashenvale sample camp on seek (TBC testbed) |

## Deploy

**TBC Anniversary (testing):**

```powershell
.\scripts\deploy-to-wow.ps1 -Client anniversary
```

**Forever (when beta client exists):**

```powershell
.\scripts\deploy-to-wow.ps1 -Client forever
```

Then `/reload` in game. Character select → **Load out of date AddOns** if the toc Interface is behind the client.

## License

Personal / guild use.
