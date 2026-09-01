# Karaoki — flows, state and realtime contract

## 1. Navigation flows

### First run
`splash` → `onb1` → `onb2` → `onb3` → `welcome` → (`signin` | `signup` → `setup` | guest) → `home`
Skip on any onboarding screen jumps to `welcome`. Returning users go `splash` → `home`.

### Host a room
`home` → `createRoom` → (create room, open board) → `lobby` → `library` → add songs → `queueScr` → all ready → **host starts** → `turnNext` → `turnNow` → `singing` → `complete` → `leaderboard` → next player
Board: `bwait` → `bqueue` → `bcount` → `bperf` → `breveal` → `blead` → `bqueue` …

### Join a room
`home` → `joinRoom` → code **or** `qr` → `lobby` → `library` → `details` → add to queue → `queueScr` → `waiting` → `turnNext` → `turnNow` → `singing` → `complete` → `leaderboard`
Failures: bad code → `badCode`; capacity → `roomFull`; camera denied → permission explainer.

### Solo
`home` → `library` → `details` → `singing` → `complete` → save → `history`
No board, no queue, no leaderboard; scoring identical.

### Board screen selection (derived, never manual)
The board's screen is a pure function of room state:
```
room.status == 'waiting'                  -> bwait
room.status == 'queue' | 'idle'           -> bqueue
room.status == 'countdown'                -> bcount
room.status == 'performing' && mode solo  -> bperf
room.status == 'performing' && mode vs    -> bvs
room.status == 'revealing'                -> breveal
room.status == 'ranking'                  -> blead
```
The prototype mirrors this: choosing a phone screen moves the board to its paired state.

## 2. Room state machine

```
waiting ──host starts──> countdown ──t=0──> performing
   ^                                            │
   │                                       song ends
   │                                            v
   └──── queue <── ranking <── revealing ───────┘
```
| State | Duration | Phone | Board |
| --- | --- | --- | --- |
| `waiting` | until host starts | lobby / library / queue | `bwait` |
| `countdown` | 3s | `turnNext`/`turnNow` for the singer, "watch the board" for others | `bcount` |
| `performing` | song length | `singing` (singer) / queue view (others) | `bperf`/`bvs` |
| `revealing` | ~6s | `complete` (singer) | `breveal` |
| `ranking` | ~5s | `leaderboard` | `blead` |
| `queue` | until next start | queue | `bqueue` |

Guards: cannot enter `countdown` with an empty queue (→ `emptyQueue`); cannot start unless the next singer's mic permission is granted; on singer disconnect during `performing`, hold 60s then skip.

## 3. Client state

**Session**: `user{id,displayName,username,avatar,level,genres}`, `authMode: email|google|guest`.
**Room**: `roomId, code, name, hostId, mode, maxPlayers, visibility, category, difficulty, status`.
**Players**: `[{id, name, initial, avatar, level, ready, connected, team, score}]` (presence-backed).
**Queue**: `[{entryId, songId, requestedBy, position, state: queued|playing|done|skipped}]`.
**Performance (the clock)**: `{songId, singerId, startedAtServerMs, durationMs, positionMs}` — everything else is derived:
```
progress   = positionMs / durationMs
lineIndex  = last i where lyrics[i].t <= progress*100
lineProg   = (progress*100 - line.t) / (nextLine.t - line.t)   // the wipe
score      = f(pitchSamples, timingSamples)                    // server-authoritative
combo      = consecutive on-pitch windows
```
Only the phone measures audio; only the server computes the authoritative score; the board renders. Never let two clients compute score independently.

**Scoring model used in the prototype** — final score = weighted mean of Pitch (40%), Timing (30%), Consistency (15%), Energy (15%), 0–100. Ranks: <60 KEEP GOING · 60–74 SOLID · 75–89 GREAT · 90+ SUPERSTAR. Combo = +1 per on-pitch window (~0.5s), reset after two misses.

## 4. Realtime contract (phone ⇄ board)

The prototype's event-bus panel shows these in action.

