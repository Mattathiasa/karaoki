import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/lobby/lobby_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/singing/singing_screen.dart';
import 'screens/singing/complete_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/board/board_wait_screen.dart';
import 'screens/board/board_performance_screen.dart';
import 'screens/board/board_reveal_screen.dart';
import 'screens/board/board_countdown_screen.dart';
import 'screens/board/board_queue_screen.dart';
import 'screens/board/board_vs_screen.dart';
import 'screens/board/board_leaderboard_screen.dart';
import 'screens/edge_states/edge_states.dart';
import 'screens/game_modes/game_modes.dart';

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

/// Router that handles navigation between screens
class KaraokiRouter extends StatefulWidget {
  const KaraokiRouter({super.key});

  @override
  State<KaraokiRouter> createState() => _KaraokiRouterState();
}

class _KaraokiRouterState extends State<KaraokiRouter> {
  _Screen _currentScreen = _Screen.splash;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      child: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case _Screen.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () => setState(() => _currentScreen = _Screen.onboarding),
        );

      case _Screen.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onComplete: () => setState(() => _currentScreen = _Screen.welcome),
        );

      case _Screen.welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onContinue: () => setState(() => _currentScreen = _Screen.home),
        );

      case _Screen.home:
        return HomeScreen(
          key: const ValueKey('home'),
          onJoinRoom: () => setState(() => _currentScreen = _Screen.lobby),
          onCreateRoom: () => setState(() => _currentScreen = _Screen.lobby),
          onSolo: () => setState(() => _currentScreen = _Screen.library),
          onProfile: () => setState(() => _currentScreen = _Screen.leaderboard),
        );

      case _Screen.lobby:
        return LobbyScreen(
          key: const ValueKey('lobby'),
          roomName: 'Friday Night Fire',
          roomCode: 'KARA-7821',
          hostName: 'MATT',
          playerCount: 4,
          maxPlayers: 8,
          players: const [
            LobbyPlayer(name: 'Matt', initial: 'M', level: 24, ready: true, isHost: true),
            LobbyPlayer(name: 'Sara', initial: 'S', level: 18, ready: true),
            LobbyPlayer(name: 'Dawit', initial: 'D', level: 12, ready: true),
            LobbyPlayer(name: 'Leah', initial: 'L', level: 8, ready: false),
          ],
          onStart: () => setState(() => _currentScreen = _Screen.singing),
          onBrowseSongs: () => setState(() => _currentScreen = _Screen.library),
        );

      case _Screen.library:
        return LibraryScreen(
          key: const ValueKey('library'),
          onSongSelected: () => setState(() => _currentScreen = _Screen.lobby),
        );

      case _Screen.singing:
        return const SingingScreen(
          key: ValueKey('singing'),
          previousLine: 'Dancing in the neon midnight glow',
          currentLine: 'We were never meant to last this long',
          nextLine: 'But here we are, just proving them wrong',
          lineProgress: 0.65,
          progress: 0.42,
          pitch: 88,
          timing: 85,
          combo: 12,
          score: 87,
          elapsed: '1:32',
          duration: '3:42',
        );

      case _Screen.complete:
        return const CompleteScreen(
          key: ValueKey('complete'),
          score: 87,
          pitch: 92,
          timing: 88,
          consistency: 81,
          energy: 95,
          isNewBest: true,
          previousBest: 78,
        );

      case _Screen.leaderboard:
        return const LeaderboardScreen(
          key: ValueKey('leaderboard'),
        );

      case _Screen.boardWait:
        return const BoardWaitScreen(
          key: ValueKey('boardWait'),
          roomName: 'Friday Night Fire',
          roomCode: 'KARA-7821',
          mode: 'CLASSIC',
          playerCount: 4,
          maxPlayers: 8,
        );

      case _Screen.boardPerf:
        return const BoardPerformanceScreen(
          key: ValueKey('boardPerf'),
          songTitle: 'Neon Midnight',
          artist: 'Vela Cruz',
          singerName: 'Matt',
          previousLine: 'Dancing in the neon midnight glow',
          currentLine: 'We were never meant to last this long',
          nextLine: 'But here we are, just proving them wrong',
          lineProgress: 0.65,
          progress: 0.42,
          score: 87,
          pitch: 88,
          timing: 85,
          combo: 12,
          elapsed: '1:32',
          duration: '3:42',
        );

      case _Screen.boardReveal:
        return const BoardRevealScreen(
          key: ValueKey('boardReveal'),
          singerName: 'Matt',
          score: 96,
          rank: 'SUPERSTAR',
          songTitle: 'Neon Midnight',
          isNewRecord: true,
          rankings: [
            RankingEntry(name: 'Matt', initial: 'M', score: 96),
            RankingEntry(name: 'Sara', initial: 'S', score: 84),
            RankingEntry(name: 'Dawit', initial: 'D', score: 72),
          ],
        );

      case _Screen.boardCountdown:
        return BoardCountdownScreen(
          key: const ValueKey('boardCountdown'),
          singerName: 'Matt',
          songTitle: 'Neon Midnight',
          onComplete: () => setState(() => _currentScreen = _Screen.boardPerf),
        );

      case _Screen.boardQueue:
        return const BoardQueueScreen(
          key: ValueKey('boardQueue'),
          currentTitle: 'Neon Midnight',
          currentArtist: 'Vela Cruz',
          singerName: 'Matt',
          progress: 0.42,
        );

      case _Screen.boardVs:
        return const BoardVsScreen(
          key: ValueKey('boardVs'),
          songTitle: 'Neon Midnight',
        );

      case _Screen.boardLeaderboard:
        return const BoardLeaderboardScreen(
          key: ValueKey('boardLeaderboard'),
          roomName: 'Friday Night Fire',
          entries: [
            BoardLeaderboardEntry(name: 'Matt', initial: 'M', score: 96),
            BoardLeaderboardEntry(name: 'Sara', initial: 'S', score: 84),
            BoardLeaderboardEntry(name: 'Dawit', initial: 'D', score: 72),
            BoardLeaderboardEntry(name: 'Leah', initial: 'L', score: 68),
          ],
          nextSong: 'Concrete Halo',
          nextPlayer: 'Sara',
        );

      case _Screen.battle:
        return const BattleScreen(key: ValueKey('battle'));

      case _Screen.team:
        return const TeamScreen(key: ValueKey('team'));

      case _Screen.duet:
        return const DuetScreen(key: ValueKey('duet'));

      case _Screen.passMic:
        return const PassMicScreen(key: ValueKey('passMic'));

      case _Screen.emptyQueue:
        return EmptyQueueScreen(
          key: const ValueKey('emptyQueue'),
          onAddSong: () => setState(() => _currentScreen = _Screen.library),
        );

      case _Screen.noResults:
        return const NoResultsScreen(
          key: ValueKey('noResults'),
          query: 'zzqqx',
        );

      case _Screen.micPermission:
        return MicPermissionScreen(
          key: const ValueKey('micPermission'),
          onAllow: () => setState(() => _currentScreen = _Screen.home),
          onSkip: () => setState(() => _currentScreen = _Screen.home),
        );

      case _Screen.micLost:
        return const MicLostScreen(key: ValueKey('micLost'));

      case _Screen.weakConnection:
        return const WeakConnectionScreen(key: ValueKey('weakConnection'));

      case _Screen.playerDropped:
        return const PlayerDroppedScreen(
          key: ValueKey('playerDropped'),
          playerName: 'Dawit',
        );

      case _Screen.roomFull:
        return const RoomFullScreen(key: ValueKey('roomFull'));

      case _Screen.badCode:
        return const BadCodeScreen(
          key: ValueKey('badCode'),
          code: 'KARA-9999',
        );

      case _Screen.unavailable:
        return const UnavailableSongScreen(
          key: ValueKey('unavailable'),
          songTitle: 'Neon Midnight',
          alternatives: ['Slow Gold', 'Tequila Sunrise Radio', 'Old Sepia Letters'],
        );

      case _Screen.noHistory:
        return NoHistoryScreen(
          key: const ValueKey('noHistory'),
          onPickSong: () => setState(() => _currentScreen = _Screen.library),
        );

      case _Screen.noBadges:
        return const NoBadgesScreen(key: ValueKey('noBadges'));

      case _Screen.waiting:
        return const WaitingScreen(key: ValueKey('waiting'));
    }
  }
}

enum _Screen {
  splash,
  onboarding,
  welcome,
  home,
  lobby,
  library,
  singing,
  complete,
  leaderboard,
  boardWait,
  boardPerf,
  boardReveal,
  boardCountdown,
  boardQueue,
  boardVs,
  boardLeaderboard,
  battle,
  team,
  duet,
  passMic,
  emptyQueue,
  noResults,
  micPermission,
  micLost,
  weakConnection,
  playerDropped,
  roomFull,
  badCode,
  unavailable,
  noHistory,
  noBadges,
  waiting,
}


