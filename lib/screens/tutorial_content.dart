import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/mahjong_tile.dart';
import '../localization/app_localizations.dart';
import '../services/settings_service.dart';
import '../models/game_mode.dart';
import '../models/tw_rules.dart';
import '../models/rule.dart';

class TutorialContent extends StatelessWidget {
  final int pageIndex;
  final Function(String)? onRuleTap;
  final GameMode gameMode;

  const TutorialContent({
    super.key,
    required this.pageIndex,
    this.onRuleTap,
    this.gameMode = GameMode.hongKong,
  });

  @override
  Widget build(BuildContext context) {
    switch (pageIndex) {
      case 0:
        return _buildIntroductionPage();
      case 1:
        return _buildTileTypesPage();
      case 2:
        return _buildBasicRulesPage();
      case 3:
        return _buildScoringPage(context, gameMode);
      default:
        return _buildIntroductionPage();
    }
  }

  Widget _buildIntroductionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.welcomeTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.appDescription,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Text(
            AppLocalizations.keyFeatures,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildFeatureItem(
            Icons.calculate,
            AppLocalizations.smartCalculatorTitle,
            AppLocalizations.smartCalculatorDesc,
          ),
          _buildFeatureItem(
            Icons.history,
            AppLocalizations.gameRecordingTitle,
            AppLocalizations.gameRecordingDesc,
          ),
          _buildFeatureItem(
            Icons.menu_book,
            AppLocalizations.rulesReferenceTitle,
            AppLocalizations.rulesReferenceDesc,
          ),
          _buildFeatureItem(
            Icons.group,
            AppLocalizations.playerManagementTitle,
            AppLocalizations.playerManagementDesc,
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              AppLocalizations.swipeToLearn,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileTypesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.tileTypesTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Character tiles
          _buildTileSection(
            AppLocalizations.characterTiles,
            AppLocalizations.characterTilesDesc,
            ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m'],
          ),

          const SizedBox(height: 16),

          // Dots tiles
          _buildTileSection(
            AppLocalizations.dotsTiles,
            AppLocalizations.dotsTilesDesc,
            ['1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p'],
          ),

          const SizedBox(height: 16),

          // Bamboo tiles
          _buildTileSection(
            AppLocalizations.bambooTiles,
            AppLocalizations.bambooTilesDesc,
            ['1s', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s'],
          ),

          const SizedBox(height: 16),

          // Honor tiles
          _buildTileSection(
            AppLocalizations.honorTiles,
            AppLocalizations.honorTilesDesc,
            ['1z', '2z', '3z', '4z', '5z', '6z', '7z'],
          ),

          const SizedBox(height: 16),

          // Flower tiles
          _buildTileSection(
            AppLocalizations.flowerTiles,
            AppLocalizations.flowerTilesDesc,
            ['1f', '2f', '3f', '4f', '5f', '6f', '7f', '8f'],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTileSection(
    String title,
    String description,
    List<String> tiles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tiles.map((tile) => MahjongTile(tile: tile)).toList(),
        ),
      ],
    );
  }

  Widget _buildBasicRulesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.basicRulesTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Text(
            AppLocalizations.gameObjectiveTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.gameObjectiveDesc1),
          Text(AppLocalizations.gameObjectiveDesc2),
          Text(AppLocalizations.gameObjectiveDesc3),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.basicTermsTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.basicTermsChow),
          Text(AppLocalizations.basicTermsPong),
          Text(AppLocalizations.basicTermsEyes),
          Text(AppLocalizations.basicTermsSelfDraw),
          Text(AppLocalizations.basicTermsDiscard),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.startingGameTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.startingGameDesc),
          const SizedBox(height: 8),

          // Dice Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.diceRollTableTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDiceRow('5, 9, 13, 17', AppLocalizations.diceDealerEast),
                _buildDiceRow('6, 10, 14, 18', AppLocalizations.diceSouthRight),
                _buildDiceRow(
                  '3, 7, 11, 15',
                  AppLocalizations.diceWestOpposite,
                ),
                _buildDiceRow('4, 8, 12, 16', AppLocalizations.diceNorthLeft),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.counterClockwiseCount,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(AppLocalizations.exampleRoll8),
          Text(AppLocalizations.drawClockwise),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.amber.withValues(alpha: 0.2),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text(AppLocalizations.rememberDirection)),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            AppLocalizations.dealingProcedureTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(AppLocalizations.dealStep1),
          Text(AppLocalizations.dealStep2),
          Text(AppLocalizations.dealStep3),
          Text(AppLocalizations.dealStep4),
          Text(AppLocalizations.dealStep5),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.gameplayProcessTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.gameplayProcessDesc),

          const SizedBox(height: 12),
          Text(
            AppLocalizations.standardTurnTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.download),
                    Text(AppLocalizations.drawAction),
                  ],
                ),
                const Icon(Icons.arrow_forward),
                Column(
                  children: [
                    const Icon(Icons.touch_app),
                    Text(AppLocalizations.actionAction),
                  ],
                ),
                const Icon(Icons.arrow_forward),
                Column(
                  children: [
                    const Icon(Icons.upload),
                    Text(AppLocalizations.discardAction),
                  ],
                ),
              ],
            ),
          ),
          Text(AppLocalizations.turnStep1),
          Text(AppLocalizations.turnStep2),
          Text(AppLocalizations.turnStep3),
          Text(AppLocalizations.turnStep4),

          const SizedBox(height: 16),
          Text(
            AppLocalizations.interactionsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(AppLocalizations.interactionsDesc),

          const SizedBox(height: 8),
          _buildInteractionRow(
            AppLocalizations.actionChow,
            AppLocalizations.targetLeftPlayer,
            AppLocalizations.descChowInteract,
            Colors.blue.shade100,
          ),
          _buildInteractionRow(
            AppLocalizations.actionPong,
            AppLocalizations.targetAnyPlayer,
            AppLocalizations.descPongInteract,
            Colors.green.shade100,
          ),
          _buildInteractionRow(
            AppLocalizations.actionKong,
            AppLocalizations.targetAnyPlayer,
            AppLocalizations.descKongInteract,
            Colors.purple.shade100,
          ),
          _buildInteractionRow(
            AppLocalizations.actionWinInteract,
            AppLocalizations.targetAnyPlayer,
            AppLocalizations.descWinInteract,
            Colors.red.shade100,
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.priorityRuleTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Text(AppLocalizations.priorityRuleDesc),
                const SizedBox(height: 4),
                Text(AppLocalizations.priorityPongWins),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            AppLocalizations.missedWinTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(AppLocalizations.missedWinDesc),
          const SizedBox(height: 4),
          Text(AppLocalizations.missedWinException),
        ],
      ),
    );
  }

  Widget _buildInteractionRow(
    String action,
    String target,
    String desc,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              action,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(desc, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceRow(String numbers, String wall) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              numbers,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(wall, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildScoringPage(BuildContext context, GameMode mode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = context.read<SettingsService>().language;

    if (mode == GameMode.taiwan) {
      return _buildTwScoringPage(context, isDark);
    }

    return _buildHkScoringPage(context, isDark, language);
  }

  // ── Taiwan Scoring Tutorial ──
  Widget _buildTwScoringPage(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.twScoringRulesTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.twScoringRulesDesc,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),

          // ── Scoring formula ──
          _buildTwSectionHeader(
            AppLocalizations.twScoringFormulaTitle,
            Icons.calculate,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.amber.shade50,
              border: Border.all(color: Colors.amber),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.twScoringFormulaDesc,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(AppLocalizations.twScoringExample),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.twScoringDefault,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Dealer bonus ──
          _buildTwSectionHeader(
            AppLocalizations.twDealerBonusTitle,
            Icons.star,
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.twDealerBonusDesc),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blue.withValues(alpha: 0.15)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.twDealerBonusBase,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.twDealerBonusFormula,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text(AppLocalizations.twDealerBonusExample1),
                Text(AppLocalizations.twDealerBonusExample2),
                Text(AppLocalizations.twDealerBonusExample3),
                const Divider(),
                Text(
                  AppLocalizations.twDealerBonusResponsibility,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Instant payment ──
          _buildTwSectionHeader(
            AppLocalizations.twInstantPayTitle,
            Icons.payments,
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.twInstantPayDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ...twInstantPayRules.map((r) => _buildTwInfoRow(context, r, isDark)),

          const SizedBox(height: 24),

          // ── Penalties ──
          _buildTwSectionHeader(AppLocalizations.twPenaltiesTitle, Icons.gavel),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.twPenaltiesDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ...twPenaltyRules.map((r) => _buildTwInfoRow(context, r, isDark)),

          const SizedBox(height: 24),

          // ── 拉 settlement ──
          _buildTwSectionHeader(
            AppLocalizations.twLaSettlementTitle,
            Icons.sync,
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.twLaSettlementDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ...twLaSettlementRules.map(
            (r) => _buildTwInfoRow(context, r, isDark),
          ),

          const SizedBox(height: 24),

          // ── Winning patterns (TW scoring) ──
          Text(
            AppLocalizations.winningPatternsTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...getRules(
            GameMode.taiwan,
          ).map((r) => _buildClickableRuleRow(context, r.name, r.fan)),

          const SizedBox(height: 16),

          // ── Stacking / exclusion rules ──
          _buildTwSectionHeader(
            AppLocalizations.twStackRulesTitle,
            Icons.warning_amber,
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.twStackRulesDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.orange.withValues(alpha: 0.15)
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStackRuleItem('1', AppLocalizations.twStackRule1),
                _buildStackRuleItem('2', AppLocalizations.twStackRule2),
                _buildStackRuleItem('3', AppLocalizations.twStackRule3),
                _buildStackRuleItem('4', AppLocalizations.twStackRule4),
                _buildStackRuleItem('5', AppLocalizations.twStackRule5),
                _buildStackRuleItem('6', AppLocalizations.twStackRule6),
                _buildStackRuleItem('7', AppLocalizations.twStackRule7),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTwSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStackRuleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.orange.shade300,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTwInfoRow(BuildContext context, Rule rule, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rule.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(rule.description, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // ── Hong Kong Scoring Tutorial (original) ──
  Widget _buildHkScoringPage(
    BuildContext context,
    bool isDark,
    String language,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.scoringSystemTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Text(
            AppLocalizations.scoringRulesTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.scoringRulesDesc),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.amber.shade50,
              border: Border.all(color: Colors.amber),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.fanLimitSettings,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  language == 'Traditional Chinese'
                      ? '標準香港麻將通常設有「3番起胡」及「13番封頂」的限制。但在本程式中，您可以在開始新一局時（選莊家頁面）自訂這些限制：'
                      : 'Standard Hong Kong Mahjong is played with a minimum of 3 Fan to win and a maximum of 13 Fan. However, you can customize these limits when starting a new game:',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove_circle_outline, size: 16),
                    const Text(" / "),
                    const Icon(Icons.add_circle_outline, size: 16),
                    Text(
                      language == 'Traditional Chinese'
                          ? ' 使用按鈕調整番數限制'
                          : ' Use buttons to adjust limits',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  language == 'Traditional Chinese'
                      ? '• 最少番數: 預設為 3。胡牌牌型必須達到此番數。'
                      : '• Min Fan: Default 3. Hand must meet this threshold to win.',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  language == 'Traditional Chinese'
                      ? '• 最大番數: 預設為 13。可設為「無上限」。'
                      : '• Max Fan: Default 13. Can be set to "No Limit".',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Scoring Table
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.5),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.fanPointsHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.byDiscardHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.bySelfDrawHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // Rows
              _buildScoreRow(
                AppLocalizations.chickenHand,
                '1',
                AppLocalizations.naMinOne,
              ),
              _buildScoreRow('1', '2', '3 (1×3)'),
              _buildScoreRow('2', '4', '6 (2×3)'),
              _buildScoreRow('3', '8', '12 (4×3)'),
              _buildScoreRow('4', '16', '24 (8×3)'),
              _buildScoreRow('5', '24', '36 (12×3)'),
              _buildScoreRow('6', '32', '48 (16×3)'),
              _buildScoreRow('7', '48', '72 (24×3)'),
              _buildScoreRow('8', '64', '96 (32×3)'),
              _buildScoreRow('9', '96', '144 (48×3)'),
              _buildScoreRow('10', '128', '192 (64×3)'),
              _buildScoreRow('11', '192', '288 (96×3)'),
              _buildScoreRow('12', '256', '384 (128×3)'),
              _buildScoreRow(AppLocalizations.limitHand, '384', '576 (192×3)'),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.flowerTilesScoringTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.noFlowersFan),
          Text(AppLocalizations.ownFlowerFan),
          const SizedBox(height: 8),
          Text(AppLocalizations.flowerMapping),
          Text(AppLocalizations.seat1Flower),
          Text(AppLocalizations.seat2Flower),
          Text(AppLocalizations.seat3Flower),
          Text(AppLocalizations.seat4Flower),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.orange.shade800 : Colors.orange.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.importantNoteTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.orange.shade200 : Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(AppLocalizations.flowerNote),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.honorTilesScoringTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.dragonPongFan),
          Text(AppLocalizations.roundWindPongFan),
          Text(AppLocalizations.seatWindPongFan),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.dragonNote,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.winningPatternsTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.winningPatternsDesc),
          const SizedBox(height: 8),

          // 1 Fan
          _buildFanHeader(AppLocalizations.fanCount('1 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleAllChows,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleNoFlowers,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleOwnSeason,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleSelfDraw,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleMenQianQing,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleDragonWindPong,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleRobbingKong,
            AppLocalizations.fanCount('1 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleHaidilao,
            AppLocalizations.fanCount('1 Fan'),
          ),

          // 2 Fan
          _buildFanHeader(AppLocalizations.fanCount('2 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleKongOnKong,
            AppLocalizations.fanCount('2 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleFlowerPlatform,
            AppLocalizations.fanCount('2 Fan'),
          ),

          // 3 Fan
          _buildFanHeader(AppLocalizations.fanCount('3 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleSevenFlowers,
            AppLocalizations.fanCount('3 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleAllPongs,
            AppLocalizations.fanCount('3 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleMixedOneSuit,
            AppLocalizations.fanCount('3 Fan'),
          ),

          // 4 Fan
          _buildFanHeader(AppLocalizations.fanCount('4 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleMixedTerminals,
            AppLocalizations.fanCount('4 Fan'),
          ),

          // 5 Fan
          _buildFanHeader(AppLocalizations.fanCount('5 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleSmallThreeDragons,
            AppLocalizations.fanCount('5 Fan'),
          ),

          // 6 Fan
          _buildFanHeader(AppLocalizations.fanCount('6 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleSmallFourWinds,
            AppLocalizations.fanCount('6 Fan'),
          ),

          // 7 Fan
          _buildFanHeader(AppLocalizations.fanCount('7 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.rulePureOneSuit,
            AppLocalizations.fanCount('7 Fan'),
          ),

          // 8 Fan
          _buildFanHeader(AppLocalizations.fanCount('8 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleBigThreeDragons,
            AppLocalizations.fanCount('8 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleEightImmortals,
            AppLocalizations.fanCount('8 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleHiddenTreasure,
            AppLocalizations.fanCount('8 Fan'),
          ),

          // 9 Fan
          _buildFanHeader(AppLocalizations.fanCount('9 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleDoubleKong,
            AppLocalizations.fanCount('9 Fan'),
          ),

          // 10 Fan
          _buildFanHeader(AppLocalizations.fanCount('10 Fan')),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleAllHonors,
            AppLocalizations.fanCount('10 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.rulePureTerminals,
            AppLocalizations.fanCount('10 Fan'),
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleNineGates,
            AppLocalizations.fanCount('10 Fan'),
          ),

          // 13 Fan
          _buildFanHeader('13 Fan'),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleThirteenOrphans,
            '13 Fan',
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleBlessingOfMan,
            '13 Fan',
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleEarthlyHand,
            '13 Fan',
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleHeavenlyHand,
            '13 Fan',
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleBigFourWinds,
            '13 Fan',
          ),
          _buildClickableRuleRow(
            context,
            AppLocalizations.ruleEighteenArhats,
            '13 Fan',
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.green.shade800 : Colors.green.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.tipTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(AppLocalizations.tipDesc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildScoreRow(String fan, String discard, String selfDraw) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(fan)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(discard)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(selfDraw)),
      ],
    );
  }

  Widget _buildFanHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildClickableRuleRow(BuildContext context, String name, String fan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onRuleTap != null) {
              onRuleTap!(name);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                  : Colors.white,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fan,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
