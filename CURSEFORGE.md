Paste into CurseForge → Description (Markdown mode).

---

**S'more Skills** helps you find **campsites** on **World of Warcraft: Forever** while you level.

When someone lights a fire, same-faction players can sit down and place up to **three** profession objects (a sharpening wheel, a banner, incense, and more). This addon is **community-driven**: anyone with it enabled can share a fire so others can show up, fill a slot, and meet people.

You choose when to share. Nothing is dumped on login. Guild chat is not used — a small **G** on a pin only means a guildie is at that camp.

## How it works

**Seek** — click the S'more on the **world map** (or `/smores find`). That looks for open camps in your zone.

**Host** — light a campfire with Auto host on, then click **Find** or `/smores host` once so others can see the pin. You host **one camp at a time**. A new fire packs the old pin. Walk away and the pin stays on that fire until it expires, fills, you pack up, or you light another.

The addon reads **this character’s professions** from the skill list. If you have Leatherworking, hosts who asked for leatherworkers can find you — you do not have to tick it yourself.

A host can optionally limit who sees the camp (specific professions, and optionally camping objects). Filter on with **nothing** ticked means nobody sees you. Object picks left empty still mean any object. The camp panel can change that for the fire you have up now without editing Host settings.

## What you see

* A bonfire pin on the **zone** map — **hosts only**. Seekers do not get a pin of their own.
* How full the fire is (`1/3`, `2/3`, `3/3`)
* Three sockets: camping **object** when named (your faction’s banner, not a generic Alliance flag), or a faded S'more if empty
* Host name, coords, and a guild mark if a guildie is there

Hover a pin for the full tooltip (coords, layer, slots, objects the host wants). Left-click **your** pin (or `/smores camp`) for the host camp panel. Left-click another player's pin to whisper them. Right-click **your** pin to pack up (you will be asked to confirm). Right-click Find to clear other people’s markers; your hosted pin stays.

## Settings

`/smores` (also `/sms` or `/smoreskills`) opens settings.

* **General** — auto-host when you light a campfire, pin size, minimap button, chat messages, guild mark
* **Host** — defaults when you host (profession, who may see you, optional objects). The camp panel can override this fire only.
* **Seeker** — which camps you want to find (professions and optional objects)

The minimap S'more opens the world map (left-click) and settings (right-click).

## Commands

| Command | Action |
| --- | --- |
| `/smores`, `/sms`, `/smoreskills` | Open settings |
| `/smores find` | Look for camps in this zone |
| `/smores host` | Share your campfire with seekers |
| `/smores camp` | Open the host camp panel (sockets + this-camp requests) |
| `/smores stop` | Stop hosting |
| `/smores pack` | Pack up your camp (same confirm as the map pin) |
| `/smores status` | Channel, hosting, and seeking status |
| `/smores list` | List visible hosted camps in this zone |

## Notes

* Same faction only
* Map pins are hosted camps only
* One camp at a time — a new fire replaces the old pin; or pack up / wait for expiry
* After you light a fire, click **Find** (or `/smores host`) once so the pin is actually shared
* All opt-in. No login dump of stored camps

---

**Developed by** Nobunda
