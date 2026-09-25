import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/cards.dart';
import '../../providers/app_state.dart';
import '../../models/room.dart';

class QueueScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddMore;

  const QueueScreen({super.key, this.onBack, this.onAddMore});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final queue = appState.queue;

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
                  KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: onBack),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Queue', style: TextStyle(
                      fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                      fontSize: 22, color: KColors.bone,
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: queue.isEmpty
                  ? _EmptyQueue(onAddMore: onAddMore)
                  : ListView(
                      padding: const EdgeInsets.all(KSpacing.mobilePaddingH),
                      children: [
                        // Up next header
                        Row(
                          children: [
                            Text(
                              'UP NEXT \u00b7 ${queue.length}',
                              style: KTypography.monoLabel.copyWith(fontSize: 9),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Queue rows from live AppState data
                        ...List.generate(queue.length, (i) {
                          final entry = queue[i];
                          final song = appState.songForEntry(entry);
                          final requester = appState.players
                              .where((p) => p.id == entry.requestedBy)
                              .firstOrNull;
                          final isMine = entry.requestedBy == appState.userId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: KColors.ink650,
                                borderRadius: BorderRadius.circular(KRadius.tile),
                                border: Border.all(color: KColors.hairline, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${entry.position}',
                                    style: KTypography.monoLabel.copyWith(
                                      fontSize: 14, color: KColors.bone28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: KColors.ink700,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.music_note, color: KColors.bone28, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(song.title, style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
                                        Row(
                                          children: [
                                            KAvatar(initial: requester?.initial ?? '?', size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              requester?.name ?? (isMine ? 'You' : 'Guest'),
                                              style: KTypography.monoLabel.copyWith(fontSize: 9),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (entry.state == QueueEntryState.playing)
                                    const SizedBox(height: 24, child: KEqualiser(height: 24, barCount: 3))
                                  else
                                    _RemoveButton(entryId: entry.entryId),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        // Position hint
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: KColors.hairline, width: 0.5, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(KRadius.tile),
                          ),
                          child: Text(
                            _positionHint(appState),
                            style: KTypography.monoLabel.copyWith(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: KSecondaryButton(label: 'Add another', onPressed: onAddMore)),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Where the current user sits in the queue, in plain language.
  String _positionHint(AppState appState) {
    final mine = appState.queue
        .where((e) => e.requestedBy == appState.userId && e.state == QueueEntryState.queued)
        .toList();
    if (mine.isEmpty) {
      return 'You have nothing queued \u2014 pick a song to sing';
    }
    final first = mine.first;
    final ahead = appState.queue
        .where((e) => e.position < first.position && e.state != QueueEntryState.done)
        .length;
    if (ahead == 0) return "You're up next \u2014 get ready!";
    return 'You sing ${ahead + 1}${ahead == 0 ? 'st' : ahead == 1 ? 'nd' : ahead == 2 ? 'rd' : 'th'} \u2014 $ahead song${ahead == 1 ? '' : 's'} before yours';
  }
}

/// Remove button for entries the current user added (or the host).
class _RemoveButton extends StatelessWidget {
  final String entryId;

  const _RemoveButton({required this.entryId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final appState = context.read<AppState>();
        final room = appState.currentRoom;
        if (room != null) {
          try {
            // No removeSong() on the service contract yet; local removal keeps
            // the UI truthful for this player until server support lands.
            appState.removeFromQueue(entryId);
          } catch (_) {}
        } else {
          appState.removeFromQueue(entryId);
        }
      },
      child: const Icon(Icons.close, color: KColors.bone28, size: 16),
    );
  }
}

/// Empty state when nothing is queued.
class _EmptyQueue extends StatelessWidget {
  final VoidCallback? onAddMore;

  const _EmptyQueue({this.onAddMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KSpacing.mobilePaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: KColors.ink700,
              borderRadius: BorderRadius.circular(KRadius.heroCard),
              border: Border.all(color: KColors.bone28, width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.music_note, color: KColors.bone28, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nothing queued yet',
            style: TextStyle(
              fontFamily: 'BricolageGrotesque',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: KColors.bone,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The board is waiting. Whoever adds the first song\nsings first.',
            style: KTypography.uiBody.copyWith(fontSize: 14.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          KPrimaryButton(label: 'Add the first song', onPressed: onAddMore),
        ],
      ),
    );
  }
}
