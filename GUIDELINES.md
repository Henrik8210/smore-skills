# S'more Skills — dev guidelines

Forever camping finder. Protocol and UX are documented in [CAMPING.md](CAMPING.md). Host pin across `/reload`: [HOST-PERSIST.md](HOST-PERSIST.md).

- **Remote:** https://github.com/Henrik8210/smore-skills
- **Addon folder:** `SmoreSkills/` (no apostrophe — WoW toc/folder rule)
- **Title:** S'more Skills
- **Version:** 0.6.8 (CurseForge beta `v0.6.8-beta`; last full tag `v0.5.62` for **WoW Forever 1.60.1**)

## WoW install paths

| Client | Folder | Interface (Sep 2026) |
| --- | --- | --- |
| **TBC Anniversary** (testbed) | `_anniversary_\Interface\AddOns\` | `20505`, `20506` |
| **Forever** (beta 17 Sep) | `_classic_beta_\Interface\AddOns\` | `16001` (game 1.60.1); keep `20505`/`20506` for Anniversary. Battle.net product is `wow_classic_beta` — there is no `_forever_` folder. |

```powershell
# Forever (product)
.\scripts\deploy-to-wow.ps1 -Client forever

# Anniversary — two-client share only
.\scripts\deploy-to-wow.ps1 -Client anniversary
```

After Forever beta lands: read `## Interface:` from the client’s `FrameXML.toc`, update `SmoreSkills.toc`, and re-test map hooks. Forever uses the **retail/Mainline addon API** (Midnight-style restrictions), not Classic — see [FOREVER.md](FOREVER.md). **Forever world map layout and Thursday smoke test:** [FOREVER.md](FOREVER.md).

## Source layout

| File | Role |
| --- | --- |
| `Core.lua` | Version, constants, saved vars, init |
| `Camps.lua` | Camp cache, matching, profession detection |
| `Sync.lua` | Channel join, seek/host/pack, rate limits |
| `Map.lua` | World map pins, Find button, custom camp tooltip |
| `Settings.lua` | Minimap button, settings popup (General / Host / Seeker) |
| `HostPanel.lua` | Host camp panel (sockets + this-camp request chips) |
| `UI.lua` | Legacy camp list window (minimal; camps live on map) |
| `Commands.lua` | Slash commands |
| `Art/` | `SmoreSkillsLogo` (512, addon list) + `SmoreSkillsIcon` (64, minimap/settings — sized for small circular frames) |

Logo paths: `SmoreSkills.LOGO` (full art), `SmoreSkills.ICON` (cropped, minimap/map/pins).

## Commands

| Command | Action |
| --- | --- |
| `/smores`, `/sms`, `/smoreskills` | Toggle settings popup |
| `/smores list` | Print visible hosted camps in this zone (max 12, same as map pins) |
| `/smores find` | Seek camps in zone |
| `/smores host` | Re-share the current fire (walk-away keeps those coords) |
| `/smores host basic` / `journeyman` / `expert` | Test 3 / 5 / 10 sockets (`jm` / `exp`) |
| `/smores camp` | Host camp panel (sockets + this-camp requests) |
| `/smores stop` | Stop hosting rebroadcasts |
| `/smores pack` | Pack up your camp (same Yes/No confirm as the map pin) |
| `/smores status` | Channel, hosting/seeking, trades, zone, map view |
| `/smores slot 1 bs` | Set object slot (TBC testing) |
| `/smores prof lw` | This session only (testing). Reload uses learned trades |
| `/smores want any` | Professions host accepts |

## TBC Anniversary testing

TBC has no camping. Use two characters in the **same zone and faction** (e.g. Ashenvale):

1. Deploy with `-Client anniversary`
2. **Host:** light **Basic Campfire** (Auto host on) or `/smores host` at a landmark
3. **Seeker:** map Find button or `/smores find` (minimap icon only opens the world map)
4. Confirm bonfire pin on **zone** map; hover shows three sockets (faded S'more if empty)
5. Verify opposite faction does not see the ping
6. Verify cooldowns (see [CAMPING.md](CAMPING.md) load limits)
7. Host walks away — pin stays on the fire; seeker Find still works
8. Elwynn: Stormwind in the corner is still the Elwynn map — pin must show. `/smores status` if it does not.
9. Use `/smores slot 1 bs` etc. to simulate filled object slots

## CurseForge release

**Hold a full (non-beta) CurseForge release until Forever beta works**, unless the user explicitly asks to publish.

Publishing is **GitHub Actions**, not the CurseForge webhook.

1. Create a **new** CurseForge project for S'more Skills.
2. Put `## X-Curse-Project-ID: 1696940` in `SmoreSkills/SmoreSkills.toc`.
3. Add GitHub secret **`CF_API_KEY`** (authors.curseforge.com → API tokens). Never paste the token in chat.
4. Leave the GitHub → CurseForge webhook **inactive**.
5. Push a version tag (`v0.5.49-beta`) → `.github/workflows/release.yml` zips with packager, then uploads to CurseForge as **WoW Forever 1.60.1**.
6. Tag name containing **`beta`** uploads as a CurseForge **beta** file. Plain `v0.5.49` is a full release. Packager alone would mark Interface 20505 as TBC 2.5.x, so Forever uses the extra upload step.

Pushing `main` is not a release. Do not delete/re-push tags — bump the patch.

### Agent checklist (only when the user asks to publish)

1. Bump toc `## Version:` and `SmoreSkills.VERSION`.
2. Add `## vX.Y.Z` to `CHANGELOG.md`.
3. Commit and push `main`.
4. `git tag v<version>` and `git push origin v<version>`.
   Include **`beta` in the tag** (`v0.5.48-beta`) for a CurseForge beta file; a plain `v0.5.48` is a full release.
5. Confirm Actions **Release** succeeded; check CurseForge **Files**.

`.pkgmeta` uses `move-folders` (no flatten). `.pkgmeta` must be UTF-8 without BOM.

## Sync

See [CAMPING.md](CAMPING.md), [HOST-PERSIST.md](HOST-PERSIST.md), and `.cursor/rules/camp-sync.mdc`. Hidden community channel (`SmoreSkills`). Same faction. Three slots. Share is opt-in. Do not dump on login. Guild mark is optional.
