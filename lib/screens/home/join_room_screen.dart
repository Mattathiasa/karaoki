import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/ui_components.dart';
import '../../providers/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/room_service.dart';

class JoinRoomScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onJoin;
  final VoidCallback? onScan;

  const JoinRoomScreen({super.key, this.onBack, this.onJoin, this.onScan});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _codeController = TextEditingController();
  bool _hasError = false;
  bool _joining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    if (_joining) return;

    setState(() => _joining = true);
    try {
      final appState = context.read<AppState>();
      final roomService = context.read<RoomService>();
      final room = await roomService.joinRoom(
        code: code,
        userId: appState.userId,
      );
      appState.setRoom(room, isHost: room.hostId == appState.userId);
      if (!mounted) return;
      // Preserve where we came from: after picking a name the user lands
      // on the lobby, which is where they were headed anyway.
      widget.onJoin?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
      // Route to the matching edge screen for full-room / bad-code states.
      final message = e.toString();
      if (message.contains('Room is full')) {
        context.push('/edge/room-full');
      } else {
        context.push('/edge/bad-code', extra: code);
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Name gate: a guest still carrying the default identity picks a name
    // before joining, so the room never shows another "Player".
    if (!context.watch<AppState>().hasCustomName) {
      return const _NameGateScreen();
    }

    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: widget.onBack),
              const SizedBox(height: 32),
              const Text('Join Room', style: TextStyle(
                fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                fontSize: 28, color: KColors.bone,
              )),
              const SizedBox(height: 32),
              // Code input
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: KTypography.monoCode.copyWith(fontSize: 30, letterSpacing: 0.14),
                decoration: InputDecoration(
                  hintText: 'KARA-0000',
                  hintStyle: KTypography.monoCode.copyWith(fontSize: 30, color: KColors.bone28, letterSpacing: 0.14),
                  filled: true,
                  fillColor: KColors.ink600,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KRadius.input),
                    borderSide: BorderSide(color: _hasError ? KColors.red : KColors.hairline, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KRadius.input),
                    borderSide: BorderSide(color: _hasError ? KColors.red : KColors.hairline, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KRadius.input),
                    borderSide: const BorderSide(color: KColors.lime, width: 1),
                  ),
                ),
                onChanged: (v) {
                  _codeController.text = v.toUpperCase();
                  setState(() => _hasError = false);
                },
              ),
              if (_hasError) ...[
                const SizedBox(height: 8),
                Text(
                  'No room with that code. Codes look like KARA-7821.',
                  style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.red),
                ),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _codeController.text = 'KARA-7821',
                child: Text(
                  'Autofill the demo code',
                  style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45),
                ),
              ),
              const SizedBox(height: 24),
              KPrimaryButton(
                label: _joining ? 'Joining…' : 'Join',
                onPressed: _joining ? null : _join,
              ),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: KColors.hairline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: KTypography.monoLabel.copyWith(fontSize: 10)),
                  ),
                  Expanded(child: Container(height: 1, color: KColors.hairline)),
                ],
              ),
              const SizedBox(height: 24),
              // Scan QR
              GestureDetector(
                onTap: widget.onScan,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: KColors.ink650,
                    borderRadius: BorderRadius.circular(KRadius.tile),
                    border: Border.all(color: KColors.hairline, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner, color: KColors.bone28, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scan QR on the board', style: KTypography.uiRowTitle.copyWith(fontSize: 14)),
                            Text('Point your camera at the board screen', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: KColors.bone28, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Nearby rooms
              Text('NEARBY ROOMS', style: KTypography.monoLabel.copyWith(fontSize: 9)),
              const SizedBox(height: 10),
              const _NearbyRoom(name: 'Friday Night Fire', code: 'KARA-7821', players: '4/8', joinable: true),
              const SizedBox(height: 8),
              const _NearbyRoom(name: 'Saturday Chill', code: 'KARA-3456', players: '8/8', joinable: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the join form when the user has no display name yet.
/// Collects a name, persists it to AppState, then reveals the join form.
class _NameGateScreen extends StatefulWidget {
  const _NameGateScreen();

  @override
  State<_NameGateScreen> createState() => _NameGateScreenState();
}

class _NameGateScreenState extends State<_NameGateScreen> {
  final _nameController = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    context.read<AppState>().setUserName(name);
    // Same as the setup screen: give the guest a stable Firebase UID so
    // multiplayer sync works across restarts.
    unawaited(context.read<AuthService>().signInAsGuest());
    // Rebuild switches back to the join form now that hasCustomName holds.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('Before you join…', style: TextStyle(
                fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                fontSize: 28, color: KColors.bone,
              )),
              const SizedBox(height: 12),
              Text(
                'Pick a display name so the room knows who is singing.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Your display name',
                  hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
                  errorText: _hasError ? 'A name is required to join.' : null,
                  filled: true,
                  fillColor: KColors.ink600,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KRadius.input),
                    borderSide: const BorderSide(color: KColors.hairline, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KRadius.input),
                    borderSide: const BorderSide(color: KColors.hairline, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KRadius.input),
                    borderSide: const BorderSide(color: KColors.lime, width: 1),
                  ),
                ),
                onChanged: (_) {
                  if (_hasError) setState(() => _hasError = false);
                },
                onSubmitted: (_) => _confirm(),
              ),
              const SizedBox(height: 24),
              KPrimaryButton(label: 'Continue', onPressed: _confirm),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyRoom extends StatelessWidget {
  final String name;
  final String code;
  final String players;
  final bool joinable;
  const _NearbyRoom({required this.name, required this.code, required this.players, required this.joinable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KColors.ink650,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(color: KColors.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          KLiveDot(color: joinable ? KColors.mint : KColors.gold, size: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: KTypography.uiRowTitle),
                Text('$code  $players', style: KTypography.monoLabel.copyWith(fontSize: 10)),
              ],
            ),
          ),
          if (!joinable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: KColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
              child: Text('FULL', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.gold)),
            ),
        ],
      ),
    );
  }
}
