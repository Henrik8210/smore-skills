# S'more Skills

Find **WoW Forever** campsites: where the fire is, which of the **three object slots** are filled, and which professions set them up.

Not Guildie Crafts. Workshops stay in [guildie-crafts-forever](https://github.com/Henrik8210/guildie-crafts-forever).

**CurseForge:** new project + `CF_API_KEY` secret + version tag. Webhook stays off. See [GUIDELINES.md](GUIDELINES.md).

## 0.1.0

- Share a camp at your position (`/smores here`)
- Guild sync of map, coordinates, faction, and three profession slots
- Same-faction list in `/smores`
- Manual pin until beta lets us read campfires

## Commands

| Command | Action |
|---------|--------|
| `/smores`, `/sms`, `/smoreskills` | Toggle the window |
| `/smores here` | Pin and share this spot |
| `/smores ask` | Ask the guild for camps |
| `/smores list` | Print stored camps |

```powershell
.\scripts\deploy-to-wow.ps1
```

## License

Personal / guild use.
