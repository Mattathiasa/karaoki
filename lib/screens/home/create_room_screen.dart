import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

class CreateRoomScreen extends StatefulWidget {
  final VoidCallback? onCreate;
  final VoidCallback? onBack;

  const CreateRoomScreen({super.key, this.onCreate, this.onBack});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _nameController = TextEditingController(text: 'Friday Night Fire');
  String _selectedMode = 'Classic';
  final int _maxPlayers = 8;
  final String _visibility = 'Private';
  final String _category = 'Party';
  final String _difficulty = 'Mixed';

  static const _modes = [
    ('Classic', 'Icons.queue_music', 'One singer at a time, queue order'),
    ('Battle', 'Icons.sports_mma', 'Two players, same track, higher score wins'),
    ('Team', 'Icons.groups', 'Split into Fire and Lightning teams'),
    ('Duet', 'Icons.record_voice_over', 'Sing together, separate scores'),
    ('Pass the Mic', 'Icons.mic_external_on', 'Round-robin sections'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH, KSpacing.mobilePaddingV, KSpacing.mobilePaddingH, 0,
              ),
              child: Row(
                children: [
                  KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: widget.onBack),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Create Room', style: TextStyle(
                      fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                      fontSize: 22, color: KColors.bone,
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(KSpacing.mobilePaddingH),
                children: [
                  // Room name
                  _Field(label: 'ROOM NAME', child: TextField(
                    controller: _nameController,
                    style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                    decoration: InputDecoration(
                      filled: true, fillColor: KColors.ink600,
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
                  )),
                  const SizedBox(height: 24),
                  // Game mode
                  Text('GAME MODE', style: KTypography.monoLabel.copyWith(fontSize: 11.5)),
                  const SizedBox(height: 10),
                  ...(_modes).map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = m.$1),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _selectedMode == m.$1 ? KColors.limeTint.withOpacity(0.2) : KColors.ink650,
                          borderRadius: BorderRadius.circular(KRadius.tile),
                          border: Border.all(
                            color: _selectedMode == m.$1 ? KColors.lime : KColors.hairline,
                            width: _selectedMode == m.$1 ? 1 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: KColors.ink700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                m.$1 == 'Classic' ? Icons.queue_music :
                                m.$1 == 'Battle' ? Icons.sports_mma :
                                m.$1 == 'Team' ? Icons.groups :
                                m.$1 == 'Duet' ? Icons.record_voice_over : Icons.mic_external_on,
                                color: KColors.bone28, size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.$1, style: KTypography.uiRowTitle.copyWith(fontSize: 14)),
                                  Text(m.$3, style: KTypography.monoLabel.copyWith(fontSize: 9)),
                                ],
                              ),
                            ),
                            if (_selectedMode == m.$1)
                              const Icon(Icons.check, color: KColors.lime, size: 18),
                          ],
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                  // Settings grid
                  Text('SETTINGS', style: KTypography.monoLabel.copyWith(fontSize: 11.5)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    children: [
                      _SettingTile(label: 'MAX PLAYERS', value: '$_maxPlayers'),
                      _SettingTile(label: 'VISIBILITY', value: _visibility),
                      _SettingTile(label: 'CATEGORY', value: _category),
                      _SettingTile(label: 'DIFFICULTY', value: _difficulty),
                    ],
                  ),
                ],
              ),
            ),
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH, 0, KSpacing.mobilePaddingH, 20,
              ),
              child: KPrimaryButton(label: 'Create room & open board', onPressed: widget.onCreate),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KTypography.monoLabel.copyWith(fontSize: 11.5)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String label;
  final String value;
  const _SettingTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KColors.ink650,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(color: KColors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: KTypography.monoLabel.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(value, style: KTypography.uiRowTitle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
