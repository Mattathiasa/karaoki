# Karaoki (Zemaoki)

A multiplayer Ethiopian karaoke party game, built as two connected Flutter
clients:

1. **Mobile player app** (Android/iOS, portrait) — each guest's mic,
   controller, song browser, and personal lyric sheet.
2. **Karaoke Board** (Flutter Web, landscape) — the shared TV screen: room
   code + QR, queue, synchronised lyrics, live scoring, podium.

Phones join a room, queue songs, take turns singing, and get scored. The
board is the stage; the phone is the instrument.

**Stack:** Flutter · Provider (state) · go_router · Firebase (Auth +
Realtime Database) · `just_audio` (playback) · `audio_waveforms` (mic
capture / pitch) · `qr_flutter`.

## What's actually built (`lib/`)
- **Onboarding:** splash, welcome, onboarding, sign in/up, setup
- **Home:** create room, join room, QR join
- **Lobby:** waiting room before a performance starts
- **Singing flow:** turn-next, turn-now, singing, complete
- **Board screens:** wait, countdown, queue, performance, reveal, VS, leaderboard
- **Library:** search, browse, details, queue
- **Profile / leaderboard:** leaderboard, history, achievements, settings
- **Services:** `firebase_room_service`, `firebase_sync_service`,
  `realtime_sync_service`, `room_service` (rooms/presence/queue),
  `karaoke_playback_service` + `lrc_parser` (lyric-synced playback),
  `audio_service` / `tv_audio_service` / `mic_service` (audio I/O),
  `performance_service` (scoring)
- **Theme:** `colors`, `typography`, `spacing`, `radius` — implements the
  design tokens in `DESIGN_SYSTEM.md`

Screens and services cover most of the design spec's suggested build order
through scoring/leaderboard; game modes and the 12 edge states may still be
partial — check `lib/screens/game_modes/` and `lib/screens/edge_states/`
against `FLOWS.md` for what's left.

## Docs in this repo
- **`DESIGN_SYSTEM.md`** — the full design reference (colour, type, spacing,
  component library, motion) that `lib/theme/` implements. Originally
  written as a build handoff; read it for tokens and component specs, not
  as a status report.
- **`SCREENS.md`** — per-screen implementation spec.
- **`FLOWS.md`** — navigation flows, state machine, realtime event contract.
- **`karaoki-prototype-standalone.html`** / `Karaoke Prototype v5.dc.html`
  / `support.js` — the original interactive HTML prototype (47 screens),
  useful as a visual reference alongside the Flutter build.

## Status
This README replaces the previous one, which was written entirely as a
build handoff brief even though `lib/`, `android/`, and `ios/` already
contain a substantial implementation. Fill in actual build/run instructions
and current completion status per screen as they firm up.
