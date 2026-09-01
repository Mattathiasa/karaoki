import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'ui_components.dart';

/// Song card (cover art + title + artist + difficulty tag)
class KSongCard extends StatelessWidget {
  final String title;
  final String artist;
  final String? difficulty;
  final String? duration;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final double artSize;

  const KSongCard({
    super.key,
    required this.title,
    required this.artist,
    this.difficulty,
    this.duration,
    this.onTap,
    this.onAdd,
    this.artSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KSpacing.cardPadding),
        decoration: BoxDecoration(
          color: KColors.ink650,
          borderRadius: BorderRadius.circular(KRadius.tile),
          border: Border.all(color: KColors.hairline, width: 0.5),
        ),
        child: Row(
          children: [
            // Cover art placeholder
            Container(
              width: artSize,
              height: artSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(KRadius.tile),
                gradient: const LinearGradient(
                  colors: [KColors.limeTint, KColors.ink700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.music_note, color: KColors.bone28, size: 24),
            ),
            const SizedBox(width: KSpacing.lg),
            // Title + artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: KTypography.uiRowTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: KTypography.monoLabel.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (difficulty != null || duration != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (difficulty != null) ...[
                          _MetaTag(label: difficulty!),
                          const SizedBox(width: 6),
                        ],
                        if (duration != null) _MetaTag(label: duration!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Add button
            if (onAdd != null)
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: KColors.limeTint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: KColors.lime, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Player card (avatar + name + level + status tag)
class KPlayerCard extends StatelessWidget {
  final String name;
  final String? level;
  final String? status; // READY, SINGING, PICKING SONG
  final String? initial;
  final bool isHost;
  final VoidCallback? onLongPress;

  const KPlayerCard({
    super.key,
    required this.name,
    this.level,
    this.status,
    this.initial,
    this.isHost = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: KColors.ink650,
          borderRadius: BorderRadius.circular(KRadius.tile),
          border: Border.all(color: KColors.hairline, width: 0.5),
        ),
        child: Row(
          children: [
            // Avatar
            KAvatar(initial: initial ?? name[0], size: 42),
            const SizedBox(width: KSpacing.lg),
            // Name + level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: KTypography.uiRowTitle),
                      if (isHost) ...[
                        const SizedBox(width: 8),
                        const KHostTag(),
                      ],
                    ],
                  ),
                  if (level != null) ...[
                    const SizedBox(height: 2),
                    Text(level!, style: KTypography.monoLabel),
                  ],
                ],
              ),
            ),
            // Status tag
            if (status != null) KStatusTag(status: status!),
          ],
        ),
      ),
    );
  }
}

/// Achievement card
class KAchievementCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final bool unlocked;

  const KAchievementCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.description,
    this.unlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? KColors.limeTint.withOpacity(0.3) : KColors.ink700,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(
          color: unlocked ? KColors.limeTint : KColors.hairline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(name, style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            description,
            style: KTypography.monoLabel.copyWith(fontSize: 10.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            unlocked ? '✓ UNLOCKED' : 'LOCKED',
            style: KTypography.monoLabel.copyWith(
              fontSize: 9,
              color: unlocked ? KColors.mint : KColors.bone28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Leaderboard row
class KLeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String? initial;
  final bool isCurrentUser;

  const KLeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    this.initial,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser ? KColors.limeTint.withOpacity(0.2) : KColors.ink650,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(
          color: isCurrentUser ? KColors.limeTint : KColors.hairline,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: KTypography.monoLabel.copyWith(
              fontSize: 19,
              color: KColors.bone28,
            ),
          ),
          const SizedBox(width: 12),
          KAvatar(initial: initial ?? name[0], size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: KTypography.uiRowTitle),
          ),
          Text(
            score.toString(),
            style: KTypography.displayHeadline2.copyWith(
              color: KColors.gold,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper meta tag
class _MetaTag extends StatelessWidget {
  final String label;
  const _MetaTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: KColors.ink700,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: KTypography.monoLabel.copyWith(fontSize: 9, letterSpacing: 0.12),
      ),
    );
  }
}

/// Host tag
class KHostTag extends StatelessWidget {
  const KHostTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: KColors.lime, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'HOST',
        style: KTypography.monoLabel.copyWith(
          fontSize: 9,
          color: KColors.lime,
          letterSpacing: 0.12,
        ),
      ),
    );
  }
}

/// Avatar (squircle)
class KAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const KAvatar({
    super.key,
    required this.initial,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.34),
        gradient: const LinearGradient(
          colors: [KColors.limeTint, KColors.ink600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          fontFamily: 'BricolageGrotesque',
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
          color: KColors.bone,
        ),
      ),
    );
  }
}

/// Score badge (display numeral + /100)
class KScoreBadge extends StatelessWidget {
  final int score;

  const KScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          score.toString(),
          style: KTypography.displayHero.copyWith(fontSize: 88, color: KColors.gold),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '/100',
            style: KTypography.monoLabel.copyWith(
              fontSize: 16,
              color: KColors.bone45,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rank badge (pill with gradient)
class KRankBadge extends StatelessWidget {
  final String rank; // SUPERSTAR, GREAT, SOLID, KEEP GOING
  final String emoji;

  const KRankBadge({
    super.key,
    required this.rank,
    this.emoji = '',
  });

  Color get _color {
    switch (rank) {
      case 'SUPERSTAR':
        return KColors.gold;
      case 'GREAT':
        return KColors.mint;
      case 'SOLID':
        return KColors.teal;
      default:
        return KColors.bone45;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.3), _color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(KRadius.pill),
        border: Border.all(color: _color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        rank,
        style: KTypography.monoLabel.copyWith(
          fontSize: 14,
          color: _color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Combo badge
class KComboBadge extends StatelessWidget {
  final int combo;

  const KComboBadge({super.key, required this.combo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.whatshot, color: KColors.gold, size: 34),
        const SizedBox(width: 8),
        Text(
          'x$combo',
          style: KTypography.displayHeadline2.copyWith(
            color: KColors.gold,
            fontSize: 40,
          ),
        ),
      ],
    );
  }
}
