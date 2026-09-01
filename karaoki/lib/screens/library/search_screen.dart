import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../models/song.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SearchScreen({super.key, this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Song> _results = [];
  static const _recent = ['Neon Midnight', 'Rock', 'Vela Cruz'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.isEmpty) { setState(() => _results = []); return; }
    setState(() {
      _results = fixtureSongs.where((s) =>
        s.title.toLowerCase().contains(query.toLowerCase()) ||
        s.artist.toLowerCase().contains(query.toLowerCase()) ||
        s.genre.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search field
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, KSpacing.mobilePaddingH, 0),
              child: Row(
                children: [
                  KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: widget.onBack),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: KColors.ink600,
                        borderRadius: BorderRadius.circular(KRadius.input),
                        border: Border.all(color: KColors.lime, width: 1),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search songs...',
                          hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
                          border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                          prefixIcon: const Icon(Icons.search, color: KColors.lime, size: 18),
                        ),
                        onChanged: _search,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_controller.text.isEmpty) ...[
              // Recent searches
              Padding(
                padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 20, KSpacing.mobilePaddingH, 0),
                child: Text('RECENT SEARCHES', style: KTypography.monoLabel.copyWith(fontSize: 9)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 10, KSpacing.mobilePaddingH, 0),
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _recent.map((r) => GestureDetector(
                    onTap: () { _controller.text = r; _search(r); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KColors.ink600,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(r, style: KTypography.uiBody.copyWith(fontSize: 12, color: KColors.bone55)),
                    ),
                  )).toList(),
                ),
              ),
            ] else ...[
              // Results
              Padding(
                padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 20, KSpacing.mobilePaddingH, 0),
                child: Text('RESULTS \u00b7 ${_results.length}', style: KTypography.monoLabel.copyWith(fontSize: 9)),
              ),
              Expanded(
                child: _results.isEmpty
                  ? Center(
                      child: Text(
                        'No songs match "${_controller.text}"',
                        style: KTypography.uiBody.copyWith(fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 40),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = _results[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: KColors.ink650,
                            borderRadius: BorderRadius.circular(KRadius.tile),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(KRadius.tile),
                                  color: KColors.ink700,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.music_note, color: KColors.bone28, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title, style: KTypography.uiRowTitle),
                                    Text('${s.artist} \u00b7 ${s.genre}', style: KTypography.monoLabel.copyWith(fontSize: 10)),
                                  ],
                                ),
                              ),
                              Text(s.durationLabel, style: KTypography.monoLabel.copyWith(fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
