# Hosted camp across `/reload`

If the pin vanishes after `/reload` while the fire is still on the ground, **do not** treat it as “we forgot to save.” On Forever the files on disk are usually fine. The client often **does not put the nested tables back into memory**, and the 20-minute TTL is easy to fail if two clocks are mixed.

Verified live **18 Sep 2026** on `_classic_beta_` (Zephras Isle, Horde **No Bunda**): kit **Use**, `/smores host`, and `/reload` keep the pin; **Create** kit does not host. Shipped in **v0.5.77**.

## What you will see

| Clue | Meaning |
| --- | --- |
| Chat: `Host a camp first` | `SmoreSkills_GetOwnedActiveCamp()` is nil. Restore never rebuilt the camp in RAM. |
| Chat: `Your campfire in … is still yours (N min left)` | Restore worked. If the pin is still missing, it is map drawing, not save/restore. |
| Explorer: `WTF\…\SavedVariables\SmoreSkills.lua` still has the camp | Save worked. The bug is **load** or **TTL**, not write. |
| Nested `["camps"] = { … }` on disk, empty `camps` in `/reload` | Forever dropped the nested table on load. This is the usual case. |

Do not “fix” this by writing a richer nested camp into `SmoreSkillsDB.camps`. That is what v0.5.68 tried. The nested table is written and then comes back empty.

## Three separate failure modes

### 1. Nested SavedVariables do not load

`SmoreSkillsDB.camps` is a nested map of camp tables (slots, owner, coords). Forever writes it. After `/reload` it is often **missing in memory** even though the `.lua` file still has it.

`## SavedVariablesPerCharacter: SmoreSkillsHostDB` is the flat per-character snapshot. The file exists under `WTF\Account\<id>\<realm>\<char>\SavedVariables\SmoreSkills.lua`. After `/reload` that global is often **`{}`** anyway.

**What does load:** top-level primitives on the **account** table `SmoreSkillsDB` — settings, `hostCampId`, `hostSnapRemaining`, `hostSnap_mapId`, `hostSnap_x`, …

**Rule:** persist the hosted fire as **flat account fields**. Restore from those. Then copy into `SmoreSkillsDB.camps` for the rest of the session.

`hostCampId` is already `mapId:x:y` (`2521:0.599:0.650`). If the `hostSnap_*` coords are missing, parse that string.

### 2. Two clocks (Denmark vs US realm)

The realm is in the US. The PC may be in Denmark (~9 hours). That gap is larger than the **20 minute** pin TTL.

| API | What it is |
| --- | --- |
| `GetServerTime()` | Realm clock. Use this for wire stamps and `SmoreSkills_Now()`. |
| `time()` | **PC local** unix time on this client. Never use it for camp TTL. |
| `GetTime()` | Seconds since this UI session started. Resets on `/reload`. Use it to count **remaining** down *after* restore. |

While you play, hosting uses `GetServerTime()` consistently, so the pin is fine. After `/reload`, a fallback to `time()` makes “now” 21:12 and “lit at” 12:12. Age ≈ 9 hours → pin looks burned out.

`GetServerTime()` can also be **0** (or milliseconds) at login. Writing `litAt = now - elapsed` then stores a **negative** time. Every later check with a real clock treats the fire as years old.

**Rule:** camp TTL for *your* fire is **seconds remaining**, not `now - litAt` across a reload.

- On snapshot: store `remaining` (and `hostSnapRemaining`).
- On restore: do not subtract wall clocks. Keep `remaining`. Start `Sync.hostRemainAt` + `Sync.hostRemainStarted = GetTime()`.
- `SmoreSkills_CampPinActive` for an owned host uses that remaining countdown.
- `SmoreSkills_Now()` is `GetServerTime()` only. If it is 0, wait and retry restore. Never fall back to `time()`.

Other people’s pins can still use `litAt` vs `GetServerTime()` — those stamps come from the wire in the same session.

### 3. Create kit vs Use kit

Cooking **Create** (Basic Campfire Kit) and **Use** (place the fire) share a cast name / spell id on Forever (`1229737`, bar often says “Basic Campfire”).

**Rule:** profession window open at `UNIT_SPELLCAST_START` → craft, ignore. Window closed → place, host. Do not host from Create. Do not skip Use because the craft fix was too broad. Spell handlers stay tiny (no bag scan, no `C_Timer` from the event — queue on the outbound pump) or Forever taints (*Interface action failed*).

## Working snapshot (v0.5.77)

Write on host, slot change, `ReloadUI` hook, and `PLAYER_LOGOUT`:

- Per-character `SmoreSkillsHostDB` — flat primitives (keep writing; harmless if load fails).
- Account `SmoreSkillsDB.hostCampId`
- Account `SmoreSkillsDB.hostSnapRemaining`
- Account `SmoreSkillsDB.hostSnap_*` — `mapId`, `x`, `y`, `zone`, `owner`, slots `p1`/`o1`/`n1`, …

Restore on `ADDON_LOADED`, `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, and a few delayed retries:

1. `SmoreSkillsHostDB` if it has coords.
2. Else `ReadAccountHostSnap()` (`hostSnap_*` + `hostSnapRemaining`).
3. Else parse `hostCampId`.

Rebuild the in-memory camp, set session remaining from `GetTime()`, then draw the pin. Chat **Your campfire in \<zone\> is still yours** only after `Sync:RestoreHostSession()` actually succeeds.

Clear the snapshot only on **pack-up** or a real 20-minute burn. A failed restore or a 3/3 camp must not wipe it.

This does **not** auto-broadcast stored camps on login. The pin is **local**. `H:` still waits for Find or `/smores host`.

## Never

- Trust `SmoreSkillsDB.camps` after `/reload` as the source of truth.
- Mix `time()` and `GetServerTime()` for pin TTL.
- Rewrite `litAt` from a `0` clock.
- Expire an owned fire because `now - litAt` is hours (timezone or ms/sec jump).
- Wipe `HostDB` when restore returns “no saved campfire” or “waiting for clock”.
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

## Test (every persist change)

1. Deploy Forever (`_classic_beta_`). `/reload` until chat shows the new version.
2. **Create** a Basic Campfire Kit at the trainer — no pin.
3. **Use** the kit in the wilderness (or `/smores host` at a fire) — pin + host panel.
4. `/reload`. Chat: **Your campfire in … is still yours**. Pin on the zone map. `/smores camp` opens the panel (not “Host a camp first”).
5. Optional: `/smores status` — Hosting yes; Host snapshot line if present.

If step 4 fails, read the two `SmoreSkills.lua` files under `WTF\Account\…` **before** the next `/reload`. If they still contain coords/`remaining`, it is load/TTL again, not save.