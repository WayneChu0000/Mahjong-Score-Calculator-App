import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../models/game_mode.dart';
import '../screens/splash_screen.dart';
import '../screens/auth_wrapper.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/player_setup.dart';
import '../screens/score_recording/score_recording_screen.dart';
import '../screens/score_calculation/score_calculation_screen.dart';
import '../screens/tile_selection_screen.dart';
import '../screens/rules_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/saved_groups_screen.dart';
import '../screens/group_detail_screen.dart';

/// Centralized route generator.
///
/// Screens that require typed arguments receive them via
/// [RouteSettings.arguments] cast to the appropriate type.
///
/// Usage in main.dart:
/// ```dart
/// MaterialApp(
///   initialRoute: AppRoutes.splash,
///   onGenerateRoute: AppRouter.generateRoute,
/// )
/// ```
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _build(const SplashScreen(), settings);

      case AppRoutes.auth:
        return _build(const AuthWrapper(), settings);

      case AppRoutes.home:
        return _build(const HomePage(), settings);

      case AppRoutes.login:
        return _build(const LoginScreen(), settings);

      case AppRoutes.playerSetup:
        final args = settings.arguments as PlayerSetupArgs?;
        return _build(
          PlayerSetupScreen(
            existingPlayers: args?.existingPlayers,
            groupName: args?.groupName,
            groupId: args?.groupId,
            directStart: args?.directStart ?? false,
            currentRound: args?.currentRound,
            dealerIndex: args?.dealerIndex,
            prevalentWindIndex: args?.prevalentWindIndex,
            currentDealerGameCount: args?.currentDealerGameCount,
            totalWindRounds: args?.totalWindRounds,
            initialGameMode: args?.initialGameMode,
          ),
          settings,
        );

      case AppRoutes.rules:
        return _build(const RulesScreen(), settings);

      case AppRoutes.settings:
        return _build(const SettingsScreen(), settings);

      case AppRoutes.savedGroups:
        return _build(const SavedGroupsScreen(), settings);

      case AppRoutes.groupDetail:
        final group = settings.arguments as GroupDetailArgs;
        return _build(GroupDetailScreen(group: group.group), settings);

      case AppRoutes.scoreRecording:
        final args = settings.arguments as ScoreRecordingArgs;
        return _build(
          ScoreRecordingScreen(
            players: args.players,
            currentRound: args.currentRound,
            totalRounds: args.totalRounds,
            onScoreSubmitted: args.onScoreSubmitted,
            groupId: args.groupId,
            groupName: args.groupName,
            initialDealerIndex: args.initialDealerIndex,
            initialPrevalentWindIndex: args.initialPrevalentWindIndex,
            initialDealerGameCount: args.initialDealerGameCount,
            initialTotalWindRounds: args.initialTotalWindRounds,
            minFan: args.minFan,
            maxFan: args.maxFan,
            gameMode: args.gameMode,
          ),
          settings,
        );

      case AppRoutes.scoreCalculation:
        final args = settings.arguments as ScoreCalculationArgs;
        return _build(
          ScoreCalculationScreen(
            players: args.players,
            groupName: args.groupName,
            roundWindIndex: args.roundWindIndex,
            dealerIndex: args.dealerIndex,
            minFan: args.minFan,
            maxFan: args.maxFan,
            gameMode: args.gameMode,
            consecutiveDealerCount: args.consecutiveDealerCount,
          ),
          settings,
        );

      case AppRoutes.tileSelection:
        final args = settings.arguments as TileSelectionArgs?;
        return _build(
          TileSelectionScreen(
            initialTiles: args?.initialTiles ?? const [],
            gameMode: args?.gameMode ?? GameMode.hongKong,
          ),
          settings,
        );

      default:
        return _build(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _build(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
