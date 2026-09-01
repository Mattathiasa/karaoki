import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'services/performance_service.dart';
import 'models/song.dart';

// Onboarding
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/signin_screen.dart';
import 'screens/onboarding/signup_screen.dart';
import 'screens/onboarding/setup_screen.dart';

// Core
import 'screens/home/home_screen.dart';
import 'screens/home/create_room_screen.dart';
import 'screens/home/join_room_screen.dart';
import 'screens/home/qr_screen.dart';
import 'screens/lobby/lobby_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/library/search_screen.dart';
import 'screens/library/details_screen.dart';
import 'screens/library/queue_screen.dart';

// Performance
import 'screens/singing/turn_next_screen.dart';
import 'screens/singing/turn_now_screen.dart';
import 'screens/singing/singing_screen.dart';
import 'screens/singing/complete_screen.dart';

// Profile
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/leaderboard/history_screen.dart';
import 'screens/leaderboard/achievements_screen.dart';
import 'screens/leaderboard/profile_screen.dart';
import 'screens/leaderboard/settings_screen.dart';

// Board
import 'screens/board/board_wait_screen.dart';
import 'screens/board/board_countdown_screen.dart';
import 'screens/board/board_queue_screen.dart';
import 'screens/board/board_performance_screen.dart';
import 'screens/board/board_vs_screen.dart';
import 'screens/board/board_reveal_screen.dart';
import 'screens/board/board_leaderboard_screen.dart';

// Game modes
import 'screens/game_modes/game_modes.dart';

// Edge states
import 'screens/edge_states/edge_states.dart';

// Widgets
import 'widgets/board_shell.dart';

void main() {
  runApp(const KaraokiApp());
}

class KaraokiApp extends StatelessWidget {
  const KaraokiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karaoki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: KColors.ink800,
        colorScheme: const ColorScheme.dark(
          primary: KColors.lime,
          secondary: KColors.teal,
          surface: KColors.ink700,
          error: KColors.red,
        ),
      ),
      home: const KaraokiRouter(),
    );
  }
}

class KaraokiRouter extends StatefulWidget {
  const KaraokiRouter({super.key});

  @override
  State<KaraokiRouter> createState() => _KaraokiRouterState();
}

class _KaraokiRouterState extends State<KaraokiRouter> {
  _Screen _currentScreen = _Screen.splash;
  final _perfService = PerformanceService();

  @override
  void dispose() {
    _perfService.dispose();
    super.dispose();
  }

