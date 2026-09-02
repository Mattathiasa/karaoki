import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'theme/colors.dart';
import 'providers/app_state.dart';
import 'services/room_service.dart';
import 'services/performance_service.dart';
import 'services/audio_service.dart';
import 'services/karaoke_playback_service.dart';
import 'services/mic_service.dart';
import 'services/realtime_sync_service.dart';
import 'services/firebase_room_service.dart';
import 'services/firebase_sync_service.dart';

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
import 'widgets/app_shell.dart';

/// Whether Firebase is properly configured with real credentials.
bool _isFirebaseConfigured = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Check if Firebase is actually configured (not placeholder values)
    final db = FirebaseDatabase.instance;
    _isFirebaseConfigured = !(db.databaseURL ?? '').contains('YOUR_PROJECT_ID');

    if (_isFirebaseConfigured) {
      // Use persistent connection for real-time sync
      db.setPersistenceEnabled(true);
      db.setPersistenceCacheSizeBytes(10 * 1024 * 1024); // 10MB
    }
  } catch (e) {
    // Firebase not configured, fall back to stubs
    debugPrint('Firebase init failed: $e - using stub services');
    _isFirebaseConfigured = false;
  }

  runApp(const KaraokiApp());
}

// ─── Navigator Keys ────────────────────────────────
final _shellKey = GlobalKey<NavigatorState>();

