import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';
import '../../models/song.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onJoinRoom;
  final VoidCallback? onCreateRoom;
  final VoidCallback? onSolo;
  final VoidCallback? onProfile;

  const HomeScreen({
    super.key,
    this.onJoinRoom,
    this.onCreateRoom,
    this.onSolo,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  KSpacing.mobilePaddingV,
                  KSpacing.mobilePaddingH,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Online status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: KColors.lime,
                              borderRadius: BorderRadius.circular(KRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const KLiveDot(color: KColors.mint, size: 6),
                                const SizedBox(width: 6),
                                Text(
                                  'SAT 21:04 / 4 ONLINE',
                                  style: KTypography.monoLabel.copyWith(
                                    fontSize: 9,
                                    color: KColors.onAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Hero text
                          const Text(
                            'Ready to\nSing?',
                            style: TextStyle(
                              fontFamily: 'BricolageGrotesque',
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              color: KColors.bone,
                              letterSpacing: -1.2,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Avatar
                    GestureDetector(
                      onTap: onProfile,
                      child: const Stack(
                        children: [
                          KAvatar(initial: 'M', size: 50),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: KLiveDot(color: KColors.mint, size: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Join Room hero card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  20,
                  KSpacing.mobilePaddingH,
                  0,
                ),
                child: GestureDetector(
                  onTap: onJoinRoom,
                  child: Container(
                    height: 184,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(KRadius.heroCard),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: const Alignment(0.2, 1),
                        colors: [
                          KColors.limeTint.withOpacity(0.4),
                          KColors.ink700,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                          spreadRadius: -22,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Stack(
                      children: [
                        // Room live pill
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: KColors.mint.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(KRadius.pill),
                              border: Border.all(
                                color: KColors.mint.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const KLiveDot(color: KColors.mint, size: 6),
                                const SizedBox(width: 6),
                                Text(
                                  'ROOM LIVE NOW',
                                  style: KTypography.monoLabel.copyWith(
                                    fontSize: 9,
                                    color: KColors.mint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Mic tile
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: KColors.ink600.withOpacity(0.8),
                              border: Border.all(color: KColors.hairline),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.mic, color: KColors.bone28, size: 28),
                          ),
                        ),
                        // Bottom text
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Join Room',
                                style: TextStyle(
                                  fontFamily: 'BricolageGrotesque',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 31,
                                  color: KColors.bone,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Friday Night Fire · 4 singing · KARA-7821',
                                style: KTypography.monoLabel.copyWith(
                                  fontSize: 10,
                                  color: KColors.bone45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Create Room + Quick Solo tiles
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  14,
                  KSpacing.mobilePaddingH,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCreateRoom,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: KColors.limeTint.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(KRadius.tile),
                            border: Border.all(
                              color: KColors.limeTint.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: KColors.limeTint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add,
                                  color: KColors.lime,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Create Room',
                                style: TextStyle(
                                  fontFamily: 'BricolageGrotesque',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                  color: KColors.bone,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Host a session',
                                style: KTypography.monoLabel.copyWith(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: onSolo,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: KColors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(KRadius.tile),
                            border: Border.all(
                              color: KColors.teal.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: KColors.teal.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.headphones,
                                  color: KColors.teal,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Quick Solo',
                                style: TextStyle(
                                  fontFamily: 'BricolageGrotesque',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                  color: KColors.bone,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Practice alone',
                                style: KTypography.monoLabel.copyWith(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recently played
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  24,
                  0,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'RECENTLY PLAYED',
                          style: KTypography.monoLabel.copyWith(fontSize: 9),
                        ),
                        const Spacer(),
                        Text(
                          'See all',
                          style: KTypography.monoLabel.copyWith(
                            fontSize: 10,
                            color: KColors.lime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: fixtureSongs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final song = fixtureSongs[i];
                          return _RecentlyPlayedCard(song: song);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trending tonight
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  24,
                  KSpacing.mobilePaddingH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TRENDING TONIGHT',
                          style: KTypography.monoLabel.copyWith(fontSize: 9),
                        ),
                        const SizedBox(width: 8),
                        const KLiveDot(color: KColors.red, size: 6),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...fixtureSongs.take(4).map(
                      (song) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: KSongCard(
                          title: song.title,
                          artist: song.artist,
                          difficulty: song.difficulty,
                          artSize: 52,
                          onTap: () {},
                          onAdd: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats pair
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  24,
                  KSpacing.mobilePaddingH,
                  40,
                ),
                child: Row(
                  children: [
                    // Top score
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: KColors.limeTint.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(KRadius.tile),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR TOP SCORE',
                              style: KTypography.monoLabel.copyWith(fontSize: 9),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '96',
                              style: KTypography.displayHero.copyWith(
                                fontSize: 44,
                                color: KColors.lime,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // New badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: KColors.ink650,
                          borderRadius: BorderRadius.circular(KRadius.tile),
                          border: Border.all(color: KColors.hairline, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEW BADGE',
                              style: KTypography.monoLabel.copyWith(fontSize: 9),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.emoji_events, color: KColors.gold, size: 26),
                            const SizedBox(height: 4),
                            Text(
                              'Pitch Perfect',
                              style: KTypography.uiRowTitle.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyPlayedCard extends StatelessWidget {
  final Song song;
  const _RecentlyPlayedCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover art
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KRadius.tile),
              gradient: LinearGradient(
                colors: [
                  KColors.limeTint.withOpacity(0.6),
                  KColors.ink700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.music_note, color: KColors.bone28, size: 32),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            song.title,
            style: KTypography.uiRowTitle.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Artist
          Text(
            song.artist,
            style: KTypography.monoLabel.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
