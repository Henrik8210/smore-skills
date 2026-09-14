# S'more Skills — dev guidelines

Forever camping finder. Protocol and UX are documented in [CAMPING.md](CAMPING.md).

- **Remote:** https://github.com/Henrik8210/smore-skills
- **Addon folder:** `SmoreSkills/` (no apostrophe — WoW toc/folder rule)
- **Title:** S'more Skills
- **Version:** 0.5.9 (GitHub only until Forever beta validates — **no CurseForge tag yet**)

## WoW install paths

| Client | Folder | Interface (Sep 2026) |
| --- | --- | --- |
| **TBC Anniversary** (testbed) | `_anniversary_\Interface\AddOns\` | `20505`, `20506` |
| **Forever** (beta 17 Sep) | `_forever_\Interface\AddOns\` | TBD from `FrameXML.toc` |

```powershell
# Testing on TBC Anniversary (default until Forever beta)
.\scripts\deploy-to-wow.ps1 -Client anniversary

# Forever when the client exists
.\scripts\deploy-to-wow.ps1 -Client forever
```

After Forever beta lands: read `## Interface:` from the client’s `FrameXML.toc`, update `SmoreSkills.toc`, and re-test map hooks. **Forever world map layout and Thursday smoke test:** [FOREVER.md](FOREVER.md).

## Source layout

| File | Role |
| --- | --- |
| `Core.lua` | Version, constants, saved vars, init |
| `Camps.lua` | Camp cache, matching, profession detection |
| `Sync.lua` | Channel join, seek/host/share, rate limits |
| `Map.lua` | World map pins, Find button, custom camp tooltip |
| `Settings.lua` | Minimap button, settings popup (General / Host / Seeker) |
| `UI.lua` | Legacy camp list window (minimal; camps live on map) |
| `Commands.lua` | Slash commands |
| `Art/` | `SmoreSkillsLogo` (512, addon list) + `SmoreSkillsIcon` (64, minimap/settings — sized for small circular frames) |

Logo paths: `SmoreSkills.LOGO` (full art), `SmoreSkills.ICON` (cropped, minimap/map/pins).

## Commands

| Command | Action |
| --- | --- |
| `/smores`, `/sms`, `/smoreskills` | Toggle settings popup |
| `/smores here` | Share camp snapshot at your location |
| `/smores list` | Print stored camps |
| `/smores find` | Seek camps in zone |
| `/smores host` | Host signal at your location |
| `/smores stop` | Stop hosting rebroadcasts |
| `/smores status` | Channel, hosting/seeking, trades, zone, map view |
| `/smores slot 1 bs` | Set object slot (TBC testing) |
| `/smores prof lw` | Set profession for matching |
| `/smores want any` | Professions host accepts |
| `/smores test on\|off` | Toggle Ashenvale sample camp on seek |

## TBC Anniversary testing

TBC has no camping. Use two characters in the **same zone and faction** (e.g. Ashenvale):

1. Deploy with `-Client anniversary`
2. **Host:** light **Basic Campfire** (Auto host on) or `/smores host` at a landmark (or `/smores here` for a camp snapshot)
3. **Seeker:** map Find button or `/smores find` (minimap icon only opens the world map)
4. Confirm bonfire pin on **zone** map; hover shows three sockets (faded S'more if empty)
5. Verify opposite faction does not see the ping
6. Verify cooldowns (see [CAMPING.md](CAMPING.md) load limits)
7. Host walks away — pin stays on the fire; seeker Find still works
8. Elwynn: Stormwind in the corner is still the Elwynn map — pin must show. `/smores status` if it does not.
9. Use `/smores slot 1 bs` etc. to simulate filled object slots

Optional: `/smores test on` injects a sample Ashenvale camp when seeking (single-client smoke test).

## CurseForge release

**Hold until Forever beta works.** Do not tag or publish until the user explicitly asks after beta validation.

Publishing is **GitHub Actions**, not the CurseForge webhook.

1. Create a **new** CurseForge project for S'more Skills.
2. Put `## X-Curse-Project-ID:` in `SmoreSkills/SmoreSkills.toc`.
3. Add GitHub secret **`CF_API_KEY`** (authors.curseforge.com → API tokens). Never paste the token in chat.
4. Leave the GitHub → CurseForge webhook **inactive**.
5. Push a version tag (`v0.1.0`) → `.github/workflows/release.yml` → `BigWigsMods/packager@v2`.

Pushing `main` is not a release. Do not delete/re-push tags — bump the patch.

### Agent checklist (only when the user asks to publish)

1. Bump toc `## Version:` and `SmoreSkills.VERSION`.
2. Add `## vX.Y.Z` to `CHANGELOG.md`.
3. Commit and push `main`.
4. `git tag v<version>` and `git push origin v<version>`.
5. Confirm Actions **Release** succeeded; check CurseForge **Files**.

`.pkgmeta` uses `move-folders` (no flatten). `.pkgmeta` must be UTF-8 without BOM.

## Sync

See [CAMPING.md](CAMPING.md) and `.cursor/rules/camp-sync.mdc`. Hidden community channel (`SmoreSkills`). Same faction. Three slots. Share is opt-in. Do not dump on login. Guild mark is optional.
