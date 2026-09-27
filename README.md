# Karaoki (Zemaoki)

A multiplayer Ethiopian karaoke party game, built as two connected Flutter
clients:

1. **Mobile player app** (Android/iOS, portrait) — each guest's mic,
   controller, song browser, and personal lyric sheet.
2. **Karaoke Board** (Flutter Web or any large screen, landscape) — the
   shared TV screen: room code + QR, queue, synchronised lyrics, live
   scoring, podium.

Phones join a room, queue songs, take turns singing, and get scored. The
board is the stage; the phone is the instrument.

**Stack:** Flutter · Provider (state) · go_router · Firebase (Auth +
Realtime Database) · `just_audio` (playback) · `audio_waveforms` (mic
capture / pitch) · `qr_flutter`.

## What works end-to-end

- **Solo play** — browse → details → sing the song you picked (backing track
  plays, lyrics wipe in sync, mic scores pitch/timing/consistency/energy/
  speed) → score reveal → history.
- **Room play** — create room (4+4 code) or join by code; shared queue;
  host starts; the active queue entry becomes the performance for everyone;
  phones stream `perf.tick` so the TV shows live lyrics + score; finishing
  a song advances the queue and walks the board through reveal → ranking →
  queue for the next singer.
- **TV mode** — open `/tv?code=KARA-XXXX` on any big screen. The board's
  screen is a *pure function of room status* (FLOWS.md §1): wait → queue →
  countdown → performance → reveal → leaderboard. The board never plays its
  own audio or computes its own score — it mirrors the singing phone.
- **Real audio** — every fixture song has a synthesized backing track
  (`assets/audio/*.ogg`, original compositions, royalty-free by
  construction). The guide melody is generated from each song's `NoteTrack`
  so what you hear matches what the pitch scorer expects. Regenerate with
  `tool/generate_backing_tracks.py` (needs Python + numpy + ffmpeg).
- **Scoring** — live score is an EMA of the spec-weighted blend (pitch 40% /
  timing 30% / consistency 15% / energy 15%) with a speed metric on top;
  ranks: <60 KEEP GOING · 60–74 SOLID · 75–89 GREAT · 90+ SUPERSTAR.
- **Persistence** — performances save to Firebase under `performances/{id}`
  when configured; scores clamp 0–100 server-side per `database.rules.json`.

## Run it

```bash
flutter pub get

# Phone app (device or emulator)
flutter run

# TV board (Chrome or any large display)
flutter run -d chrome -t lib/main.dart --web-port 8080
# then open http://localhost:8080/#/tv?code=KARA-XXXX (the code from the phone)
```

Multiplayer needs Firebase Realtime Database (see below). Without it the app
runs fully in local/stub mode: solo play, queue, scoring and the complete
board UI all work on one device; other devices simply won't see each other.

### Firebase setup (optional, for real multiplayer)

1. `flutterfire configure` — writes `lib/firebase_options.dart`. The app
   detects placeholder `YOUR_*` keys and falls back to stub services, so the
   shipped file is safe to run as-is.
2. Enable **Anonymous auth** and **Realtime Database** in the Firebase
   console; deploy `database.rules.json`.
3. Structure used: `rooms/{roomId}` (room + `players/`, `queue/`,
   `events/`, `presence/`), `roomCodes/{CODE}` → roomId,
   `performances/{id}`.

## What's actually built (`lib/`)

- **Onboarding:** splash, welcome, onboarding, sign in/up, setup
- **Home:** create room, join room, QR join
- **Lobby:** waiting room before a performance starts
- **Singing flow:** turn-next (live countdown, real queued song), turn-now,
  singing, complete
- **Board screens:** wait (real room data), queue, countdown, performance
  (mirrors the phone), reveal, VS, leaderboard — driven by `TvRoomScope`
- **Library:** search, browse, details, queue (remove propagates)
- **Profile / leaderboard:** leaderboard, history, achievements, settings
- **Services:** `firebase_room_service`, `firebase_sync_service`,
  `realtime_sync_service`, `room_service` (rooms/presence/queue + status
  transitions + queue removal), `karaoke_playback_service` +
  `lrc_parser` (lyric-synced playback), `audio_service` /
  `tv_audio_service` / `mic_service` (audio I/O), `performance_service`
  (scoring), `performance_history_service` (durable records)
- **Theme:** `colors`, `typography`, `spacing`, `radius` — implements the
  design tokens in `DESIGN_SYSTEM.md`

## Docs in this repo

- **`DESIGN_SYSTEM.md`** — the full design reference (colour, type, spacing,
  component library, motion) that `lib/theme/` implements.
- **`SCREENS.md`** — per-screen implementation spec.
- **`FLOWS.md`** — navigation flows, state machine, realtime event contract.
- **`karaoki-prototype-standalone.html`** — the original interactive HTML
  prototype (47 screens), useful as a visual reference.

## Tests

```bash
flutter test          # 55 tests: state machine, scoring, queue, turn loop
flutter analyze       # static analysis
```

## Known gaps

- Game modes beyond classic (battle/team/duet/pass-the-mic) have UI screens
  but are not wired into the turn loop yet.
- Some of the 12 edge states are demonstrative screens, not yet triggered
  automatically by their real conditions (see `FLOWS.md` §7/§8 checklist).
- `TvAudioService` web JS-interop (YouTube/HTML5 audio) is scaffolded but
  the board mirrors phone audio state instead of playing independently.
