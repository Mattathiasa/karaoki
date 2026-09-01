import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';
import '../../models/song.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback? onSongSelected;

  const LibraryScreen({super.key, this.onSongSelected});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  static const _categories = [
    'All', 'Pop', 'Rock', 'Hip Hop', 'R&B', 'Gospel', 'Classics', 'Party', 'Ethiopian',
  ];

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
                KSpacing.mobilePaddingH,
                KSpacing.mobilePaddingV,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Row(
                children: [
                  const KIconButton(icon: Icons.arrow_back_ios_new, size: 34),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Song Library',
                      style: TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: KColors.bone,
                      ),
                    ),
                  ),
                  const KIconButton(icon: Icons.search, size: 34),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                16,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: KColors.ink600,
                  borderRadius: BorderRadius.circular(KRadius.input),
                  border: Border.all(color: KColors.hairline, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: KColors.bone28, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: KTypography.uiBody.copyWith(
                          color: KColors.bone,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search songs...',
                          hintStyle: KTypography.uiBody.copyWith(
                            color: KColors.bone28,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category pills
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  12,
                  KSpacing.mobilePaddingH,
                  0,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return KCategoryPill(
                    label: _categories[i],
                    selected: _selectedCategory == _categories[i],
                    onTap: () => setState(() => _selectedCategory = _categories[i]),
                  );
                },
              ),
            ),

            // Filter tags
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                12,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    'ALL SONGS',
                    style: KTypography.monoLabel.copyWith(fontSize: 9),
                  ),
                  const SizedBox(width: 12),
                  _FilterTag(label: 'DIFFICULTY ▾'),
                  const SizedBox(width: 8),
                  _FilterTag(label: 'POPULAR ▾'),
                ],
              ),
            ),

            // Song list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  12,
                  KSpacing.mobilePaddingH,
                  40,
                ),
                itemCount: fixtureSongs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final song = fixtureSongs[i];
                  return KSongCard(
                    title: song.title,
                    artist: song.artist,
                    difficulty: song.difficulty,
                    duration: song.durationLabel,
                    artSize: 56,
                    onTap: widget.onSongSelected,
                    onAdd: () {},
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

class _FilterTag extends StatelessWidget {
  final String label;
  const _FilterTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: KColors.ink600,
        borderRadius: BorderRadius.circular(KRadius.pill),
      ),
      child: Text(
        label,
        style: KTypography.monoLabel.copyWith(
          fontSize: 9,
          color: KColors.bone45,
        ),
      ),
    );
  }
}