// ─── Go Router Configuration ───────────────────────
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Onboarding (no bottom nav) ──
    GoRoute(
      path: '/',
      builder: (ctx, state) => SplashScreen(
        onComplete: () => ctx.go('/onboarding'),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (ctx, state) => OnboardingScreen(
        onComplete: () => ctx.go('/welcome'),
      ),
    ),
    GoRoute(
      path: '/welcome',
      builder: (ctx, state) => WelcomeScreen(
        onContinue: () => ctx.go('/home'),
      ),
    ),
    GoRoute(
      path: '/signin',
      builder: (ctx, state) => SigninScreen(
        onSignedIn: () => ctx.go('/home'),
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (ctx, state) => SignupScreen(
        onSignedUp: () => ctx.go('/setup'),
      ),
    ),
    GoRoute(
      path: '/setup',
      builder: (ctx, state) => SetupScreen(
        onComplete: () => ctx.go('/home'),
      ),
    ),

    // ── Phone routes with bottom nav shell ──
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (ctx, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (ctx, state) => HomeScreen(
            onJoinRoom: () => ctx.go('/join-room'),
            onCreateRoom: () => ctx.go('/create-room'),
            onSolo: () => ctx.go('/library'),
            onProfile: () => ctx.go('/profile'),
          ),
        ),
        GoRoute(
          path: '/create-room',
          builder: (ctx, state) => CreateRoomScreen(
            onCreate: () => ctx.go('/lobby'),
          ),
        ),
        GoRoute(
          path: '/join-room',
          builder: (ctx, state) => JoinRoomScreen(
            onJoin: () => ctx.go('/lobby'),
            onScan: () => ctx.go('/qr'),
          ),
        ),
        GoRoute(
          path: '/qr',
          builder: (ctx, state) => const QrScreen(),
        ),
        GoRoute(
          path: '/lobby',
          builder: (ctx, state) => LobbyScreen(
            onStart: () => ctx.go('/turn-next'),
            onBrowseSongs: () => ctx.go('/library'),
          ),
        ),
        GoRoute(
          path: '/library',
          builder: (ctx, state) => LibraryScreen(
            onSongSelected: () => ctx.go('/details'),
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (ctx, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/details',
          builder: (ctx, state) => DetailsScreen(
            onAddToQueue: () => ctx.go('/queue'),
          ),
        ),
        GoRoute(
          path: '/queue',
          builder: (ctx, state) => QueueScreen(
            onAddMore: () => ctx.go('/library'),
          ),
        ),
        GoRoute(
          path: '/turn-next',
          builder: (ctx, state) => TurnNextScreen(
            onReady: () => ctx.go('/turn-now'),
            onSkip: () => ctx.go('/queue'),
          ),
        ),
        GoRoute(
          path: '/turn-now',
          builder: (ctx, state) => TurnNowScreen(
            onStart: () => ctx.go('/singing'),
          ),
        ),
        GoRoute(
          path: '/singing',
          builder: (ctx, state) => SingingScreen(
            onComplete: () => ctx.go('/complete'),
          ),
        ),
        GoRoute(
          path: '/complete',
          builder: (ctx, state) => CompleteScreen(
            onContinue: () => ctx.go('/queue'),
            onLeaderboard: () => ctx.go('/leaderboard'),
          ),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (ctx, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (ctx, state) => HistoryScreen(
            onBack: () => ctx.go('/profile'),
          ),
        ),
        GoRoute(
          path: '/achievements',
          builder: (ctx, state) => AchievementsScreen(
            onBack: () => ctx.go('/profile'),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (ctx, state) => ProfileScreen(
            onBack: () => ctx.go('/home'),
            onSettings: () => ctx.go('/settings'),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (ctx, state) => SettingsScreen(
            onBack: () => ctx.go('/profile'),
          ),
        ),
      ],
    ),

    // ── Board / TV Routes (full-screen, no bottom nav) ──
    GoRoute(path: '/tv', builder: (ctx, state) => const BoardShell(child: BoardWaitScreen())),
    GoRoute(path: '/tv/countdown', builder: (ctx, state) => const BoardShell(child: BoardCountdownScreen())),
    GoRoute(path: '/tv/queue', builder: (ctx, state) => const BoardShell(child: BoardQueueScreen())),
    GoRoute(path: '/tv/performance', builder: (ctx, state) => const BoardShell(child: BoardPerformanceScreen())),
    GoRoute(path: '/tv/vs', builder: (ctx, state) => const BoardShell(child: BoardVsScreen())),
    GoRoute(path: '/tv/reveal', builder: (ctx, state) => const BoardShell(child: BoardRevealScreen())),
    GoRoute(path: '/tv/leaderboard', builder: (ctx, state) => const BoardShell(child: BoardLeaderboardScreen())),

    // ── Game Mode Routes (full-screen) ──
    GoRoute(path: '/battle', builder: (ctx, state) => const BattleScreen()),
    GoRoute(path: '/team', builder: (ctx, state) => const TeamScreen()),
    GoRoute(path: '/duet', builder: (ctx, state) => const DuetScreen()),
    GoRoute(path: '/pass-mic', builder: (ctx, state) => const PassMicScreen()),

    // ── Edge State Routes (full-screen) ──
    GoRoute(path: '/edge/empty-queue', builder: (ctx, state) => const EmptyQueueScreen()),
    GoRoute(path: '/edge/no-results', builder: (ctx, state) => const NoResultsScreen()),
    GoRoute(path: '/edge/mic-permission', builder: (ctx, state) => const MicPermissionScreen()),
    GoRoute(path: '/edge/mic-lost', builder: (ctx, state) => const MicLostScreen()),
    GoRoute(path: '/edge/weak-connection', builder: (ctx, state) => const WeakConnectionScreen()),
    GoRoute(path: '/edge/player-dropped', builder: (ctx, state) => const PlayerDroppedScreen()),
    GoRoute(path: '/edge/room-full', builder: (ctx, state) => const RoomFullScreen()),
    GoRoute(path: '/edge/bad-code', builder: (ctx, state) => const BadCodeScreen()),
    GoRoute(path: '/edge/unavailable', builder: (ctx, state) => const UnavailableSongScreen()),
    GoRoute(path: '/edge/no-history', builder: (ctx, state) => const NoHistoryScreen()),
    GoRoute(path: '/edge/no-badges', builder: (ctx, state) => const NoBadgesScreen()),
    GoRoute(path: '/edge/waiting', builder: (ctx, state) => const WaitingScreen()),
  ],
);

class KaraokiApp extends StatelessWidget {
  const KaraokiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        // Use Firebase services if configured, otherwise stubs
        Provider<RoomService>(
          create: (_) => _isFirebaseConfigured
              ? FirebaseRoomService()
              : StubRoomService(),
        ),
        Provider<PerformanceService>(create: (_) => PerformanceService()),
        Provider<AudioPlaybackService>(create: (_) => AudioPlaybackService()),
        Provider<KaraokePlaybackService>(
          create: (_) => KaraokePlaybackService(),
          dispose: (_, svc) => svc.dispose(),
        ),
        Provider<MicInputService>(
          create: (_) => MicInputService(),
          dispose: (_, svc) => svc.dispose(),
        ),
        Provider<RealtimeSyncService>(
          create: (_) => _isFirebaseConfigured
              ? FirebaseRealtimeSyncService()
              : StubRealtimeSyncService(),
        ),
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
