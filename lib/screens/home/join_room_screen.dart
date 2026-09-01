import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
              KPrimaryButton(label: 'Join', onPressed: widget.onJoin),
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
              _NearbyRoom(name: 'Friday Night Fire', code: 'KARA-7821', players: '4/8', joinable: true),
              const SizedBox(height: 8),
              _NearbyRoom(name: 'Saturday Chill', code: 'KARA-3456', players: '8/8', joinable: false),
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
              decoration: BoxDecoration(color: KColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
              child: Text('FULL', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.gold)),
            ),
        ],
      ),
    );
  }
}