  void _go(_Screen s) => setState(() => _currentScreen = s);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        child: _buildScreen(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScreenPicker(context),
        backgroundColor: KColors.ink600,
        child: const Icon(Icons.grid_view, color: KColors.bone, size: 20),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      // ─── Onboarding ─────────────────────────────────
      case _Screen.splash:
        return SplashScreen(key: const ValueKey('splash'), onComplete: () => _go(_Screen.onboarding));
      case _Screen.onboarding:
        return OnboardingScreen(key: const ValueKey('onboarding'), onComplete: () => _go(_Screen.welcome));
      case _Screen.welcome:
        return WelcomeScreen(key: const ValueKey('welcome'), onContinue: () => _go(_Screen.home));
      case _Screen.signin:
        return SigninScreen(key: const ValueKey('signin'), onBack: () => _go(_Screen.welcome), onSignedIn: () => _go(_Screen.home), goToSignup: () => _go(_Screen.signup));
      case _Screen.signup:
        return SignupScreen(key: const ValueKey('signup'), onBack: () => _go(_Screen.welcome), onSignedUp: () => _go(_Screen.setup), goToSignin: () => _go(_Screen.signin));
      case _Screen.setup:
        return SetupScreen(key: const ValueKey('setup'), onComplete: () => _go(_Screen.home));

      // ─── Core ───────────────────────────────────────
      case _Screen.home:
        return HomeScreen(
          key: const ValueKey('home'),
          onJoinRoom: () => _go(_Screen.joinRoom),
          onCreateRoom: () => _go(_Screen.createRoom),
          onSolo: () => _go(_Screen.library),
          onProfile: () => _go(_Screen.profile),
        );
      case _Screen.createRoom:
        return CreateRoomScreen(key: const ValueKey('createRoom'), onBack: () => _go(_Screen.home), onCreate: () => _go(_Screen.lobby));
      case _Screen.joinRoom:
        return JoinRoomScreen(key: const ValueKey('joinRoom'), onBack: () => _go(_Screen.home), onJoin: () => _go(_Screen.lobby), onScan: () => _go(_Screen.qr));
      case _Screen.qr:
        return QrScreen(key: const ValueKey('qr'), onCancel: () => _go(_Screen.joinRoom), onSimulate: () => _go(_Screen.lobby));
      case _Screen.lobby:
        return LobbyScreen(
          key: const ValueKey('lobby'),
          roomName: 'Friday Night Fire', roomCode: 'KARA-7821', hostName: 'MATT',
          playerCount: 4, maxPlayers: 8,
          players: const [
            LobbyPlayer(name: 'Matt', initial: 'M', level: 24, ready: true, isHost: true),
            LobbyPlayer(name: 'Sara', initial: 'S', level: 18, ready: true),
            LobbyPlayer(name: 'Dawit', initial: 'D', level: 12, ready: true),
            LobbyPlayer(name: 'Leah', initial: 'L', level: 8, ready: false),
          ],
          onStart: () => _go(_Screen.turnNext),
          onBrowseSongs: () => _go(_Screen.library),
        );
      case _Screen.library:
        return LibraryScreen(key: const ValueKey('library'), onSongSelected: () => _go(_Screen.details));
      case _Screen.search:
        return SearchScreen(key: const ValueKey('search'), onBack: () => _go(_Screen.library));
      case _Screen.details:
        return DetailsScreen(key: const ValueKey('details'), onBack: () => _go(_Screen.library), onAddToQueue: () => _go(_Screen.queueScr));
      case _Screen.queueScr:
        return QueueScreen(key: const ValueKey('queueScr'), onBack: () => _go(_Screen.lobby), onAddMore: () => _go(_Screen.library));

      // ─── Performance ────────────────────────────────
      case _Screen.turnNext:
        return TurnNextScreen(key: const ValueKey('turnNext'), onReady: () => _go(_Screen.turnNow), onSkip: () => _go(_Screen.lobby));
      case _Screen.turnNow:
        return TurnNowScreen(key: const ValueKey('turnNow'), onStart: () {
          _perfService.startPerformance(song: fixtureSongs.first, singerId: 'matt');
          _go(_Screen.singing);
        });
      case _Screen.singing:
        return SingingScreen(
          key: const ValueKey('singing'),
          perfService: _perfService,
          onComplete: () => _go(_Screen.complete),
        );
      case _Screen.complete:
        return const CompleteScreen(key: ValueKey('complete'), score: 87, pitch: 92, timing: 88, consistency: 81, energy: 95, isNewBest: true, previousBest: 78);

      // ─── Profile ────────────────────────────────────
      case _Screen.leaderboard:
        return const LeaderboardScreen(key: ValueKey('leaderboard'));
      case _Screen.history:
        return HistoryScreen(key: const ValueKey('history'), onBack: () => _go(_Screen.profile));
      case _Screen.achievements:
        return AchievementsScreen(key: const ValueKey('achievements'), onBack: () => _go(_Screen.profile));
      case _Screen.profile:
        return ProfileScreen(key: const ValueKey('profile'), onBack: () => _go(_Screen.home), onSettings: () => _go(_Screen.settings));
      case _Screen.settings:
        return SettingsScreen(key: const ValueKey('settings'), onBack: () => _go(_Screen.profile));

      // ─── Board ──────────────────────────────────────
      case _Screen.boardWait:
        return const BoardShell(child: BoardWaitScreen(key: ValueKey('boardWait'), roomName: 'Friday Night Fire', roomCode: 'KARA-7821', mode: 'CLASSIC', playerCount: 4, maxPlayers: 8));
      case _Screen.boardCountdown:
        return BoardShell(child: BoardCountdownScreen(key: const ValueKey('boardCountdown'), singerName: 'Matt', songTitle: 'Neon Midnight', onComplete: () => _go(_Screen.boardPerf)));
      case _Screen.boardQueue:
        return const BoardShell(child: BoardQueueScreen(key: ValueKey('boardQueue'), currentTitle: 'Neon Midnight', currentArtist: 'Vela Cruz', singerName: 'Matt', progress: 0.42));
      case _Screen.boardPerf:
        return const BoardShell(child: BoardPerformanceScreen(key: ValueKey('boardPerf'), songTitle: 'Neon Midnight', artist: 'Vela Cruz', singerName: 'Matt', previousLine: 'Dancing in the neon midnight glow', currentLine: 'We were never meant to last this long', nextLine: 'But here we are, just proving them wrong', lineProgress: 0.65, progress: 0.42, score: 87, pitch: 88, timing: 85, combo: 12, elapsed: '1:32', duration: '3:42'));
      case _Screen.boardVs:
        return const BoardShell(child: BoardVsScreen(key: ValueKey('boardVs'), songTitle: 'Neon Midnight'));
      case _Screen.boardReveal:
        return const BoardShell(child: BoardRevealScreen(key: ValueKey('boardReveal'), singerName: 'Matt', score: 96, rank: 'SUPERSTAR', songTitle: 'Neon Midnight', isNewRecord: true, rankings: [RankingEntry(name: 'Matt', initial: 'M', score: 96), RankingEntry(name: 'Sara', initial: 'S', score: 84), RankingEntry(name: 'Dawit', initial: 'D', score: 72)]));
      case _Screen.boardLeaderboard:
        return const BoardShell(child: BoardLeaderboardScreen(key: ValueKey('boardLeaderboard'), roomName: 'Friday Night Fire', entries: [BoardLeaderboardEntry(name: 'Matt', initial: 'M', score: 96), BoardLeaderboardEntry(name: 'Sara', initial: 'S', score: 84), BoardLeaderboardEntry(name: 'Dawit', initial: 'D', score: 72), BoardLeaderboardEntry(name: 'Leah', initial: 'L', score: 68)], nextSong: 'Concrete Halo', nextPlayer: 'Sara'));

      // ─── Game Modes ─────────────────────────────────
      case _Screen.battle:
        return const BattleScreen(key: ValueKey('battle'));
      case _Screen.team:
        return const TeamScreen(key: ValueKey('team'));
      case _Screen.duet:
        return const DuetScreen(key: ValueKey('duet'));
      case _Screen.passMic:
        return const PassMicScreen(key: ValueKey('passMic'));

      // ─── Edge States ────────────────────────────────
      case _Screen.emptyQueue:
        return EmptyQueueScreen(key: const ValueKey('emptyQueue'), onAddSong: () => _go(_Screen.library));
      case _Screen.noResults:
        return const NoResultsScreen(key: ValueKey('noResults'), query: 'zzqqx');
      case _Screen.micPermission:
        return MicPermissionScreen(key: const ValueKey('micPermission'), onAllow: () => _go(_Screen.home), onSkip: () => _go(_Screen.home));
      case _Screen.micLost:
        return const MicLostScreen(key: ValueKey('micLost'));
      case _Screen.weakConnection:
        return const WeakConnectionScreen(key: ValueKey('weakConnection'));
      case _Screen.playerDropped:
        return const PlayerDroppedScreen(key: ValueKey('playerDropped'), playerName: 'Dawit');
      case _Screen.roomFull:
        return const RoomFullScreen(key: ValueKey('roomFull'));
      case _Screen.badCode:
        return const BadCodeScreen(key: ValueKey('badCode'), code: 'KARA-9999');
      case _Screen.unavailable:
        return const UnavailableSongScreen(key: ValueKey('unavailable'), songTitle: 'Neon Midnight', alternatives: ['Slow Gold', 'Tequila Sunrise Radio', 'Old Sepia Letters']);
      case _Screen.noHistory:
        return NoHistoryScreen(key: const ValueKey('noHistory'), onPickSong: () => _go(_Screen.library));
      case _Screen.noBadges:
        return const NoBadgesScreen(key: ValueKey('noBadges'));
      case _Screen.waiting:
        return const WaitingScreen(key: ValueKey('waiting'));
    }
  }

  void _showScreenPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KColors.ink700,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: KColors.bone28, borderRadius: BorderRadius.circular(2))),
            const Text('NAVIGATE TO SCREEN', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: KColors.bone45, letterSpacing: 0.16)),
            const SizedBox(height: 16),
            ..._screenGroups.map((group) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.$1.toUpperCase(), style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: KColors.lime, letterSpacing: 0.16)),
                const SizedBox(height: 8),
                ...group.$2.map((screen) => ListTile(
                  dense: true,
                  title: Text(_screenLabels[screen] ?? '', style: TextStyle(fontFamily: 'InstrumentSans', fontSize: 14, color: _currentScreen == screen ? KColors.lime : KColors.bone)),
                  trailing: _currentScreen == screen ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: KColors.lime, shape: BoxShape.circle)) : null,
                  onTap: () { Navigator.pop(context); _go(screen); },
                )),
                const SizedBox(height: 12),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

