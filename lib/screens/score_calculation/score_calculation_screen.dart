import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/player.dart';
import '../../routes/app_routes.dart';
import '../../services/vision_service.dart';
import '../../localization/app_localizations.dart';
import '../../models/game_mode.dart';
import '../../controllers/score_calculation_controller.dart';
import 'widgets/win_setup_card.dart';
import 'widgets/fan_setup_card.dart';
import 'widgets/hand_preview_card.dart';
import 'widgets/score_summary_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

class ScoreCalculationScreen extends StatefulWidget {
  final List<Player> players;
  final String? groupName;
  final int? roundWindIndex;
  final int? dealerIndex;
  final int minFan;
  final int maxFan;
  final GameMode gameMode;
  final int consecutiveDealerCount;

  const ScoreCalculationScreen({
    super.key,
    required this.players,
    this.groupName,
    this.roundWindIndex,
    this.dealerIndex,
    this.minFan = 3,
    this.maxFan = 13,
    this.gameMode = GameMode.hongKong,
    this.consecutiveDealerCount = 1,
  });

  @override
  State<ScoreCalculationScreen> createState() => _ScoreCalculationScreenState();
}

class _ScoreCalculationScreenState extends State<ScoreCalculationScreen> {
  late final ScoreCalculationController _ctrl;

  // Image state (needs context for Navigator / SnackBar)
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _ctrl = ScoreCalculationController(
      players: widget.players,
      minFan: widget.minFan,
      maxFan: widget.maxFan,
      gameMode: widget.gameMode,
      consecutiveDealerCount: widget.consecutiveDealerCount,
      roundWindIndex: widget.roundWindIndex,
      dealerIndex: widget.dealerIndex,
    );
    _ctrl.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _ctrl.dispose();
    super.dispose();
  }

  // =============================================
  //  Actions that need BuildContext
  // =============================================

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        _ctrl.selectedTiles.clear();
      });
      _ctrl.setAnalyzing(true);

      try {
        final detectedTiles = await VisionService.analyzeImage(_capturedImage!);

        detectedTiles.sort((a, b) {
          if (a.length < 2 || b.length < 2) return a.compareTo(b);
          final suitA = a.substring(a.length - 1);
          final suitB = b.substring(b.length - 1);
          final valA = a.substring(0, a.length - 1);
          final valB = b.substring(0, b.length - 1);

          if (suitA != suitB) {
            const order = ['m', 'p', 's', 'z', 'f'];
            int idxA = order.indexOf(suitA);
            int idxB = order.indexOf(suitB);
            if (idxA == -1) idxA = 99;
            if (idxB == -1) idxB = 99;
            return idxA.compareTo(idxB);
          }
          return valA.compareTo(valB);
        });

        if (mounted) {
          _ctrl.setAnalyzing(false);
          _ctrl.setSelectedTiles(detectedTiles);
        }
      } catch (e) {
        if (mounted) {
          _ctrl.setAnalyzing(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to analyze tiles: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectHand() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.tileSelection,
      arguments: TileSelectionArgs(
        initialTiles: _ctrl.selectedTiles,
        gameMode: widget.gameMode,
      ),
    ) as List<String>?;

    if (result != null) {
      setState(() {
        _capturedImage = null;
      });
      _ctrl.setSelectedTiles(result);
    }
  }

  void _submitScore() {
    final result = _ctrl.buildSubmitResult();
    if (result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Score updated, next round')),
    );
    Navigator.pop(context, result);
  }

  // =============================================
  //  Build (uses extracted sub-widgets)
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName ?? AppLocalizations.scoreCalculation),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Rules Reference',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.rules);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppDimens.paddingAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Win setup card
            WinSetupCard(
              isSelfDraw: _ctrl.isSelfDraw,
              winningPlayer: _ctrl.winningPlayer,
              discardPlayer: _ctrl.discardPlayer,
              roundWind: _ctrl.roundWind,
              seatWind: _ctrl.seatWind,
              players: widget.players,
              winds: _ctrl.winds,
              onSelfDrawChanged: (value) => _ctrl.setSelfDraw(value),
              onWinningPlayerChanged: (v) => _ctrl.setWinningPlayer(v),
              onDiscardPlayerChanged: (v) => _ctrl.setDiscardPlayer(v),
              onRoundWindChanged: (v) => _ctrl.setRoundWind(v),
              onSeatWindChanged: (v) => _ctrl.setSeatWind(v),
              getPlayerCurrentScore: _ctrl.getPlayerCurrentScore,
            ),

            const SizedBox(height: 16),

            // 2. Fan setup card
            FanSetupCard(
              effectiveFan: _ctrl.effectiveFan,
              gameMode: widget.gameMode,
              selectedSpecialCondition: _ctrl.selectedSpecialCondition,
              activeSpecialConditions: _ctrl.activeSpecialConditions,
              onFanChanged: (v) => _ctrl.setFan(v),
              onSpecialConditionChanged: (v) => _ctrl.setSpecialCondition(v),
              getLocalizedCondition: _ctrl.getLocalizedCondition,
            ),

            const SizedBox(height: 16),

            // 3. Hand preview (buttons + tiles + flowers)
            HandPreviewCard(
              isAnalyzing: _ctrl.isAnalyzing,
              capturedImage: _capturedImage,
              selectedTiles: _ctrl.selectedTiles,
              selectedFlowers: _ctrl.selectedFlowers,
              onSelectHand: _selectHand,
              onCaptureImage: _captureImage,
              onFlowerToggled: (key) => _ctrl.toggleFlower(key),
              getAssetPath: _ctrl.getAssetPath,
            ),

            const SizedBox(height: 16),

            // 4. Score summary
            ScoreSummaryCard(
              displayRules: _ctrl.displayRules,
              effectiveFan: _ctrl.effectiveFan,
              totalPoints: _ctrl.totalPoints,
              isSelfDraw: _ctrl.isSelfDraw,
              playerCount: widget.players.length,
              gameMode: widget.gameMode,
              maxFan: widget.maxFan,
            ),

            const SizedBox(height: 24),

            // 5. Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.black,
                      padding: AppDimens.paddingVerticalLg,
                    ),
                    onPressed: _submitScore,
                    child: Text(AppLocalizations.nextRound,
                        style: const TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.white
                              : AppColors.black,
                      side: BorderSide(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.grey600
                                : AppColors.grey300,
                      ),
                      padding: AppDimens.paddingVerticalLg,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.cancel,
                        style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
