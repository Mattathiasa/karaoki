import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'theme/colors.dart';
import 'providers/app_state.dart';
import 'services/room_service.dart';
import 'services/performance_service.dart';
import 'services/audio_service.dart';
import 'services/mic_service.dart';
import 'services/realtime_sync_service.dart';
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

// ─── Go Router Configuration ───────────────────────
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Phone / Controller routes
    GoRoute(path: '/', builder: (ctx, state) => const SplashScreen(key: ValueKey('splash'))),
    GoRoute(path: '/onboarding', builder: (ctx, state) => const OnboardingScreen(key: ValueKey('onboarding'))),
    GoRoute(path: '/welcome', builder: (ctx, state) => const WelcomeScreen(key: ValueKey('welcome'))),
    GoRoute(path: '/signin', builder: (ctx, state) => const SigninScreen(key: ValueKey('signin'))),
    GoRoute(path: '/signup', builder: (ctx, state) => const SignupScreen(key: ValueKey('signup'))),
    GoRoute(path: '/setup', builder: (ctx, state) => const SetupScreen(key: ValueKey('setup'))),
    GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen(key: ValueKey('home'))),
    GoRoute(path: '/create-room', builder: (ctx, state) => const CreateRoomScreen(key: ValueKey('createRoom'))),
    GoRoute(path: '/join-room', builder: (ctx, state) => const JoinRoomScreen(key: ValueKey('joinRoom'))),
    GoRoute(path: '/qr', builder: (ctx, state) => const QrScreen(key: ValueKey('qr'))),
    GoRoute(path: '/lobby', builder: (ctx, state) => const LobbyScreen(key: ValueKey('lobby'))),
    GoRoute(path: '/library', builder: (ctx, state) => const LibraryScreen(key: ValueKey('library'))),
    GoRoute(path: '/search', builder: (ctx, state) => const SearchScreen(key: ValueKey('search'))),
    GoRoute(path: '/details', builder: (ctx, state) => const DetailsScreen(key: ValueKey('details'))),
    GoRoute(path: '/queue', builder: (ctx, state) => const QueueScreen(key: ValueKey('queueScr'))),
    GoRoute(path: '/turn-next', builder: (ctx, state) => const TurnNextScreen(key: ValueKey('turnNext'))),
    GoRoute(path: '/turn-now', builder: (ctx, state) => const TurnNowScreen(key: ValueKey('turnNow'))),
    GoRoute(path: '/singing', builder: (ctx, state) => const SingingScreen(key: ValueKey('singing'))),
    GoRoute(path: '/complete', builder: (ctx, state) => const CompleteScreen(key: ValueKey('complete'))),
    GoRoute(path: '/leaderboard', builder: (ctx, state) => const LeaderboardScreen(key: ValueKey('leaderboard'))),
    GoRoute(path: '/history', builder: (ctx, state) => const HistoryScreen(key: ValueKey('history'))),
    GoRoute(path: '/achievements', builder: (ctx, state) => const AchievementsScreen(key: ValueKey('achievements'))),
    GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen(key: ValueKey('profile'))),
    GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen(key: ValueKey('settings'))),

    // Board / TV routes
    GoRoute(path: '/tv', builder: (ctx, state) => const BoardShell(child: BoardWaitScreen(key: ValueKey('boardWait')))),
    GoRoute(path: '/tv/countdown', builder: (ctx, state) => const BoardShell(child: BoardCountdownScreen(key: ValueKey('boardCountdown')))),
    GoRoute(path: '/tv/queue', builder: (ctx, state) => const BoardShell(child: BoardQueueScreen(key: ValueKey('boardQueue')))),
    GoRoute(path: '/tv/performance', builder: (ctx, state) => const BoardShell(child: BoardPerformanceScreen(key: ValueKey('boardPerf')))),
    GoRoute(path: '/tv/vs', builder: (ctx, state) => const BoardShell(child: BoardVsScreen(key: ValueKey('boardVs')))),
    GoRoute(path: '/tv/reveal', builder: (ctx, state) => const BoardShell(child: BoardRevealScreen(key: ValueKey('boardReveal')))),
    GoRoute(path: '/tv/leaderboard', builder: (ctx, state) => const BoardShell(child: BoardLeaderboardScreen(key: ValueKey('boardLeaderboard')))),

    // Game mode routes
    GoRoute(path: '/battle', builder: (ctx, state) => const BattleScreen(key: ValueKey('battle'))),
    GoRoute(path: '/team', builder: (ctx, state) => const TeamScreen(key: ValueKey('team'))),
    GoRoute(path: '/duet', builder: (ctx, state) => const DuetScreen(key: ValueKey('duet'))),
    GoRoute(path: '/pass-mic', builder: (ctx, state) => const PassMicScreen(key: ValueKey('passMic'))),

    // Edge state routes
    GoRoute(path: '/edge/empty-queue', builder: (ctx, state) => const EmptyQueueScreen(key: ValueKey('emptyQueue'))),
    GoRoute(path: '/edge/no-results', builder: (ctx, state) => const NoResultsScreen(key: ValueKey('noResults'))),
    GoRoute(path: '/edge/mic-permission', builder: (ctx, state) => const MicPermissionScreen(key: ValueKey('micPermission'))),
    GoRoute(path: '/edge/mic-lost', builder: (ctx, state) => const MicLostScreen(key: ValueKey('micLost'))),
    GoRoute(path: '/edge/weak-connection', builder: (ctx, state) => const WeakConnectionScreen(key: ValueKey('weakConnection'))),
    GoRoute(path: '/edge/player-dropped', builder: (ctx, state) => const PlayerDroppedScreen(key: ValueKey('playerDropped'))),
    GoRoute(path: '/edge/room-full', builder: (ctx, state) => const RoomFullScreen(key: ValueKey('roomFull'))),
    GoRoute(path: '/edge/bad-code', builder: (ctx, state) => const BadCodeScreen(key: ValueKey('badCode'))),
    GoRoute(path: '/edge/unavailable', builder: (ctx, state) => const UnavailableSongScreen(key: ValueKey('unavailable'))),
    GoRoute(path: '/edge/no-history', builder: (ctx, state) => const NoHistoryScreen(key: ValueKey('noHistory'))),
    GoRoute(path: '/edge/no-badges', builder: (ctx, state) => const NoBadgesScreen(key: ValueKey('noBadges'))),
    GoRoute(path: '/edge/waiting', builder: (ctx, state) => const WaitingScreen(key: ValueKey('waiting'))),
  ],
);

class KaraokiApp extends StatelessWidget {
  const KaraokiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider<RoomService>(create: (_) => StubRoomService()),
        Provider<PerformanceService>(create: (_) => PerformanceService()),
        Provider<AudioPlaybackService>(create: (_) => AudioPlaybackService()),
        Provider<MicService>(create: (_) => MicService()),
        Provider<RealtimeSyncService>(create: (_) => StubRealtimeSyncService()),
      ],
      child: MaterialApp.router(
        title: 'Zemaoki',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
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
      ),
    );
  }
}