const _screenLabels = {
  _Screen.splash: 'Splash', _Screen.onboarding: 'Onboarding', _Screen.welcome: 'Welcome',
  _Screen.signin: 'Sign In', _Screen.signup: 'Sign Up', _Screen.setup: 'Setup Profile',
  _Screen.home: 'Home', _Screen.createRoom: 'Create Room', _Screen.joinRoom: 'Join Room', _Screen.qr: 'QR Scan',
  _Screen.lobby: 'Lobby', _Screen.library: 'Library', _Screen.search: 'Search', _Screen.details: 'Song Details', _Screen.queueScr: 'Queue',
  _Screen.turnNext: 'Turn Next', _Screen.turnNow: 'Turn Now', _Screen.singing: 'Singing', _Screen.complete: 'Score Reveal',
  _Screen.leaderboard: 'Leaderboard', _Screen.history: 'History', _Screen.achievements: 'Achievements', _Screen.profile: 'Profile', _Screen.settings: 'Settings',
  _Screen.boardWait: 'Board: Wait', _Screen.boardCountdown: 'Board: Countdown', _Screen.boardQueue: 'Board: Queue',
  _Screen.boardPerf: 'Board: Performance', _Screen.boardVs: 'Board: VS', _Screen.boardReveal: 'Board: Reveal', _Screen.boardLeaderboard: 'Board: Leaderboard',
  _Screen.battle: 'Battle', _Screen.team: 'Team', _Screen.duet: 'Duet', _Screen.passMic: 'Pass the Mic',
  _Screen.emptyQueue: 'Edge: Empty Queue', _Screen.noResults: 'Edge: No Results', _Screen.micPermission: 'Edge: Mic Permission',
  _Screen.micLost: 'Edge: Mic Lost', _Screen.weakConnection: 'Edge: Weak Connection', _Screen.playerDropped: 'Edge: Player Dropped',
  _Screen.roomFull: 'Edge: Room Full', _Screen.badCode: 'Edge: Bad Code', _Screen.unavailable: 'Edge: Unavailable',
  _Screen.noHistory: 'Edge: No History', _Screen.noBadges: 'Edge: No Badges', _Screen.waiting: 'Edge: Waiting',
};

