import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryScreen({super.key, this.onBack});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filter = 0; // 0=Recent, 1=Highest, 2=By artist

  static const _history = [
    ('Neon Midnight', 'Vela Cruz', '96', 'SUPERSTAR', KColors.gold, '2d ago'),
    ('Concrete Halo', 'The Static Kings', '87', 'GREAT', KColors.mint, '3d ago'),
    ('Slow Gold', 'Amara Reign', '78', 'GREAT', KColors.mint, '5d ago'),
    ('Loose Change', 'Kobi Blaze', '72', 'SOLID', KColors.teal, '1w ago'),
    ('Old Sepia Letters', 'Frank Delacroix', '68', 'SOLID', KColors.teal, '2w ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Expanded(child: Text('History', style: TextStyle(
                    fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                    fontSize: 22, color: KColors.bone,
                  ))),
                ],
              ),
            ),
            // Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 16, KSpacing.mobilePaddingH, 0),
              child: Row(
                children: [
                  _FilterPill(label: 'Recent', selected: _filter == 0, onTap: () => setState(() => _filter = 0)),
                  const SizedBox(width: 8),
                  _FilterPill(label: 'Highest', selected: _filter == 1, onTap: () => setState(() => _filter = 1)),
                  const SizedBox(width: 8),
                  _FilterPill(label: 'By artist', selected: _filter == 2, onTap: () => setState(() => _filter = 2)),
                ],
              ),
            ),
            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH, 16, KSpacing.mobilePaddingH, 40,
                ),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final h = _history[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: KColors.ink650,
                      borderRadius: BorderRadius.circular(KRadius.tile),
                      border: Border.all(color: KColors.hairline, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: KColors.ink700),
                          alignment: Alignment.center,
                          child: const Icon(Icons.music_note, color: KColors.bone28, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.$1, style: KTypography.uiRowTitle),
                              Text(h.$2, style: KTypography.monoLabel.copyWith(fontSize: 10)),
                              Text(h.$6, style: KTypography.monoLabel.copyWith(fontSize: 8.5)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(h.$3, style: TextStyle(
                              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                              fontSize: 21, color: h.$4 == 'SUPERSTAR' ? KColors.gold :
                                         h.$4 == 'GREAT' ? KColors.mint : KColors.teal,
                            )),
                            Text(h.$4, style: KTypography.monoLabel.copyWith(
                              fontSize: 9, color: h.$5,
                            )),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _FilterPill({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? KColors.limeTint : KColors.ink600,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? KColors.lime : KColors.hairline, width: 0.5),
        ),
        child: Text(label, style: KTypography.uiButton.copyWith(
          fontSize: 12.5, color: selected ? KColors.lime : KColors.bone55,
        )),
      ),
    );
  }
}
