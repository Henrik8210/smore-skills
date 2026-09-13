# WoW Forever — beta notes

Reference for **Forever beta** (opens **17 Sep 2026**). TBC Anniversary remains the day-to-day testbed until then.

**Release policy:** code is on GitHub at v0.5.7. **No CurseForge publish** until beta smoke test passes.

Screenshots from the pre-beta client (Sep 2026) show how the **world map** differs from retail and from TBC Anniversary.

---

## Install

```powershell
.\scripts\deploy-to-wow.ps1 -Client forever
```

After first login on Forever:

1. Read `## Interface:` from `_forever_\Interface\FrameXML\FrameXML.toc` (or equivalent).
2. Update `SmoreSkills/SmoreSkills.toc` `## Interface:` line to match.
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
| **Pin visibility** | Pins only when `WorldMapFrame:GetMapID()` equals `camp.mapId` (zone id). | At **World** or **Continent** zoom, pins may **not** show — expected until we add parent-map projection. |
| **Find button** | Anchored to map canvas (`ScrollContainer` / `GetCanvas()`). | Confirm button still visible at zone + continent + world. |
| **Map hooks** | `OnShow`, `OnMapChanged`, canvas `OnSizeChanged`. | Log `GetMapID()` at each breadcrumb level; note ids for test zones. |
| **Camp tooltip** | Custom frame (not GameTooltip): opaque dialog background, three circular gold-ring profession sockets. | Verify TBC-safe color APIs still work; no silent fallback to text-only tooltip. |
| **Seek pulse** | Find button and minimap fire icon fade while seeking. | Confirm animation on Forever map frame. |
| **New zones** | — | Names like **Zephras Isle** may not exist on TBC — verify `C_Map.GetBestMapForUnit("player")` returns stable ids. |

---

## Camping (Forever vs TBC)

| | TBC Anniversary | Forever |
| --- | --- | --- |
| Basic campfire / campsite | **Not in game** | Real mechanic (see [CAMPING.md](CAMPING.md)) |
| Three object slots | Manual `/smores slot` | Auto-read when API exposed |
| Auto host on campfire | Setting saved; manual `/smores host` on TBC | Toggle in minimap settings → General |
| Profession specs | TBC specs mapped (Spellfire → Tailoring, etc.) | Re-verify when Forever skill names are known |
| Who updates camp state | Host rebroadcasts (guests without addon cannot) | Host + addon users at fire when API allows |

---

## Thursday beta smoke test (checklist)

Use **two same-faction characters** in the **same zone**.

### Setup

- [ ] Deploy: `.\scripts\deploy-to-wow.ps1 -Client forever`
- [ ] Fix `## Interface:` in toc if addon is red
- [ ] `/reload` both clients
- [ ] Set professions: `/smores prof alch` / `/smores prof tail` (or your trades)
- [ ] Confirm minimap fire icon (cropped s'more art); right-click opens **S'more skills settings** (General / Host / Seeker tabs)

### Map & pins

- [ ] Open **zone** map (not only World/continent)
- [ ] Host: `/smores host` at a campfire (or stand-in spot if fires are scarce)
- [ ] Seeker: left-click minimap icon or map **Find** button (or `/smores find`)
- [ ] Bonfire pin appears at host coords on **zone** map
- [ ] Hover pin: custom tooltip with host line, three gold-ring sockets (filled/empty), coords
- [ ] Minimap and Find button pulse while seeking
- [ ] Right-click map Find button clears pins
- [ ] Zoom out to continent/world — note whether pins hide (document map ids)

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
Zone name / mapId at camp: 
World mapId: 
Continent mapId: 
Pin visible at zone? Y/N
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