const _screenGroups = [
  ('Onboarding', [_Screen.splash, _Screen.onboarding, _Screen.welcome, _Screen.signin, _Screen.signup, _Screen.setup]),
  ('Core', [_Screen.home, _Screen.createRoom, _Screen.joinRoom, _Screen.qr, _Screen.lobby, _Screen.library, _Screen.search, _Screen.details, _Screen.queueScr]),
  ('Performance', [_Screen.turnNext, _Screen.turnNow, _Screen.singing, _Screen.complete]),
  ('Profile', [_Screen.leaderboard, _Screen.history, _Screen.achievements, _Screen.profile, _Screen.settings]),
  ('Board', [_Screen.boardWait, _Screen.boardCountdown, _Screen.boardQueue, _Screen.boardPerf, _Screen.boardVs, _Screen.boardReveal, _Screen.boardLeaderboard]),
  ('Game Modes', [_Screen.battle, _Screen.team, _Screen.duet, _Screen.passMic]),
  ('Edge States', [_Screen.emptyQueue, _Screen.noResults, _Screen.micPermission, _Screen.micLost, _Screen.weakConnection, _Screen.playerDropped, _Screen.roomFull, _Screen.badCode, _Screen.unavailable, _Screen.noHistory, _Screen.noBadges, _Screen.waiting]),
];

enum _Screen {
  splash, onboarding, welcome, signin, signup, setup,
  home, createRoom, joinRoom, qr, lobby, library, search, details, queueScr,
  turnNext, turnNow, singing, complete,
  leaderboard, history, achievements, profile, settings,
  boardWait, boardCountdown, boardQueue, boardPerf, boardVs, boardReveal, boardLeaderboard,
  battle, team, duet, passMic,
  emptyQueue, noResults, micPermission, micLost, weakConnection, playerDropped, roomFull, badCode, unavailable, noHistory, noBadges, waiting,
}
