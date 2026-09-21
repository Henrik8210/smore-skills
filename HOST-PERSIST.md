# Hosted camp across `/reload`

If the pin vanishes after `/reload` while the fire is still on the ground, **do not** treat it as “we forgot to save.” On Forever the files on disk are usually fine. Live WTF (Barrens `1413:0.646:0.484`, remaining 1175) has proven that. After `/reload` the client often **does not put the nested tables back into memory**, restore may rebuild the camp **without an owner** (short CVar `HPc1`), and `GetOwnedActiveCamp()` then returns nil because `UnitName` is still `Unknown` or `No Bunda` ≠ `No-Bunda`. Creating an empty `SmoreSkillsDB` before the SavedVariables file runs makes Forever **skip the file** (HP blob never loads). Own-pin remaining after a live restore counts down with `GetTime()` so a jumped `GetServerTime()` cannot hide it.

Verified live **18 Sep 2026** on `_classic_beta_` (Zephras Isle, Horde **No Bunda**): kit **Use**, `/smores host`, and `/reload` keep the pin; **Create** kit does not host (**v0.5.77**). An hour-old leftover pin must not come back as a new 15 minutes (**v0.5.78**, TTL later measured **15 min**). Settings persist: **v0.6.3**. Camp-panel `/1` announce: **v0.6.7**.

## What you will see

| Clue | Meaning |
| --- | --- |
| Chat: `Host a camp first` | `SmoreSkills_GetOwnedActiveCamp()` is nil. Restore never rebuilt the camp in RAM. |
| Chat: `Your campfire in … is still yours (N min left)` | Restore worked. If the pin is still missing, it is map drawing, not save/restore. |
| Explorer: `WTF\…\SavedVariables\SmoreSkills.lua` still has the camp | Save worked. The bug is **load** or **TTL**, not write. |
| Nested `["camps"] = { … }` on disk, empty `camps` in `/reload` | Forever dropped the nested table on load. This is the usual case. |
| Own pin comes back **more than 15 min** after you left | Stale snapshot. `remaining` was restored as-is (v0.5.77). v0.5.78 subtracts realm time since `clock`. |

Do not “fix” this by writing a richer nested camp into `SmoreSkillsDB.camps`. That is what v0.5.68 tried. The nested table is written and then comes back empty.

## Three separate failure modes

### 1. Nested SavedVariables do not load

`SmoreSkillsDB.camps` is a nested map of camp tables (slots, owner, coords). Forever writes it. After `/reload` it is often **missing in memory** even though the `.lua` file still has it.

`## SavedVariablesPerCharacter: SmoreSkillsHostDB` is the flat per-character snapshot. The file exists under `WTF\Account\<id>\<realm>\<char>\SavedVariables\SmoreSkills.lua`. After `/reload` that global is often **`{}`** anyway.

**What does load:** top-level primitives on the **account** table `SmoreSkillsDB` — settings, `hostCampId`, `hostSnapRemaining`, `hostSnap_mapId`, `hostSnap_x`, …

**v0.5.88:** write the same `HPv1|…` blob to five places. Restore uses the first that loads.

| Channel | Where | Why |
| --- | --- | --- |
| `SmoreSkillsHP` | Account SavedVariables string | Separate global; never created empty |
| `SmoreSkillsDB.hp` | Account table | Same file as settings |
| `settings.hp` | Inside the settings table | That table has been coming back |
| CVar `SmoreSkillsHP` | `config-cache.wtf` | Game config, not addon SV |
| Macro `S~Camp` | Character macros | Independent of addon SavedVariables |

**Rule:** persist the hosted fire as **flat account fields**. Restore from those. Then copy into `SmoreSkillsDB.camps` for the rest of the session.

`hostCampId` is already `mapId:x:y` (`2521:0.599:0.650`). If the `hostSnap_*` coords are missing, parse that string.

### 2. Two clocks (Denmark vs US realm)

The realm is in the US. The PC may be in Denmark (~9 hours). That gap is larger than the **15 minute** pin TTL.

| API | What it is |
| --- | --- |
| `GetServerTime()` | Realm wall clock as a number. US realm 2pm vs Denmark 11pm is a **9 hour** gap. Use it for **other people’s** `H:` stamps only. |
| `time()` | PC unix time. Never use it for camp TTL. |
| `GetTime()` | Client uptime. **Not** used for owned-pin TTL (it fought `GetServerTime()` in WTF). |

