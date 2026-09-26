import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';
import '../../models/song.dart';
import '../../services/song_repository.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback? onSongSelected;

  const LibraryScreen({super.key, this.onSongSelected});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Loaded and filtered song list
  List<Song> _songs = [];
  bool _loading = true;

  static const _categories = [
    'All', 'Pop', 'Rock', 'Hip Hop', 'R&B', 'Gospel', 'Classics', 'Party', 'Ethiopian',
  ];

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
      _loadSongs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    final repo = SongRepository.instance;
    final List<Song> results;

    if (_searchQuery.isNotEmpty) {
      results = await repo.search(_searchQuery);
    } else {
      results = await repo.byGenre(_selectedCategory);
    }

    if (mounted) setState(() { _songs = results; _loading = false; });
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
                  KIconButton(icon: Icons.arrow_back_ios_new, size: 34,
                      onPressed: () => context.pop()),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Song Library', style: TextStyle(
                      fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                      fontSize: 22, color: KColors.bone,
                    )),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH, 16, KSpacing.mobilePaddingH, 0,
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
                        style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search songs or artists…',
                          hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadSongs();
                        },
                        child: const Icon(Icons.close, color: KColors.bone28, size: 16),
                      ),
                  ],
                ),
              ),
            ),

            // Category pills — hidden while searching
            if (_searchQuery.isEmpty) ...[
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => KCategoryPill(
                    label: _categories[i],
                    selected: _selectedCategory == _categories[i],
                    onTap: () {
                      setState(() => _selectedCategory = _categories[i]);
                      _loadSongs();
                    },
                  ),
                ),
              ),
              // Row count label
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0,
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCategory == 'All'
                          ? 'ALL SONGS'
                          : _selectedCategory.toUpperCase(),
                      style: KTypography.monoLabel.copyWith(fontSize: 9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${_songs.length}',
                      style: KTypography.monoLabel.copyWith(
                          fontSize: 9, color: KColors.bone28),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0,
                ),
                child: Row(
                  children: [
                    Text(
                      'RESULTS FOR "${_searchQuery.toUpperCase()}"',
                      style: KTypography.monoLabel.copyWith(fontSize: 9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${_songs.length}',
                      style: KTypography.monoLabel.copyWith(
                          fontSize: 9, color: KColors.bone28),
                    ),
                  ],
                ),
              ),

            // Song list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: KColors.lime))
                  : _songs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_off, color: KColors.bone28, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'No songs found',
                                style: KTypography.uiRowTitle.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 40,
                          ),
                          itemCount: _songs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final song = _songs[i];
                            return KSongCard(
                              title: song.title,
                              artist: song.artist,
                              difficulty: song.difficulty,
                              duration: song.durationLabel,
                              artSize: 56,
                              onTap: () => context.go('/details', extra: song.id),
                              onAdd: () => context.go('/details', extra: song.id),
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
