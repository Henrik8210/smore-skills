Paste into CurseForge → Description (Markdown mode).

---

**S'more Skills** helps you find **campsites** on **World of Warcraft: Forever** while you level.

When someone lights a fire, same-faction players can sit down and place up to **three** profession objects (a sharpening wheel, a banner, incense, and more). This addon is **community-driven**: anyone with it enabled can share a fire so others can show up, fill a slot, and meet people.

You choose when to share. Nothing is dumped on login. Guild chat is not used — a small **G** on a pin only means a guildie is at that camp.

## How it works

**Seek** — click the S'more on the **world map** (or `/smores find`). That looks for open camps in your zone.

**Host** — light a campfire with Auto host on, or `/smores host`. Seekers in the zone can then see your pin. You host **one camp at a time**. Walk away and the pin stays on the fire until it expires, fills, or you pack up.

The addon reads **this character’s professions** from the skill list. If you have Leatherworking, hosts who asked for leatherworkers can find you — you do not have to tick it yourself.

A host can optionally limit who sees the camp (specific professions, and optionally up to three items). Filter on with **nothing** ticked means nobody sees you. Item picks left empty still mean any item.

## What you see

* A bonfire pin on the **zone** map — **hosts only**. Seekers do not get a pin of their own.
* How full the fire is (`1/3`, `2/3`, `3/3`)
* Three sockets: profession (and object when known), or a faded S'more if empty
* Host name, coords, and a guild mark if a guildie is there

Hover a pin for the full tooltip (coords, layer, slots). Left-click another player's pin to whisper them for an invite. Right-click **your** pin to pack up (you will be asked to confirm). Right-click Find to clear other people’s markers; your hosted pin stays.

## Settings

`/smores` (also `/sms` or `/smoreskills`) opens settings.

* **General** — auto-host when you light a campfire, pin size, minimap button, chat messages, guild mark
* **Host** — profession you are using at this camp, who may see you, optional items you want brought
* **Seeker** — which camps you want to find (professions and optional items)

The minimap S'more opens the world map (left-click) and settings (right-click).

## Commands

| Command | Action |
| --- | --- |
| `/smores`, `/sms`, `/smoreskills` | Open settings |
| `/smores find` | Look for camps in this zone |
| `/smores host` | Share your campfire with seekers |
| `/smores stop` | Stop hosting |
| `/smores pack` | Pack up your camp (same confirm as the map pin) |
| `/smores status` | Channel, hosting, and seeking status |
| `/smores list` | List visible hosted camps in this zone |

## Notes

* Same faction only
* Map pins are hosted camps only
* One camp at a time — wait for it to expire, or pack up, before hosting another
* All opt-in. No login dump of stored camps

---

**Developed by** Nobunda