While you play, hosting uses `GetServerTime()` consistently, so the pin is fine. After `/reload`, a fallback to `time()` makes “now” 21:12 and “lit at” 12:12. Age ≈ 9 hours → pin looks burned out.

`GetServerTime()` can also be **0** (or milliseconds) at login. Writing `litAt = now - elapsed` then stores a **negative** time. Every later check with a real clock treats the fire as years old.

**Rule:** camp TTL for *your* fire is **seconds remaining**, counted down on the **realm clock**.

- On snapshot: store `remaining` and `clock` (`GetServerTime()`), plus `hostSnapRemaining` / `hostSnap_clock`.
- On restore: `left = remaining - (now - clock)` when both times are the same scale (unix seconds). `/reload` a few seconds later keeps ~the same remaining. Logout for an **hour** → left ≤ 0 → **do not restore**, clear the snapshot.
- If `now` is 0 or one stamp is milliseconds and the other is seconds, do **not** treat that as an hour passing — keep `remaining` (that is the `/reload` clock-unit jump).
- After a live restore, count down with `GetTime()` for the rest of this session (`Sync.hostRemainAt`).
- `SmoreSkills_Now()` is `GetServerTime()` only. Never fall back to `time()`.
- Never gift a full 15 minutes because `now - litAt` looks “insane.” That is how an hour-old camp came back as **Your campfire … (15 min left)**.

Other people’s pins can still use `litAt` vs `GetServerTime()` — those stamps come from the wire in the same session.

### 3. Create kit vs Use kit

Cooking **Create** (Basic Campfire Kit) and **Use** (place the fire) share a cast name / spell id on Forever (`1229737`, bar often says “Basic Campfire”).

**Rule:** profession window open at `UNIT_SPELLCAST_START` → craft, ignore. Window closed → place, host. Do not host from Create. Do not skip Use because the craft fix was too broad. Spell handlers stay tiny (no bag scan, no `C_Timer` from the event — queue on the outbound pump) or Forever taints (*Interface action failed*).

## Working snapshot (v0.5.78)

Write on host, slot change, `ReloadUI` hook, and `PLAYER_LOGOUT`:

- Per-character `SmoreSkillsHostDB` — flat primitives (keep writing; harmless if load fails).
- Account `SmoreSkillsDB.hostCampId`
- Account `SmoreSkillsDB.hostSnapRemaining`
- Account `SmoreSkillsDB.hostSnap_*` — `mapId`, `x`, `y`, `zone`, `owner`, `fireType`, slots `p1`/`o1`/`n1` through `p10`/`o10`/`n10`, …