| Event | From | Payload | Board effect |
| --- | --- | --- | --- |
| `player.join` | phone | `{roomId, user}` | avatar `popIn`s on `bwait`, count increments |
| `player.ready` | phone | `{playerId, ready}` | status tag flips |
| `player.leave` / presence loss | phone | `{playerId}` | row dims, 60s hold countdown |
| `queue.add` | phone | `{songId, requestedBy}` | row appends to `bqueue` / UP NEXT strip |
| `queue.reorder` / `queue.remove` | host phone | `{entryId, toIndex}` | list reorders |
| `game.start` | host phone | `{}` | → `bcount` |
| `perf.start` | server | `{songId, singerId, startedAtServerMs}` | → `bperf`, clock starts |
| `perf.tick` | phone → server → board | `{positionMs, pitch, timing, combo, score}` @ 5–10 Hz | rail values + pitch bars update |
| `perf.mic` | phone | `{state: live|lost}` | scoring pauses, banner |
| `perf.end` | server | `{finalScore, breakdown, rank, personalBest}` | → `breveal` |
| `rank.update` | server | `{standings[]}` | → `blead`, podium re-orders |

Sync notes: use server timestamps and a per-client offset (NTP-style handshake) so the lyric wipe matches audio; target < 80ms drift (the prototype's bus reports "drift 12ms"). Lyrics run **locally** from the last known clock when the connection degrades — never freeze the words (that is the `weak` state).

## 5. Data model (Firestore sketch)

```
users/{uid}                 displayName, username, avatarUrl, level, genres[], stats{songs,avg,best,wins}
songs/{songId}              title, artist, genre, difficulty, durationMs, artUrl, lyrics[{t,text,part}]
rooms/{roomId}              code, name, hostId, mode, maxPlayers, visibility, category, difficulty, status
rooms/{roomId}/players/{uid}  name, avatarUrl, ready, connected, team, score
rooms/{roomId}/queue/{entryId} songId, requestedBy, position, state
rooms/{roomId}/perf/current   songId, singerId, startedAt, durationMs, live{pitch,timing,combo,score}
performances/{id}           uid, roomId, songId, score, breakdown{}, rank, createdAt
achievements/{uid}/{badgeId}  unlockedAt, progress
```
Use Realtime Database (or Firestore + presence doc) for `perf.tick` and presence; Firestore for durable records. Room codes: 4 letters + 4 digits, uppercase, uniqueness-checked, TTL 12h.

## 6. Lyric data format
```json
{ "t": 35, "part": "BOTH", "text": "We were never meant to last this long" }
```
`t` is percentage of song duration (use ms in production), `part` is `A` | `B` | `BOTH` for duet and pass-the-mic assignment. The prototype ships 9 lines for "Neon Midnight" — reuse them as your fixture.

## 7. Game-mode rules
- **Classic** — queue order; one singer per entry; score after each.
- **Battle** — pick two players; both sing the same track (or one verse each); higher score wins; board shows `bvs` live, then `breveal` for the winner.
- **Team** — players split into Fire / Lightning; team score = sum of member scores; board shows both totals plus a share bar; winner announced after the final song.
- **Duet** — lyric lines carry `part`; each singer's lines highlight in their colour, BOTH lines in a dual gradient; two live scores; both must have mic permission.
- **Pass the Mic** — song split into N sections round-robin; the next singer is warned two lines ahead (screen + haptic); board announces "GET READY, {NAME}!" then "YOUR TURN!".

## 8. Implementation checklist
- [ ] Tokens + component library (buttons, cards, tags, avatars, meters, lyric widget)
- [ ] Auth: email, Google, guest → profile setup
- [ ] Room create / join by code / join by QR / presence
- [ ] Board waiting screen with live roster + real QR
- [ ] Catalogue: library, search, details, queue with attribution and host controls
- [ ] Clock + countdown + lyric wipe on both clients (single source of truth)
- [ ] Mic capture, pitch/timing analysis, `perf.tick` stream, server-side scoring
- [ ] Score reveal, breakdown, personal best, save, share
- [ ] Leaderboards (room / friends / global), history with filters, achievements
- [ ] Five game modes on top of the classic loop
- [ ] All 12 edge states
- [ ] Reduce-motion and safe-area handling
