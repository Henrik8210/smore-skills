# S'more Skills — dev guidelines

Forever camping finder. Not Guildie Crafts.

- **Remote:** https://github.com/Henrik8210/smore-skills
- **Addon folder:** `SmoreSkills/` (no apostrophe — WoW toc/folder rule)
- **Title:** S'more Skills
- **TBC workshops:** https://github.com/Henrik8210/guildie-crafts (frozen)
- **Forever workshops:** https://github.com/Henrik8210/guildie-crafts-forever

## WoW install path

`C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\`

Confirm the client folder and `## Interface:` from Forever `FrameXML.toc` before a CurseForge upload. `11509` is a Classic Era placeholder.

```powershell
.\scripts\deploy-to-wow.ps1
```

## Commands

| Command | Action |
|---------|--------|
| `/smores`, `/sms`, `/smoreskills` | Toggle the window |
| `/smores here` | Pin and share a camp at your position |
| `/smores ask` | Ask the guild for camps they have |
| `/smores list` | Print stored camps |

## CurseForge release

Publishing is **GitHub Actions**, not the CurseForge webhook.

1. Create a **new** CurseForge project (do not reuse Guildie Crafts).
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

See [CAMPING.md](CAMPING.md) and `.cursor/rules/camp-sync.mdc`. Guild addon messages only. Same faction. Three slots. Rate-limit shares.