Restore on `ADDON_LOADED`, `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, and a few delayed retries:

1. `SmoreSkillsHostDB` if it has coords.
2. Else `ReadAccountHostSnap()` (`hostSnap_*` + `hostSnapRemaining`).
3. Else parse `hostCampId`.

Rebuild the in-memory camp, set session remaining from `GetTime()`, then draw the pin. Chat **Your campfire in \<zone\> is still yours** only after `Sync:RestoreHostSession()` actually succeeds.

Clear the snapshot on **pack-up** or when realm time says the 15 minutes are gone (`remaining - (now - clock) <= 0`). Do not restore a leftover snapshot an hour later as a fresh 15-minute pin. A failed restore or a 3/3 camp must not wipe a still-live snapshot.

This does **not** auto-broadcast stored camps on login. The pin is **local**. `H:` still waits for Find or `/smores host`.

## Never

- Trust `SmoreSkillsDB.camps` after `/reload` as the source of truth.
- Mix `time()` and `GetServerTime()` for pin TTL.
- Rewrite `litAt` from a `0` clock.
- Expire an owned fire because `now - litAt` is hours **and** the clocks are different units (ms vs sec). Same-scale realm time an hour later **does** expire it.
- Treat a ~9 hour Denmark-vs-US gap as burnout. That is a clock jump; keep saved `remaining`. When `litAt` and `now` are the same clock and the age is inside a real 15-minute fire, remaining is `duration - age`. Do not stamp `litAt = now` on restore (that is a fresh 15 min pin). CVar/macro store a short `HPc2` clock blob so `litAt` and sockets are not truncated.
- Wipe `HostDB` when restore returns “no saved campfire” or “waiting for clock”.
- Clear the snapshot from `Sync:IsHosting()` (a getter). Session `GetTime()` must not burn a live realm remaining.
- Wipe `HostDB` before the replacement `remaining` is known.
- Drop an owned camp from RAM because it is full, or because `CampPinActive` flickered at login.
- Require `UnitName` to match `camp.owner` before `GetOwnedActiveCamp()` returns the `hostCampId` fire (CVar restore has no owner; login name is often `Unknown`).
- Create an empty `SmoreSkillsDB` / `SmoreSkillsHP` / `SmoreSkillsHostDB` before SavedVariables apply. `EnsureSettings` must not assume the table exists; pack-up leaves no persist blob and login can run first.
- Restore from short `HPc1` (CVar/macro) without sockets. Use `HPc2` (remaining + item-id sockets). Do not snapshot during restore, and do not apply the default host profession from a heartbeat — that overwrites First Aid Kit / Mana Well with “You”.
- Leave a burned-out owned pin in SavedVariables. When remaining hits 0, pack locally and clear the snapshot (do not `SendChatMessage` `X:` from the timer).
- Host when the profession window is open (Create kit).
- Call `C_Timer.After` / bag scans / `SendChatMessage` from `UNIT_SPELLCAST_*`.
- Delete and re-push a CurseForge tag to retry a persist fix — bump the patch.

## Code

| | |
| --- | --- |
| Snapshot / restore / flat keys | `SmoreSkills_SnapshotOwnedHost`, `SmoreSkills_RestoreOwnedHost`, `WriteAccountHostSnap` in `Camps.lua` |
| Session remaining | `SmoreSkills_OwnedHostRemaining`, `Sync.hostRemainAt` |
| Clock | `SmoreSkills_Now` in `Core.lua` |
| Retries | `Sync:OnLogin`, `PLAYER_ENTERING_WORLD` |
| Kit Use vs Create | `Sync:OnUnitSpellcastStart` / `Succeeded` in `Sync.lua` |

## Settings persist (v0.6.3+)

Nested `SmoreSkillsDB.settings` is often empty after `/reload` on Forever (same skip-file class as camps). A missing table used to reset every General / Host / Seeker checkbox to defaults.

**Rule:** on every settings setter, write `SmoreSkills_SaveSettings()`:

| Channel | What |
| --- | --- |
| CVar `SmoreSkillsSS` | Bools + numbers (`SSv1\|ah=1\|ag=0\|…`) |
| CVar `SmoreSkillsST` | Strings (profession, object, want lists) |
| Account `SmoreSkillsSS` | Full `SSv1\|…` blob (do not create this global empty before SavedVariables apply) |
| `SmoreSkillsDB.ss` / `set_*` flats | Same file as host persist |

Apply the snapshot **after** `FillSettingsDefaults`, once per settings table (`_persistApplied`). Do not auto-save defaults before SavedVariables load. Do not re-run v2/v3 migrations over a saved-off checkbox.

Public `/1` is **not** a setting. The camp-panel **Announce camp in General** button is the only send.

## Test (every persist change)

1. Deploy Forever (`_classic_beta_`). `/reload` until chat shows the new version.
2. **Create** a Basic Campfire Kit at the trainer — no pin.
3. **Use** the kit in the wilderness (or `/smores host` at a fire) — pin + host panel.
4. `/reload` **within** 15 minutes. Chat: **Your campfire in … is still yours**. Pin on the zone map. `/smores camp` opens the panel (not “Host a camp first”).
5. Wait until more than 15 minutes have passed (or set leftover `remaining`/`clock` an hour back). `/reload` — **no** pin, no “still yours.”
6. Optional: `/smores status` — Hosting yes only while the fire is still in the 15-minute window.
7. Flip several General / Host / Seeker options, `/reload` — they stay.
8. **Announce camp in General** on the panel posts `/1`. Hover matches the line. Nothing else posts `/1`.

If step 4 fails, read the two `SmoreSkills.lua` files under `WTF\Account\…` **before** the next `/reload`. If they still contain coords/`remaining`, it is load/TTL again, not save.