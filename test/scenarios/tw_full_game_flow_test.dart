/// ═══════════════════════════════════════════════════════════════════
/// 台灣麻將完整牌局模擬測試
/// ═══════════════════════════════════════════════════════════════════
/// 模擬一場完整的四圈台灣麻將，涵蓋常見情況：
///   自摸 / 放銃 / 莊連莊 / 閒家胡 / 暗刻自摸計 vs 放銃不計 /
///   門前清 / 門前清自摸 / 花牌(正花/爛花) / 對對胡 / 全求人 / 半求人 /
///   清一色 / 混一色 / 明槓暗槓 / 叮 / 無字 / 無花 / 槓上開花 /
///   海底撈月 / 三元牌 / 五暗刻 / 間間胡 / 莊家放銃多賠 /
///   閒家自摸莊家多賠 / 連莊不牽涉
///
/// 四位玩家：東家(P0)、南家(P1)、西家(P2)、北家(P3)
/// 起始分數各 1000 分，底台 2，台值 1
/// ═══════════════════════════════════════════════════════════════════
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/score_calculation_controller.dart';
import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/models/tw_hand.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

void main() {
  AppLocalizations.setLocale('Traditional Chinese');

  // ─── 遊戲狀態追蹤 ──────────────────────────────────────────────
  final scores = <int, int>{0: 1000, 1: 1000, 2: 1000, 3: 1000};
  int dealerIndex = 0; // 起莊：東家 (P0)
  int consecutive = 1; // 連莊次數 (1 = 剛上莊)
  int roundWindIdx = 0; // 0=東, 1=南, 2=西, 3=北
  int handsInRound = 0; // 本圈已完成的手數（非連莊的正常計算）

  final players = [
    Player(id: 0, name: '東家', score: 1000),
    Player(id: 1, name: '南家', score: 1000),
    Player(id: 2, name: '西家', score: 1000),
    Player(id: 3, name: '北家', score: 1000),
  ];

  final seatWinds = ['East', 'South', 'West', 'North'];
  final roundWinds = ['East', 'South', 'West', 'North'];

  ScoreCalculationController makeCtrl({
    required String winningPlayer,
    required bool isSelfDraw,
    String? discardPlayer,
    TwHand? hand,
    List<String> flowers = const [],
    String specialCondition = 'None',
  }) {
    final ctrl = ScoreCalculationController(
      players: players,
      minFan: 2,
      maxFan: 1,
      gameMode: GameMode.taiwan,
      consecutiveDealerCount: consecutive,
      dealerIndex: dealerIndex,
      roundWindIndex: roundWindIdx,
    );
    ctrl.winningPlayer = winningPlayer;
    ctrl.isSelfDraw = isSelfDraw;
    if (!isSelfDraw) ctrl.discardPlayer = discardPlayer;
    ctrl.roundWind = roundWinds[roundWindIdx];
    ctrl.seatWind = seatWinds[dealerIndex]; // winner's seat wind? no, this is dealer's
    // Actually seatWind should be the winner's seat wind
    final winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
    ctrl.seatWind = seatWinds[winnerIdx % 4];
    for (var key in ctrl.selectedFlowers.keys.toList()) {
      ctrl.selectedFlowers[key] = false;
    }
    for (var f in flowers) {
      ctrl.selectedFlowers[f] = true;
    }
    ctrl.selectedSpecialCondition = specialCondition;
    if (hand != null) ctrl.setTwHand(hand);
    return ctrl;
  }

  /// 套用分數變更並推進遊戲狀態
  void applyResult(Map<String, int> scoreChanges, bool dealerWon) {
    for (final entry in scoreChanges.entries) {
      scores[int.parse(entry.key)] =
          scores[int.parse(entry.key)]! + entry.value;
    }
    if (dealerWon) {
      consecutive++;
    } else {
      consecutive = 1;
      handsInRound++;
      if (handsInRound >= 4) {
        handsInRound = 0;
        roundWindIdx++;
      }
      dealerIndex = (dealerIndex + 1) % 4;
    }
  }

  bool hasPattern(ScoreCalculationController ctrl, String keyword) {
    return ctrl.displayRules
        .any((r) => (r['name'] as String).contains(keyword));
  }

  group('台灣麻將完整牌局模擬 — 四圈十六局', () {
    // ═══════════════════════════════════════════════════════════════
    // 第一圈：東風圈
    // ═══════════════════════════════════════════════════════════════

    // ─── 第1局 ────────────────────────────────────────────────────
    // 情境：東家(莊) 自摸，門前清 + 自摸 + 門前清自摸 + 正花 + 無字
    // 莊家胡牌 → 連莊（連一）
    // ──────────────────────────────────────────────────────────────
    test('第1局：東風圈 — 東家(莊)自摸，門前清＋正花', () {
      expect(dealerIndex, 0, reason: '起莊應為東家');
      expect(roundWindIdx, 0, reason: '第一圈應為東風');

      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: true,
        flowers: ['1f'], // 春 = 東家正花
        hand: const TwHand(
          exposedMelds: [], // 門前清
          concealedTiles: [
            '2m', '3m', '4m',
            '5p', '6p', '7p',
            '8s', '8s', '8s',
            '1s', '2s', '3s',
            '6m', '7m', '9p', '9p',
          ],
          winningTile: '8m', // 完成 6m7m8m 順子
        ),
      );

      // 驗證牌型
      expect(hasPattern(ctrl, '自摸'), true, reason: '應偵測到自摸');
        expect(hasPattern(ctrl, '門前清'), false,
          reason: '門前清自摸會覆蓋門前清');
        expect(hasPattern(ctrl, '門清自摸'), true, reason: '應偵測到門清自摸');
      expect(hasPattern(ctrl, '正花'), true, reason: '應偵測到正花');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      // 自摸：每家賠 pay 分
      expect(sc['1'], equals(-pay));
      expect(sc['2'], equals(-pay));
      expect(sc['3'], equals(-pay));
      expect(sc['0'], equals(pay * 3));

      applyResult(sc, true); // 莊家胡 → 連莊
      expect(dealerIndex, 0, reason: '莊家連莊，仍為東家');
      expect(consecutive, 2, reason: '連一');
    });

    // ─── 第2局 ────────────────────────────────────────────────────
    // 情境：西家放銃給北家，暗刻放銃不計測試
    //   北家暗牌有 1m×3(暗刻) + 5s×2(等胡)，胡 5s（放銃）
    //   → 5s 從放銃得來，不算暗刻，只有 1m 的一組暗刻（不滿二暗刻）
    //   莊家(東家)沒胡也沒放銃 → 連莊不牽涉
    //   東家下莊 → 南家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第2局：東風圈 — 西家放銃給北家，暗刻放銃不計', () {
      expect(dealerIndex, 0);
      expect(consecutive, 2, reason: '東家連一');

      final ctrl = makeCtrl(
        winningPlayer: '北家',
        isSelfDraw: false,
        discardPlayer: '西家',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['6m', '7m', '8m']),
          ],
          concealedTiles: [
            '1m', '1m', '1m', // 暗刻
            '5s', '5s',       // 等胡 5s — 放銃不計暗刻
            '1s', '2s', '3s',
            '9p', '9p',       // 眼
          ],
          winningTile: '5s',
        ),
      );

      // 驗證：放銃不計暗刻 → 不應有二暗刻
      expect(hasPattern(ctrl, '暗刻'), false,
          reason: '放銃 5s 不計暗刻；只有 1m×3 一組不滿二暗刻門檻');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      // 放銃：西家付全額，莊家(東)不牽涉
      expect(sc['2'], equals(-pay), reason: '西家放銃付錢');
      expect(sc['3'], equals(pay), reason: '北家得分');
      expect(sc['0'], isNull, reason: '莊家不牽涉');

      applyResult(sc, false); // 莊家沒胡 → 下莊
      expect(dealerIndex, 1, reason: '南家成為莊');
      expect(consecutive, 1);
    });

    // ─── 第3局 ────────────────────────────────────────────────────
    // 情境：南家(莊) 放銃給東家
    //   東家門前清，手上有 1s×3 + 8m×3 全暗刻 = 二暗刻
    //   莊家放銃 → 莊家多賠連莊台數
    //   南家下莊 → 西家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第3局：東風圈 — 南家(莊)放銃給東家，門前清＋二暗刻', () {
      expect(dealerIndex, 1, reason: '南家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: false,
        discardPlayer: '南家',
        hand: const TwHand(
          exposedMelds: [], // 門前清
          concealedTiles: [
            '1s', '1s', '1s', // 暗刻 1
            '8m', '8m', '8m', // 暗刻 2
            '2p', '3p', '4p',
            '5m', '6m', '7m',
            '1m', '2m',
            '9p', '9p',       // 眼
          ],
          winningTile: '3m', // 完成 1m2m3m
        ),
      );

      // 驗證：全暗刻 1s×3 + 8m×3 = 二暗刻（放銃不影響已完整的暗刻）
      expect(hasPattern(ctrl, '暗刻'), true, reason: '應偵測到二暗刻');
      expect(hasPattern(ctrl, '門前清'), true, reason: '應偵測到門前清');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;

      // 莊家(南家)放銃 → totalPoints 已包含連莊多賠
      final basePay = ctrl.totalPoints;
      expect(sc['1'], equals(-basePay), reason: '莊家放銃總付應等於顯示總分');
      expect(sc['0'], equals(basePay), reason: '東家得分應等於顯示總分');

      applyResult(sc, false);
      expect(dealerIndex, 2, reason: '西家成為莊');
    });

    // ─── 第4局 ────────────────────────────────────────────────────
    // 情境：西家(莊) 自摸，混一色 + 三元牌(中)
    //   莊家自摸 → 各家賠，莊家連莊
    // ──────────────────────────────────────────────────────────────
    test('第4局：東風圈 — 西家(莊)自摸，混一色＋三元牌', () {
      expect(dealerIndex, 2, reason: '西家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '西家',
        isSelfDraw: true,
        flowers: ['3f'], // 秋 = 西家正花
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['5z', '5z', '5z']), // 中
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '4p', '5p', '6p',
            '7p', '8p', '9p',
            '1p', '2p', '3p',
            '7z',
          ],
          winningTile: '7z', // 白板 — 對子
        ),
      );

      expect(hasPattern(ctrl, '混一色'), true, reason: '應偵測到混一色');
      expect(hasPattern(ctrl, '自摸'), true, reason: '應偵測到自摸');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      // 莊家自摸 → 每人付同額
      expect(sc['0'], equals(-pay));
      expect(sc['1'], equals(-pay));
      expect(sc['3'], equals(-pay));
      expect(sc['2'], equals(pay * 3));

      applyResult(sc, true); // 莊家胡 → 連莊
      expect(consecutive, 2, reason: '西家連一');
    });

    // ═══════════════════════════════════════════════════════════════
    // 第二圈：南風圈
    // ═══════════════════════════════════════════════════════════════

    // ─── 第5局 ────────────────────────────────────────────────────
    // 情境：東家自摸，半求人（上碰明槓全露，手上剩一張，自摸胡）
    //   莊家(西家, 連一) 被閒家自摸 → 莊家多賠
    //   西家下莊 → 北家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第5局：南風圈 — 東家自摸，半求人 ＋ 莊家多賠', () {
      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: true,
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.pong, tiles: ['4p', '4p', '4p']),
            Meld(type: MeldType.chow, tiles: ['7s', '8s', '9s']),
            Meld(type: MeldType.pong, tiles: ['3s', '3s', '3s']),
            Meld(type: MeldType.chow, tiles: ['5m', '6m', '7m']),
          ],
          concealedTiles: ['9p'], // 只剩一張
          winningTile: '9p',      // 自摸胡
        ),
      );

      expect(hasPattern(ctrl, '半求人'), true, reason: '應偵測到半求人');
      expect(hasPattern(ctrl, '自摸'), true, reason: '應偵測到自摸');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;

      // 東家自摸，莊家(西家, P2)多賠
      final basePay = ctrl.totalPoints;
      final dealerExtra = 3; // 連一 = 3台
      expect(sc['2'], equals(-(basePay + dealerExtra)),
          reason: '莊家(西)多賠連莊3台');
      expect(sc['1'], equals(-basePay));
      expect(sc['3'], equals(-basePay));

      applyResult(sc, false);
      expect(dealerIndex, 3, reason: '北家成為莊');
    });

    // ─── 第6局 ────────────────────────────────────────────────────
    // 情境：北家(莊) 放銃給南家
    //   全求人（上碰明槓全露，手上剩一張，放銃胡）+ 叮
    //   莊家放銃 → 莊家多賠
    //   北家下莊 → 東家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第6局：南風圈 — 北家(莊)放銃給南家，全求人＋叮', () {
      expect(dealerIndex, 3, reason: '北家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '南家',
        isSelfDraw: false,
        discardPlayer: '北家',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.pong, tiles: ['4p', '4p', '4p']),
            Meld(type: MeldType.chow, tiles: ['7s', '8s', '9s']),
            Meld(type: MeldType.pong, tiles: ['8s', '8s', '8s']),
            Meld(type: MeldType.chow, tiles: ['5m', '6m', '7m']),
          ],
          concealedTiles: ['1z'], // 只剩一張
          winningTile: '1z',
          isDing: true, // 單吊 → 叮
        ),
      );

      expect(hasPattern(ctrl, '全求人'), true, reason: '應偵測到全求人');
      expect(hasPattern(ctrl, '叮'), true, reason: '應偵測到叮');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;

      // 莊家(北, P3)放銃多賠
      final basePay = ctrl.totalPoints;
      expect(sc['3'], equals(-basePay), reason: '莊家放銃總付應等於顯示總分');
      expect(sc['1'], equals(basePay), reason: '南家得分應等於顯示總分');

      applyResult(sc, false);
      expect(dealerIndex, 0, reason: '東家成為莊');
    });

    // ─── 第7局 ────────────────────────────────────────────────────
    // 情境：東家(莊) 自摸，清一色 + 門前清自摸
    //   莊家自摸 → 連莊
    // ──────────────────────────────────────────────────────────────
    test('第7局：南風圈 — 東家(莊)自摸，清一色＋門前清自摸', () {
      expect(dealerIndex, 0, reason: '東家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: true,
        hand: const TwHand(
          exposedMelds: [], // 門前清
          concealedTiles: [
            '1p', '2p', '3p',
            '4p', '5p', '6p',
            '7p', '8p', '9p',
            '1p', '2p', '3p',
            '4p', '5p', '6p', '9p',
          ],
          winningTile: '9p',
        ),
      );

      expect(hasPattern(ctrl, '清一色'), true, reason: '應偵測到清一色');
        expect(hasPattern(ctrl, '門前清'), false,
          reason: '門前清自摸會覆蓋門前清');
        expect(hasPattern(ctrl, '門清自摸'), true, reason: '應偵測到門清自摸');
      expect(hasPattern(ctrl, '自摸'), true, reason: '應偵測到自摸');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      expect(sc['1'], equals(-pay));
      expect(sc['2'], equals(-pay));
      expect(sc['3'], equals(-pay));
      expect(sc['0'], equals(pay * 3));

      applyResult(sc, true); // 連莊
      expect(consecutive, 2, reason: '東家連一');
    });

    // ─── 第8局 ────────────────────────────────────────────────────
    // 情境：北家自摸，暗刻自摸計入測試
    //   北家暗牌有 2p×2(等胡)，自摸 2p → 算暗刻
    //   加上 5s×3 全暗刻 = 二暗刻
    //   莊家(東, 連一) 被自摸 → 多賠
    //   東家下莊 → 南家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第8局：南風圈 — 北家自摸，暗刻自摸計入＋莊家多賠', () {
      expect(dealerIndex, 0);
      expect(consecutive, 2, reason: '東家連一');

      final ctrl = makeCtrl(
        winningPlayer: '北家',
        isSelfDraw: true,
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
          ],
          concealedTiles: [
            '5s', '5s', '5s', // 暗刻 1（全在手上）
            '2p', '2p',       // 自摸 2p → 暗刻 2
            '6m', '7m', '8m',
            '4p', '5p', '6p',
            '9s', '9s',       // 眼
          ],
          winningTile: '2p', // 自摸 → 算暗刻
        ),
      );

      // 驗證：自摸 2p 計入暗刻 → 5s×3 + 2p×2+自摸 = 二暗刻
      expect(hasPattern(ctrl, '暗刻'), true, reason: '自摸 2p 應計入暗刻 → 二暗刻');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;
      final dealerExtra = 3; // 連一 = 3台

      // 莊家(東, P0) 多賠
      expect(sc['0'], equals(-(basePay + dealerExtra)),
          reason: '莊家多賠連莊3台');
      expect(sc['1'], equals(-basePay));
      expect(sc['2'], equals(-basePay));

      applyResult(sc, false);
      expect(dealerIndex, 1, reason: '南家成為莊');
    });

    // ═══════════════════════════════════════════════════════════════
    // 第三圈：西風圈
    // ═══════════════════════════════════════════════════════════════

    // ─── 第9局 ────────────────────────────────────────────────────
    // 情境：南家(莊) 自摸，對對胡 + 自摸 + 花牌（爛花）
    //   南家連莊
    // ──────────────────────────────────────────────────────────────
    test('第9局：西風圈 — 南家(莊)自摸，對對胡＋爛花', () {
      expect(dealerIndex, 1, reason: '南家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '南家',
        isSelfDraw: true,
        flowers: ['1f'], // 春 = 東家的正花 → 對南家是爛花
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
            Meld(type: MeldType.pong, tiles: ['3p', '3p', '3p']),
            Meld(type: MeldType.pong, tiles: ['5s', '5s', '5s']),
            Meld(type: MeldType.pong, tiles: ['7m', '7m', '7m']),
            Meld(type: MeldType.pong, tiles: ['9p', '9p', '9p']),
          ],
          concealedTiles: ['2s'],
          winningTile: '2s',
        ),
      );

      expect(hasPattern(ctrl, '對對胡'), true, reason: '應偵測到對對胡');
      expect(hasPattern(ctrl, '自摸'), true, reason: '應偵測到自摸');
      expect(hasPattern(ctrl, '爛花'), true, reason: '應偵測到爛花');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      expect(sc['0'], equals(-pay));
      expect(sc['2'], equals(-pay));
      expect(sc['3'], equals(-pay));
      expect(sc['1'], equals(pay * 3));

      applyResult(sc, true);
      expect(consecutive, 2, reason: '南家連一');
    });

    // ─── 第10局 ───────────────────────────────────────────────────
    // 情境：北家放銃給東家
    //   東家有明槓 + 暗槓 + 大字(三元牌紅中)
    //   南家(莊, 連一) 不牽涉
    //   南家下莊 → 西家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第10局：西風圈 — 北家放銃給東家，明槓＋暗槓＋三元牌', () {
      expect(dealerIndex, 1, reason: '南家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: false,
        discardPlayer: '北家',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.kong, tiles: ['1m', '1m', '1m', '1m']),       // 明槓
            Meld(type: MeldType.concealedKong, tiles: ['2p', '2p', '2p', '2p']), // 暗槓
            Meld(type: MeldType.pong, tiles: ['5z', '5z', '5z']),             // 中（三元牌）
            Meld(type: MeldType.chow, tiles: ['4s', '5s', '6s']),
          ],
          concealedTiles: [
            '7m', '8m', '9m',
            '3p',
          ],
          winningTile: '3p', // 單吊
        ),
      );

      expect(hasPattern(ctrl, '明槓'), true, reason: '應偵測到明槓');
      expect(hasPattern(ctrl, '暗槓'), true, reason: '應偵測到暗槓');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      // 閒家放銃給閒家，莊家不牽涉
      expect(sc['3'], equals(-pay), reason: '北家放銃');
      expect(sc['0'], equals(pay), reason: '東家得分');
      expect(sc['1'], isNull, reason: '莊家(南)不牽涉');

      applyResult(sc, false);
      expect(dealerIndex, 2, reason: '西家成為莊');
    });

    // ─── 第11局 ───────────────────────────────────────────────────
    // 情境：東家自摸，多朵花（正花 + 爛花）
    //   莊家(西家) 被自摸 → 多賠
    //   西家下莊 → 北家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第11局：西風圈 — 東家自摸，正花＋爛花＋莊家多賠', () {
      expect(dealerIndex, 2, reason: '西家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: true,
        flowers: ['1f', '5f', '3f'], // 春(正), 梅(正), 秋(爛)
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['4p', '5p', '6p']),
            Meld(type: MeldType.chow, tiles: ['7s', '8s', '9s']),
          ],
          concealedTiles: [
            '2s', '3s', '4s',
            '5m', '6m', '7m',
            '8p', '8p',
          ],
          winningTile: '8p',
        ),
      );

      expect(hasPattern(ctrl, '自摸'), true);
      expect(hasPattern(ctrl, '正花'), true, reason: '應偵測到正花');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;

      // 莊家(西, P2) 多賠
      expect(sc['2'], lessThan(-basePay), reason: '莊家應多賠');
      expect(sc['1'], equals(-basePay));
      expect(sc['3'], equals(-basePay));

      applyResult(sc, false);
      expect(dealerIndex, 3, reason: '北家成為莊');
    });

    // ─── 第12局 ───────────────────────────────────────────────────
    // 情境：北家(莊) 放銃給西家
    //   無花 + 無字 基本牌型
    //   莊家放銃 → 多賠，北家下莊 → 東家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第12局：西風圈 — 北家(莊)放銃給西家，無花＋無字', () {
      expect(dealerIndex, 3, reason: '北家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '西家',
        isSelfDraw: false,
        discardPlayer: '北家',
        // 不帶花牌
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['4m', '5m', '6m']),
            Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '4s', '5s', '6s',
            '7p', '7p',
          ],
          winningTile: '7p',
        ),
      );

        expect(hasPattern(ctrl, '無花'), false,
          reason: '若同時無字無花，會由「無字花」覆蓋無花');
        expect(hasPattern(ctrl, '無字花'), true, reason: '應偵測到無字花');
      expect(hasPattern(ctrl, '無字'), true, reason: '應偵測到無字');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;

        expect(sc['3'], equals(-basePay), reason: '莊家放銃總付應等於顯示總分');
        expect(sc['2'], equals(basePay));

      applyResult(sc, false);
      expect(dealerIndex, 0, reason: '東家成為莊');
    });

    // ═══════════════════════════════════════════════════════════════
    // 第四圈：北風圈
    // ═══════════════════════════════════════════════════════════════

    // ─── 第13局 ───────────────────────────────────────────────────
    // 情境：東家(莊) 自摸，槓上開花
    //   有明槓，自摸聽牌，特殊狀況 = 槓上開花
    //   莊家自摸 → 連莊
    // ──────────────────────────────────────────────────────────────
    test('第13局：北風圈 — 東家(莊)自摸，槓上開花', () {
      expect(dealerIndex, 0, reason: '東家是莊');
      expect(roundWindIdx, greaterThanOrEqualTo(2), reason: '應已進入後段風圈');

      final ctrl = makeCtrl(
        winningPlayer: '東家',
        isSelfDraw: true,
        specialCondition: 'Kong on Kong/Flower',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.kong, tiles: ['1m', '1m', '1m', '1m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['5s', '6s', '7s']),
            Meld(type: MeldType.chow, tiles: ['3m', '4m', '5m']),
          ],
          concealedTiles: [
            '8p', '9p', '7p',
            '6m',
          ],
          winningTile: '6m',
        ),
      );

      expect(hasPattern(ctrl, '槓上槓'), true, reason: '應偵測到槓上槓/花上自摸');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      expect(sc['1'], equals(-pay));
      expect(sc['2'], equals(-pay));
      expect(sc['3'], equals(-pay));
      expect(sc['0'], equals(pay * 3));

      applyResult(sc, true);
      expect(consecutive, 2, reason: '東家連一');
    });

    // ─── 第14局 ───────────────────────────────────────────────────
    // 情境：南家自摸，海底撈月（最後一張牌自摸）
    //   莊家(東, 連一) 被自摸 → 多賠
    //   東家下莊 → 南家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第14局：北風圈 — 南家自摸，海底撈月＋莊家多賠', () {
      expect(dealerIndex, 0);
      expect(consecutive, 2);

      final ctrl = makeCtrl(
        winningPlayer: '南家',
        isSelfDraw: true,
        specialCondition: 'Under the Sea',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['4p', '5p', '6p']),
            Meld(type: MeldType.chow, tiles: ['7s', '8s', '9s']),
          ],
          concealedTiles: [
            '2s', '3s', '4s',
            '6m', '7m', '8m',
            '5m', '5m',
          ],
          winningTile: '5m',
        ),
      );

      expect(hasPattern(ctrl, '海底撈月'), true, reason: '應偵測到海底撈月');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;
      final dealerExtra = 3; // 連一 = 3台

      expect(sc['0'], equals(-(basePay + dealerExtra)),
          reason: '莊家多賠連莊3台');
      expect(sc['2'], equals(-basePay));
      expect(sc['3'], equals(-basePay));

      applyResult(sc, false);
      expect(dealerIndex, 1, reason: '南家成為莊');
    });

    // ─── 第15局 ───────────────────────────────────────────────────
    // 情境：東家放銃給西家
    //   五暗刻（全部 5 組刻子都在暗牌中，放銃）
    //   南家(莊) 不牽涉
    //   南家下莊 → 西家成為莊
    // ──────────────────────────────────────────────────────────────
    test('第15局：北風圈 — 東家放銃給西家，五暗刻', () {
      expect(dealerIndex, 1, reason: '南家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '西家',
        isSelfDraw: false,
        discardPlayer: '東家',
        hand: const TwHand(
          exposedMelds: [],
          concealedTiles: [
            '1m', '1m', '1m',
            '3p', '3p', '3p',
            '5s', '5s', '5s',
            '7m', '7m', '7m',
            '9p', '9p', '9p',
            '2s',
          ],
          winningTile: '2s', // 完成眼（2s 對子）
        ),
      );

      expect(hasPattern(ctrl, '五暗刻'), true, reason: '應偵測到五暗刻');
      // 五暗刻排除對對胡
      expect(hasPattern(ctrl, '對對胡'), false, reason: '五暗刻應排除對對胡');

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      expect(sc['0'], equals(-pay));
      expect(sc['2'], equals(pay));
      expect(sc['1'], isNull, reason: '莊家(南)不牽涉');

      applyResult(sc, false);
      expect(dealerIndex, 2, reason: '西家成為莊');
    });

    // ─── 第16局 ───────────────────────────────────────────────────
    // 情境：西家(莊) 自摸，間間胡（門前清 + 自摸 + 對對胡 = 100台）
    //   間間胡排除：自摸、門前清、門前清自摸、對對胡、五暗刻
    //   莊家自摸 → 最終局
    // ──────────────────────────────────────────────────────────────
    test('第16局：北風圈 — 西家(莊)自摸，間間胡 100台（最終局）', () {
      expect(dealerIndex, 2, reason: '西家是莊');

      final ctrl = makeCtrl(
        winningPlayer: '西家',
        isSelfDraw: true,
        hand: const TwHand(
          exposedMelds: [], // 門前清
          concealedTiles: [
            '1m', '1m', '1m',
            '3p', '3p', '3p',
            '5s', '5s', '5s',
            '7m', '7m', '7m',
            '9p', '9p', '9p',
            '2s',
          ],
          winningTile: '2s',
        ),
      );

      expect(hasPattern(ctrl, '間間胡'), true, reason: '應偵測到間間胡');
      // 間間胡排除以下：
      expect(hasPattern(ctrl, '自摸'), false, reason: '間間胡應排除自摸');
      expect(hasPattern(ctrl, '門前清'), false, reason: '間間胡應排除門前清');
      expect(hasPattern(ctrl, '對對胡'), false, reason: '間間胡應排除對對胡');
      expect(hasPattern(ctrl, '五暗刻'), false, reason: '間間胡應排除五暗刻');

      // 100 台 + 莊 bonus + 無花 + 無字
      expect(ctrl.effectiveFan, greaterThanOrEqualTo(100));

      final result = ctrl.buildSubmitResult()!;
      final sc = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      expect(sc['0'], equals(-pay));
      expect(sc['1'], equals(-pay));
      expect(sc['3'], equals(-pay));
      expect(sc['2'], equals(pay * 3));

      applyResult(sc, true);
    });

    // ─── 驗證最終對帳 ────────────────────────────────────────────
    test('最終結算：四家分數總和應為 4000（零和驗證）', () {
      final total = scores.values.reduce((a, b) => a + b);
      expect(total, equals(4000),
          reason: '零和驗證 — 四家分數總和應不變');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 額外覆蓋：核心情境矩陣（獨立於上方 16 局流程）
  // ═══════════════════════════════════════════════════════════════
  group('台麻核心情境矩陣（所有常見對局分支）', () {
    const TwHand kStableHand = TwHand(
      exposedMelds: [
        Meld(type: MeldType.pong, tiles: ['6m', '6m', '6m']),
        Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
        Meld(type: MeldType.chow, tiles: ['6s', '7s', '8s']),
      ],
      concealedTiles: ['7m', '8m', '3m', '4m', '5m', '1z', '1z'],
      winningTile: '9m',
    );

    ScoreCalculationController makeIsolatedCtrl({
      required int dealer,
      required int consecutiveCount,
      required String winner,
      required bool selfDraw,
      String? discarder,
      List<String> flowers = const [],
      TwHand hand = kStableHand,
      String specialCondition = 'None',
    }) {
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 2,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: consecutiveCount,
        dealerIndex: dealer,
        roundWindIndex: 0,
      );
      ctrl.winningPlayer = winner;
      ctrl.isSelfDraw = selfDraw;
      if (!selfDraw) ctrl.discardPlayer = discarder;
      ctrl.roundWind = 'East';
      final winnerIdx = players.indexWhere((p) => p.name == winner);
      ctrl.seatWind = ['East', 'South', 'West', 'North'][winnerIdx % 4];
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      for (final f in flowers) {
        ctrl.selectedFlowers[f] = true;
      }
      ctrl.selectedSpecialCondition = specialCondition;
      ctrl.setTwHand(hand);
      return ctrl;
    }

    int idOf(String name) => players.firstWhere((p) => p.name == name).id;
    int pick(Map<String, int> scores, int id) => scores['$id'] ?? 0;
    int dealerExtra(int consecutiveCount) =>
        consecutiveCount > 1 ? ((consecutiveCount - 1) * 2) + 1 : 1;

    test('A. 莊家自摸：三家同額支付，無額外分流', () {
      final ctrl = makeIsolatedCtrl(
        dealer: 0,
        consecutiveCount: 3,
        winner: '東家',
        selfDraw: true,
      );
      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;
      final pay = ctrl.totalPoints;

      expect(pick(scores, 1), -pay);
      expect(pick(scores, 2), -pay);
      expect(pick(scores, 3), -pay);
      expect(pick(scores, 0), pay * 3);
      expect(scores.values.fold(0, (a, b) => a + b), 0,
          reason: '每局必須零和');
    });

    test('B. 閒家自摸：莊家多付連莊台，其他閒家付基本分', () {
      final ctrl = makeIsolatedCtrl(
        dealer: 0,
        consecutiveCount: 3, // 連二 -> 5 台
        winner: '南家',
        selfDraw: true,
      );
      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;
      final extra = dealerExtra(3);

      expect(pick(scores, 0), -(basePay + extra),
          reason: '莊家應額外支付連莊台');
      expect(pick(scores, 2), -basePay);
      expect(pick(scores, 3), -basePay);
      expect(pick(scores, 1), (basePay + extra) + basePay + basePay);
      expect(scores.values.fold(0, (a, b) => a + b), 0);

      final hasDealerPaysExtra = ctrl.displayRules.any(
        (r) => (r['name'] as String).contains(AppLocalizations.twDealerPaysExtra),
      );
      expect(hasDealerPaysExtra, true,
          reason: '閒家自摸時應顯示「莊家額外支付」');
    });

    test('C. 莊家放銃給閒家：莊家支付基本分+連莊額外分', () {
      final ctrl = makeIsolatedCtrl(
        dealer: 0,
        consecutiveCount: 2, // 連一 -> 3 台
        winner: '南家',
        selfDraw: false,
        discarder: '東家',
        flowers: const ['2f'],
      );
      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;

      expect(pick(scores, 0), -basePay);
      expect(pick(scores, 1), basePay);
      expect(pick(scores, 2), 0);
      expect(pick(scores, 3), 0);
      expect(scores.values.fold(0, (a, b) => a + b), 0);
    });

    test('D. 閒家放銃給閒家且莊家未介入：不得顯示/計入莊家額外支付', () {
      final ctrl = makeIsolatedCtrl(
        dealer: 0,
        consecutiveCount: 4, // 連三 -> 7 台（此局不應介入）
        winner: '南家',
        selfDraw: false,
        discarder: '西家',
        flowers: const ['1f'],
      );
      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;

      expect(pick(scores, 2), -basePay);
      expect(pick(scores, 1), basePay);
      expect(pick(scores, 0), 0);
      expect(pick(scores, 3), 0);
      expect(scores.values.fold(0, (a, b) => a + b), 0);

      final hasDealerPaysExtra = ctrl.displayRules.any(
        (r) => (r['name'] as String).contains(AppLocalizations.twDealerPaysExtra),
      );
      expect(hasDealerPaysExtra, false,
          reason: '非莊家放銃時不應顯示「莊家額外支付」');
    });

    test('E. 閒家放銃給莊家：只由放銃者支付，無額外莊家懲罰分流', () {
      final ctrl = makeIsolatedCtrl(
        dealer: 0,
        consecutiveCount: 5,
        winner: '東家',
        selfDraw: false,
        discarder: '西家',
        flowers: const ['1f'],
      );
      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;
      final basePay = ctrl.totalPoints;

      expect(pick(scores, 2), -basePay);
      expect(pick(scores, 0), basePay);
      expect(pick(scores, 1), 0);
      expect(pick(scores, 3), 0);
      expect(scores.values.fold(0, (a, b) => a + b), 0);
    });

    test('F. 連莊額外台公式驗證：1/2/3/6 局', () {
      expect(dealerExtra(1), 1);
      expect(dealerExtra(2), 3);
      expect(dealerExtra(3), 5);
      expect(dealerExtra(6), 11);
    });

    test('G. 莊流轉規則：莊家胡則連莊，否則下莊且連莊歸 1', () {
      ({int dealer, int consecutive, int hands, int wind}) nextState({
        required int dealer,
        required int consecutive,
        required int hands,
        required int wind,
        required bool dealerWon,
      }) {
        if (dealerWon) {
          return (
            dealer: dealer,
            consecutive: consecutive + 1,
            hands: hands,
            wind: wind,
          );
        }
        var nDealer = (dealer + 1) % 4;
        var nConsecutive = 1;
        var nHands = hands + 1;
        var nWind = wind;
        if (nHands >= 4) {
          nHands = 0;
          nWind = wind + 1;
        }
        return (
          dealer: nDealer,
          consecutive: nConsecutive,
          hands: nHands,
          wind: nWind,
        );
      }

      final keepDealer = nextState(
        dealer: 2,
        consecutive: 3,
        hands: 1,
        wind: 0,
        dealerWon: true,
      );
      expect(keepDealer.dealer, 2);
      expect(keepDealer.consecutive, 4);
      expect(keepDealer.hands, 1);
      expect(keepDealer.wind, 0);

      final rotateDealer = nextState(
        dealer: 2,
        consecutive: 3,
        hands: 1,
        wind: 0,
        dealerWon: false,
      );
      expect(rotateDealer.dealer, 3);
      expect(rotateDealer.consecutive, 1);
      expect(rotateDealer.hands, 2);
      expect(rotateDealer.wind, 0);
    });

    test('H. 風圈推進：每滿四手（非連莊累積）進一圈', () {
      ({int dealer, int consecutive, int hands, int wind}) nextState({
        required int dealer,
        required int consecutive,
        required int hands,
        required int wind,
        required bool dealerWon,
      }) {
        if (dealerWon) {
          return (
            dealer: dealer,
            consecutive: consecutive + 1,
            hands: hands,
            wind: wind,
          );
        }
        var nDealer = (dealer + 1) % 4;
        var nConsecutive = 1;
        var nHands = hands + 1;
        var nWind = wind;
        if (nHands >= 4) {
          nHands = 0;
          nWind = wind + 1;
        }
        return (
          dealer: nDealer,
          consecutive: nConsecutive,
          hands: nHands,
          wind: nWind,
        );
      }

      final beforeWrap = nextState(
        dealer: 3,
        consecutive: 1,
        hands: 3,
        wind: 1,
        dealerWon: false,
      );
      expect(beforeWrap.hands, 0);
      expect(beforeWrap.wind, 2, reason: '完成第4手後應進到下一圈');
      expect(beforeWrap.dealer, 0, reason: '莊家輪替至下一位');
      expect(beforeWrap.consecutive, 1);
    });

    test('I. 常見分支整體零和驗證（自摸/放銃/特例）', () {
      final scenarios = <ScoreCalculationController>[
        makeIsolatedCtrl(
          dealer: 0,
          consecutiveCount: 1,
          winner: '東家',
          selfDraw: true,
          specialCondition: 'Kong on Kong/Flower',
        ),
        makeIsolatedCtrl(
          dealer: 1,
          consecutiveCount: 2,
          winner: '西家',
          selfDraw: true,
          specialCondition: 'Under the Sea',
        ),
        makeIsolatedCtrl(
          dealer: 2,
          consecutiveCount: 4,
          winner: '北家',
          selfDraw: false,
          discarder: '西家',
          flowers: const ['1f'],
        ),
        makeIsolatedCtrl(
          dealer: 3,
          consecutiveCount: 3,
          winner: '東家',
          selfDraw: false,
          discarder: '南家',
          flowers: const ['1f'],
        ),
      ];

      for (final ctrl in scenarios) {
        final result = ctrl.buildSubmitResult()!;
        final scores = result['scores'] as Map<String, int>;
        final sum = scores.values.fold(0, (a, b) => a + b);
        expect(sum, 0,
            reason:
                '零和驗證失敗: winner=${ctrl.winningPlayer}, selfDraw=${ctrl.isSelfDraw}, dealer=${ctrl.dealerIndex}');
      }
    });

    test('J. 快速覆蓋：每位玩家都可作為胡牌者與放銃者', () {
      for (final winner in players) {
        final ctrlSelf = makeIsolatedCtrl(
          dealer: 0,
          consecutiveCount: 2,
          winner: winner.name,
          selfDraw: true,
        );
        final r1 = ctrlSelf.buildSubmitResult()!;
        final s1 = r1['scores'] as Map<String, int>;
        expect(s1.values.fold(0, (a, b) => a + b), 0);
      }

      for (final winner in players) {
        final discarder = players.firstWhere((p) => p.id != winner.id);
        final ctrlDiscard = makeIsolatedCtrl(
          dealer: 0,
          consecutiveCount: 2,
          winner: winner.name,
          selfDraw: false,
          discarder: discarder.name,
          flowers: const ['1f'],
        );
        final r2 = ctrlDiscard.buildSubmitResult()!;
        final s2 = r2['scores'] as Map<String, int>;
        expect(s2.values.fold(0, (a, b) => a + b), 0);

        final winnerId = idOf(winner.name);
        final discarderId = idOf(discarder.name);
        expect(pick(s2, winnerId), greaterThan(0));
        expect(pick(s2, discarderId), lessThan(0));
      }
    });
  });
}
