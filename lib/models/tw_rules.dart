import '../logic/hand_patterns.dart';
import '../localization/app_localizations.dart';
import 'rule.dart';

// Taiwan Mahjong Rules (台灣麻將規則)
// Comprehensive TW 16-Tai scoring rules
// Organized per standard Taiwan mahjong rules into 5 categories
List<Rule> get twRules => [
  // ═══════════════════════════════════════════════════════════
  // 1️⃣  花牌與字牌相關 (Flowers & Honors)
  // ═══════════════════════════════════════════════════════════
  // 無花 – No Flowers (1 Tai)
  Rule(
    name: AppLocalizations.ruleNoFlowers,
    description: AppLocalizations.descNoFlowers,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.explNoFlowers,
    validator: null,
    exampleTiles: [],
  ),
  // 正花 – Proper Flower (2 Tai each)
  Rule(
    name: AppLocalizations.twProperFlower,
    description: AppLocalizations.descProperFlower,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.explProperFlower,
    validator: null,
    exampleTiles: [],
  ),
  // 爛花 – Wrong Flower (1 Tai each)
  Rule(
    name: AppLocalizations.twWrongFlower,
    description: AppLocalizations.descWrongFlower,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.explWrongFlower,
    validator: null,
    exampleTiles: [],
  ),
  // 正風牌 – Proper Wind Pong (2 Tai)
  Rule(
    name: AppLocalizations.twProperWind,
    description: AppLocalizations.descProperWind,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.explProperWind,
    validator: null,
    exampleTiles: [],
  ),
  // 非正風 – Ordinary Wind Pong (1 Tai)
  Rule(
    name: AppLocalizations.twOrdinaryWind,
    description: AppLocalizations.descOrdinaryWind,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.explOrdinaryWind,
    validator: null,
    exampleTiles: [],
  ),
  // 中發白刻 – Dragon Pong (2 Tai each)
  Rule(
    name: AppLocalizations.twDragonPong,
    description: AppLocalizations.descTwDragonPong,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.explTwDragonPong,
    validator: null,
    exampleTiles: [
      ['5z', '5z', '5z'],
    ],
  ),
  // 無字 – No Honors (1 Tai)
  Rule(
    name: AppLocalizations.twNoHonors,
    description: AppLocalizations.twDescNoHonors,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplNoHonors,
    validator: null,
    exampleTiles: [],
  ),
  // 無字花 – No Honors No Flowers (5 Tai)
  Rule(
    name: AppLocalizations.twNoHonorsNoFlowers,
    description: AppLocalizations.twDescNoHonorsNoFlowers,
    fan: AppLocalizations.taiCount(5),
    fanValue: 5,
    explanation: AppLocalizations.twExplNoHonorsNoFlowers,
    validator: null,
    exampleTiles: [],
  ),
  // 大平胡 – Grand Ping Hu (15 Tai)
  Rule(
    name: AppLocalizations.twNoHonorsNoFlowersPingHu,
    description: AppLocalizations.twDescNoHonorsNoFlowersPingHu,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplNoHonorsNoFlowersPingHu,
    validator: null,
    exampleTiles: [],
  ),

  // ═══════════════════════════════════════════════════════════
  // 2️⃣  基礎牌型與胡牌方式 (Basic Patterns & Win Methods)
  // ═══════════════════════════════════════════════════════════
  // 聽牌 – Declared Ready (5 Tai)
  Rule(
    name: AppLocalizations.twDeclaredReady,
    description: AppLocalizations.descDeclaredReady,
    fan: AppLocalizations.taiCount(5),
    fanValue: 5,
    explanation: AppLocalizations.explDeclaredReady,
    validator: null,
    exampleTiles: [],
  ),
  // 雞胡 – Chicken Hand (10 Tai)
  Rule(
    name: AppLocalizations.twChickenHand,
    description: AppLocalizations.twDescChickenHand,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplChickenHand,
    validator: null,
    exampleTiles: [],
  ),
  // 對碰 – Double Pong Wait (1 Tai)
  Rule(
    name: AppLocalizations.twDoublePong,
    description: AppLocalizations.twDescDoublePong,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplDoublePong,
    validator: null,
    exampleTiles: [],
  ),
  // 假獨 – Fake Single Wait (1 Tai)
  Rule(
    name: AppLocalizations.twFakeSingle,
    description: AppLocalizations.twDescFakeSingle,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplFakeSingle,
    validator: null,
    exampleTiles: [],
  ),
  // 獨獨 – True Single Wait (2 Tai)
  Rule(
    name: AppLocalizations.twTrueSingle,
    description: AppLocalizations.twDescTrueSingle,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.twExplTrueSingle,
    validator: null,
    exampleTiles: [],
  ),
  // 平胡 – All Chows / Ping Hu (3 Tai)
  Rule(
    name: AppLocalizations.ruleAllChows,
    description: AppLocalizations.descAllChows,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.explAllChows,
    validator: HandPatterns.isPingHu,
    exampleTiles: [],
  ),
  // 將眼 – Eye of 2/5/8 (1 Tai)
  Rule(
    name: AppLocalizations.twEyeOf258,
    description: AppLocalizations.descEyeOf258,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.explEyeOf258,
    validator: HandPatterns.hasEyeOf258,
    exampleTiles: [],
  ),
  // 老少 – Old & Young (2 Tai)
  Rule(
    name: AppLocalizations.twOldYoung,
    description: AppLocalizations.twDescOldYoung,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.twExplOldYoung,
    validator: null,
    exampleTiles: [],
  ),
  // 門清 – Concealed Hand (3 Tai)
  Rule(
    name: AppLocalizations.ruleMenQianQing,
    description: AppLocalizations.descMenQianQing,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.explMenQianQing,
    validator: null,
    exampleTiles: [],
  ),
  // 自摸 – Self-Draw (1 Tai)
  Rule(
    name: AppLocalizations.ruleSelfDraw,
    description: AppLocalizations.descSelfDraw,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.explSelfDraw,
    validator: null,
    exampleTiles: [],
  ),
  // 門清自摸 – Concealed Self-Draw (5 Tai)
  Rule(
    name: AppLocalizations.twConcealedSelfDraw,
    description: AppLocalizations.descConcealedSelfDraw,
    fan: AppLocalizations.taiCount(5),
    fanValue: 5,
    explanation: AppLocalizations.explConcealedSelfDraw,
    validator: null,
    exampleTiles: [],
  ),
  // 海底撈月 – Under the Sea / Last Tile Win (20 Tai)
  Rule(
    name: AppLocalizations.twUnderTheSea,
    description: AppLocalizations.descUnderTheSea,
    fan: AppLocalizations.taiCount(20),
    fanValue: 20,
    explanation: AppLocalizations.explUnderTheSea,
    validator: null,
    exampleTiles: [],
  ),
  // 明槓 – Exposed Kong (1 Tai)
  Rule(
    name: AppLocalizations.twExposedKong,
    description: AppLocalizations.twDescExposedKong,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplExposedKong,
    validator: null,
    exampleTiles: [],
  ),
  // 暗槓 – Concealed Kong (2 Tai)
  Rule(
    name: AppLocalizations.twConcealedKongTai,
    description: AppLocalizations.twDescConcealedKongTai,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.twExplConcealedKongTai,
    validator: null,
    exampleTiles: [],
  ),
  // 花上食胡 – Win on Flower Replacement (1 Tai)
  Rule(
    name: AppLocalizations.twFlowerWin,
    description: AppLocalizations.twDescFlowerWin,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplFlowerWin,
    validator: null,
    exampleTiles: [],
  ),
  // 槓上食胡 – Win on Kong Replacement (1 Tai)
  Rule(
    name: AppLocalizations.twKongWin,
    description: AppLocalizations.twDescKongWin,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplKongWin,
    validator: null,
    exampleTiles: [],
  ),
  // 搶槓食胡 – Robbing the Kong (1 Tai)
  Rule(
    name: AppLocalizations.twRobbingKong,
    description: AppLocalizations.twDescRobbingKong,
    fan: AppLocalizations.taiCount(1),
    fanValue: 1,
    explanation: AppLocalizations.twExplRobbingKong,
    validator: null,
    exampleTiles: [],
  ),
  // 槓上槓食胡 – Double Kong Win (30 Tai)
  Rule(
    name: AppLocalizations.twDoubleKongWin,
    description: AppLocalizations.twDescDoubleKongWin,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplDoubleKongWin,
    validator: null,
    exampleTiles: [],
  ),
  // 搶槓上槓食胡 – Robbing Double Kong (30 Tai)
  Rule(
    name: AppLocalizations.twRobbingDoubleKong,
    description: AppLocalizations.twDescRobbingDoubleKong,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplRobbingDoubleKong,
    validator: null,
    exampleTiles: [],
  ),

  // ═══════════════════════════════════════════════════════════
  // 3️⃣  刻子與順子組合 (Pong & Sequence Combos)
  // ═══════════════════════════════════════════════════════════
  // 二暗刻 – Two Concealed Pongs (3 Tai)
  Rule(
    name: AppLocalizations.twTwoConcealedPongs,
    description: AppLocalizations.twDescTwoConcealedPongs,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.twExplTwoConcealedPongs,
    validator: null,
    exampleTiles: [],
  ),
  // 三暗刻 – Three Concealed Pongs (10 Tai)
  Rule(
    name: AppLocalizations.twThreeConcealedPongs,
    description: AppLocalizations.twDescThreeConcealedPongs,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplThreeConcealedPongs,
    validator: null,
    exampleTiles: [],
  ),
  // 四暗刻 – Four Concealed Pongs (30 Tai)
  Rule(
    name: AppLocalizations.twFourConcealedPongs,
    description: AppLocalizations.twDescFourConcealedPongs,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplFourConcealedPongs,
    validator: null,
    exampleTiles: [],
  ),
  // 五暗刻 – Five Concealed Pongs (80 Tai)
  Rule(
    name: AppLocalizations.twFiveConcealedPongs,
    description: AppLocalizations.descFiveConcealedPongs,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.explFiveConcealedPongs,
    validator: HandPatterns.isAllPongs,
    exampleTiles: [],
  ),
  // 一般高 – Two Identical Sequences (3 Tai)
  Rule(
    name: AppLocalizations.twIdenticalSequenceTwo,
    description: AppLocalizations.twDescIdenticalSequenceTwo,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.twExplIdenticalSequenceTwo,
    validator: null,
    exampleTiles: [],
  ),
  // 三般高 – Three Identical Sequences (Exposed 15 / Concealed 20 Tai)
  Rule(
    name: AppLocalizations.twIdenticalSequenceThree,
    description: AppLocalizations.twDescIdenticalSequenceThree,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplIdenticalSequenceThree,
    validator: null,
    exampleTiles: [],
  ),
  // 四般高 – Four Identical Sequences (30 Tai)
  Rule(
    name: AppLocalizations.twIdenticalSequenceFour,
    description: AppLocalizations.twDescIdenticalSequenceFour,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplIdenticalSequenceFour,
    validator: null,
    exampleTiles: [],
  ),
  // 二相逢 – Mixed Double Sequence (2 Tai)
  Rule(
    name: AppLocalizations.twMixedDoubleSeq,
    description: AppLocalizations.twDescMixedDoubleSeq,
    fan: AppLocalizations.taiCount(2),
    fanValue: 2,
    explanation: AppLocalizations.twExplMixedDoubleSeq,
    validator: null,
    exampleTiles: [],
  ),
  // 三相逢 – Mixed Triple Sequence (Exposed 15 / Concealed 20 Tai)
  Rule(
    name: AppLocalizations.twMixedTripleSeq,
    description: AppLocalizations.twDescMixedTripleSeq,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplMixedTripleSeq,
    validator: null,
    exampleTiles: [],
  ),
  // 五同順 – Five Identical Sequences (45 Tai)
  Rule(
    name: AppLocalizations.twFiveIdenticalSeq,
    description: AppLocalizations.twDescFiveIdenticalSeq,
    fan: AppLocalizations.taiCount(45),
    fanValue: 45,
    explanation: AppLocalizations.twExplFiveIdenticalSeq,
    validator: null,
    exampleTiles: [],
  ),
  // 二兄弟 – Two Brothers / Consecutive Pongs (3 Tai)
  Rule(
    name: AppLocalizations.twTwoBrothers,
    description: AppLocalizations.twDescTwoBrothers,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.twExplTwoBrothers,
    validator: null,
    exampleTiles: [],
  ),
  // 小三兄弟 – Small Three Brothers (10 Tai)
  Rule(
    name: AppLocalizations.twSmallThreeBrothers,
    description: AppLocalizations.twDescSmallThreeBrothers,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplSmallThreeBrothers,
    validator: null,
    exampleTiles: [],
  ),
  // 大三兄弟 – Big Three Brothers (15 Tai)
  Rule(
    name: AppLocalizations.twBigThreeBrothers,
    description: AppLocalizations.twDescBigThreeBrothers,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplBigThreeBrothers,
    validator: null,
    exampleTiles: [],
  ),
  // 小三姊妹 – Small Three Sisters (8 Tai)
  Rule(
    name: AppLocalizations.twSmallThreeSisters,
    description: AppLocalizations.twDescSmallThreeSisters,
    fan: AppLocalizations.taiCount(8),
    fanValue: 8,
    explanation: AppLocalizations.twExplSmallThreeSisters,
    validator: null,
    exampleTiles: [],
  ),
  // 大三姊妹 – Big Three Sisters (15 Tai)
  Rule(
    name: AppLocalizations.twBigThreeSisters,
    description: AppLocalizations.twDescBigThreeSisters,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplBigThreeSisters,
    validator: null,
    exampleTiles: [],
  ),
  // 四歸一 – Four to One (Exposed 3 / Concealed 5 Tai)
  Rule(
    name: AppLocalizations.twFourToOne,
    description: AppLocalizations.twDescFourToOne,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.twExplFourToOne,
    validator: null,
    exampleTiles: [],
  ),
  // 四歸二 – Four to Two (10 Tai)
  Rule(
    name: AppLocalizations.twFourToTwo,
    description: AppLocalizations.twDescFourToTwo,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplFourToTwo,
    validator: null,
    exampleTiles: [],
  ),
  // 四歸四 – Four to Four (20 Tai)
  Rule(
    name: AppLocalizations.twFourToFour,
    description: AppLocalizations.twDescFourToFour,
    fan: AppLocalizations.taiCount(20),
    fanValue: 20,
    explanation: AppLocalizations.twExplFourToFour,
    validator: null,
    exampleTiles: [],
  ),

  // ═══════════════════════════════════════════════════════════
  // 4️⃣  花式牌型與特殊大牌 (Special Patterns & Big Hands)
  // ═══════════════════════════════════════════════════════════
  // 明龍 – Exposed Dragon / Straight (10 Tai)
  Rule(
    name: AppLocalizations.twExposedDragon,
    description: AppLocalizations.twDescExposedDragon,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplExposedDragon,
    validator: null,
    exampleTiles: [],
  ),
  // 暗龍 – Concealed Dragon / Straight (20 Tai)
  Rule(
    name: AppLocalizations.twConcealedDragon,
    description: AppLocalizations.descConcealedDragon,
    fan: AppLocalizations.taiCount(20),
    fanValue: 20,
    explanation: AppLocalizations.explConcealedDragon,
    validator: HandPatterns.isConcealedDragon,
    exampleTiles: [],
  ),
  // 明雜龍 – Exposed Mixed Dragon (8 Tai)
  Rule(
    name: AppLocalizations.twExposedMixedDragon,
    description: AppLocalizations.twDescExposedMixedDragon,
    fan: AppLocalizations.taiCount(8),
    fanValue: 8,
    explanation: AppLocalizations.twExplExposedMixedDragon,
    validator: null,
    exampleTiles: [],
  ),
  // 暗雜龍 – Concealed Mixed Dragon (15 Tai)
  Rule(
    name: AppLocalizations.twConcealedMixedDragon,
    description: AppLocalizations.twDescConcealedMixedDragon,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplConcealedMixedDragon,
    validator: null,
    exampleTiles: [],
  ),
  // 五門齊 – Five Gates / All Types (5 Tai)
  Rule(
    name: AppLocalizations.twFiveGates,
    description: AppLocalizations.twDescFiveGates,
    fan: AppLocalizations.taiCount(5),
    fanValue: 5,
    explanation: AppLocalizations.twExplFiveGates,
    validator: null,
    exampleTiles: [],
  ),
  // 缺一門 – Missing One Suit (3 Tai)
  Rule(
    name: AppLocalizations.twMissingOneSuit,
    description: AppLocalizations.twDescMissingOneSuit,
    fan: AppLocalizations.taiCount(3),
    fanValue: 3,
    explanation: AppLocalizations.twExplMissingOneSuit,
    validator: null,
    exampleTiles: [],
  ),
  // 混一色 – Mixed One Suit / Half Flush (30 Tai)
  Rule(
    name: AppLocalizations.ruleMixedOneSuit,
    description: AppLocalizations.descMixedOneSuit,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.explMixedOneSuit,
    validator: HandPatterns.isMixedOneSuit,
    exampleTiles: [],
  ),
  // 清一色 – Pure One Suit / Full Flush (80 Tai)
  Rule(
    name: AppLocalizations.rulePureOneSuit,
    description: AppLocalizations.descPureOneSuit,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.explPureOneSuit,
    validator: HandPatterns.isPureHand,
    exampleTiles: [],
  ),
  // 對對胡 – All Pongs (30 Tai)
  Rule(
    name: AppLocalizations.ruleAllPongs,
    description: AppLocalizations.descAllPongs,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.explAllPongs,
    validator: HandPatterns.isAllPongs,
    exampleTiles: [],
  ),
  // 全求人 – All Revealed / Fully Exposed (15 Tai)
  Rule(
    name: AppLocalizations.twAllRevealed,
    description: AppLocalizations.twDescAllRevealed,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplAllRevealed,
    validator: null,
    exampleTiles: [],
  ),
  // 半求人 – Half Revealed (8 Tai)
  Rule(
    name: AppLocalizations.twHalfRevealed,
    description: AppLocalizations.twDescHalfRevealed,
    fan: AppLocalizations.taiCount(8),
    fanValue: 8,
    explanation: AppLocalizations.twExplHalfRevealed,
    validator: null,
    exampleTiles: [],
  ),
  // 七只內 – Last 7 Tiles (20 Tai)
  Rule(
    name: AppLocalizations.twLastSevenTiles,
    description: AppLocalizations.twDescLastSevenTiles,
    fan: AppLocalizations.taiCount(20),
    fanValue: 20,
    explanation: AppLocalizations.twExplLastSevenTiles,
    validator: null,
    exampleTiles: [],
  ),
  // 十只內 – Last 10 Tiles (10 Tai)
  Rule(
    name: AppLocalizations.twLastTenTiles,
    description: AppLocalizations.twDescLastTenTiles,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplLastTenTiles,
    validator: null,
    exampleTiles: [],
  ),
  // 小三元 – Small Three Dragons (20 Tai)
  Rule(
    name: AppLocalizations.ruleSmallThreeDragons,
    description: AppLocalizations.descSmallThreeDragons,
    fan: AppLocalizations.taiCount(20),
    fanValue: 20,
    explanation: AppLocalizations.explSmallThreeDragons,
    validator: HandPatterns.isSmallThreeDragons,
    exampleTiles: [],
  ),
  // 大三元 – Big Three Dragons (40 Tai)
  Rule(
    name: AppLocalizations.ruleBigThreeDragons,
    description: AppLocalizations.descBigThreeDragons,
    fan: AppLocalizations.taiCount(40),
    fanValue: 40,
    explanation: AppLocalizations.explBigThreeDragons,
    validator: HandPatterns.isBigThreeDragons,
    exampleTiles: [],
  ),
  // 小三風 – Small Three Winds (15 Tai)
  Rule(
    name: AppLocalizations.twSmallThreeWinds,
    description: AppLocalizations.twDescSmallThreeWinds,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplSmallThreeWinds,
    validator: null,
    exampleTiles: [],
  ),
  // 大三風 – Big Three Winds (30 Tai)
  Rule(
    name: AppLocalizations.twBigThreeWinds,
    description: AppLocalizations.twDescBigThreeWinds,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplBigThreeWinds,
    validator: null,
    exampleTiles: [],
  ),
  // 小四喜 – Small Four Winds (60 Tai)
  Rule(
    name: AppLocalizations.ruleSmallFourWinds,
    description: AppLocalizations.descSmallFourWinds,
    fan: AppLocalizations.taiCount(60),
    fanValue: 60,
    explanation: AppLocalizations.explSmallFourWinds,
    validator: HandPatterns.isSmallFourWinds,
    exampleTiles: [],
  ),
  // 大四喜 – Big Four Winds (80 Tai)
  Rule(
    name: AppLocalizations.ruleBigFourWinds,
    description: AppLocalizations.descBigFourWinds,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.explBigFourWinds,
    validator: HandPatterns.isBigFourWinds,
    exampleTiles: [],
  ),
  // 十三么 – Thirteen Orphans (80 Tai)
  Rule(
    name: AppLocalizations.ruleThirteenOrphans,
    description: AppLocalizations.descThirteenOrphans,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.explThirteenOrphans,
    validator: HandPatterns.isThirteenOrphans,
    exampleTiles: [],
  ),
  // 十六不搭 – Sixteen Non-Matching (50 Tai)
  Rule(
    name: AppLocalizations.twSixteenNonMatching,
    description: AppLocalizations.twDescSixteenNonMatching,
    fan: AppLocalizations.taiCount(50),
    fanValue: 50,
    explanation: AppLocalizations.twExplSixteenNonMatching,
    validator: null,
    exampleTiles: [],
  ),
  // 嚦咕嚦咕 – Eight Pairs (40 Tai)
  Rule(
    name: AppLocalizations.twMiguiTw,
    description: AppLocalizations.twDescMiguiTw,
    fan: AppLocalizations.taiCount(40),
    fanValue: 40,
    explanation: AppLocalizations.twExplMiguiTw,
    validator: HandPatterns.isEightPairs,
    exampleTiles: [],
  ),
  // 一台花 – One Flower Set (10 Tai)
  Rule(
    name: AppLocalizations.twOneFlowerSet,
    description: AppLocalizations.twDescOneFlowerSet,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplOneFlowerSet,
    validator: null,
    exampleTiles: [],
  ),
  // 兩台花 – Two Flower Sets (30 Tai)
  Rule(
    name: AppLocalizations.twTwoFlowerSets,
    description: AppLocalizations.twDescTwoFlowerSets,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplTwoFlowerSets,
    validator: null,
    exampleTiles: [],
  ),
  // 斷么 – All Simples (5 Tai)
  Rule(
    name: AppLocalizations.twAllSimples,
    description: AppLocalizations.descAllSimples,
    fan: AppLocalizations.taiCount(5),
    fanValue: 5,
    explanation: AppLocalizations.explAllSimples,
    validator: HandPatterns.isAllSimples,
    exampleTiles: [],
  ),
  // 全帶混么 – Mixed Terminal Chows (10 Tai)
  Rule(
    name: AppLocalizations.twMixedTerminalChows,
    description: AppLocalizations.twDescMixedTerminalChows,
    fan: AppLocalizations.taiCount(10),
    fanValue: 10,
    explanation: AppLocalizations.twExplMixedTerminalChows,
    validator: null,
    exampleTiles: [],
  ),
  // 全帶么 – Pure Terminal Chows (15 Tai)
  Rule(
    name: AppLocalizations.twPureTerminalChows,
    description: AppLocalizations.twDescPureTerminalChows,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplPureTerminalChows,
    validator: null,
    exampleTiles: [],
  ),
  // 混么 – Mixed Terminals (30 Tai)
  Rule(
    name: AppLocalizations.twMixedTerminalsPongs,
    description: AppLocalizations.twDescMixedTerminalsPongs,
    fan: AppLocalizations.taiCount(30),
    fanValue: 30,
    explanation: AppLocalizations.twExplMixedTerminalsPongs,
    validator: HandPatterns.isMixedTerminals,
    exampleTiles: [],
  ),
  // 清么 – Pure Terminals (80 Tai)
  Rule(
    name: AppLocalizations.twPureTerminalsTw,
    description: AppLocalizations.twDescPureTerminalsTw,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.twExplPureTerminalsTw,
    validator: HandPatterns.isPureTerminals,
    exampleTiles: [],
  ),
  // 字一色 – All Honors (16 Tai)
  Rule(
    name: AppLocalizations.ruleAllHonors,
    description: AppLocalizations.descAllHonors,
    fan: AppLocalizations.taiCount(16),
    fanValue: 16,
    explanation: AppLocalizations.explAllHonors,
    validator: HandPatterns.isAllHonors,
    exampleTiles: [],
  ),
  // 九子連環 – Nine Gates (16 Tai)
  Rule(
    name: AppLocalizations.ruleNineGates,
    description: AppLocalizations.descNineGates,
    fan: AppLocalizations.taiCount(16),
    fanValue: 16,
    explanation: AppLocalizations.explNineGates,
    validator: HandPatterns.isNineGates,
    exampleTiles: [],
  ),
  // 十八羅漢 – Eighteen Arhats (16 Tai)
  Rule(
    name: AppLocalizations.ruleEighteenArhats,
    description: AppLocalizations.descEighteenArhats,
    fan: AppLocalizations.taiCount(16),
    fanValue: 16,
    explanation: AppLocalizations.explEighteenArhats,
    validator: HandPatterns.isEighteenArhats,
    exampleTiles: [],
  ),

  // ═══════════════════════════════════════════════════════════
  // 5️⃣  特殊胡牌 (Special Win Conditions)
  // ═══════════════════════════════════════════════════════════
  // 天胡 – Heavenly Hand (100 Tai)
  Rule(
    name: AppLocalizations.ruleHeavenlyHand,
    description: AppLocalizations.descHeavenlyHand,
    fan: AppLocalizations.taiCount(100),
    fanValue: 100,
    explanation: AppLocalizations.explHeavenlyHand,
    validator: null,
    exampleTiles: [],
  ),
  // 地胡 – Earthly Hand (80 Tai)
  Rule(
    name: AppLocalizations.ruleEarthlyHand,
    description: AppLocalizations.descEarthlyHand,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.explEarthlyHand,
    validator: null,
    exampleTiles: [],
  ),
  // 人胡 – Human Win (80 Tai)
  Rule(
    name: AppLocalizations.twHumanWin,
    description: AppLocalizations.twDescHumanWin,
    fan: AppLocalizations.taiCount(80),
    fanValue: 80,
    explanation: AppLocalizations.twExplHumanWin,
    validator: null,
    exampleTiles: [],
  ),
  // 七搶一 – Seven Rob One (15 Tai)
  Rule(
    name: AppLocalizations.twSevenRobOne,
    description: AppLocalizations.twDescSevenRobOne,
    fan: AppLocalizations.taiCount(15),
    fanValue: 15,
    explanation: AppLocalizations.twExplSevenRobOne,
    validator: null,
    exampleTiles: [],
  ),
  // 天聽 – Heavenly Ready (50 Tai)
  Rule(
    name: AppLocalizations.twHeavenlyReady,
    description: AppLocalizations.twDescHeavenlyReady,
    fan: AppLocalizations.taiCount(50),
    fanValue: 50,
    explanation: AppLocalizations.twExplHeavenlyReady,
    validator: null,
    exampleTiles: [],
  ),
  // 地聽 – Earthly Ready (25 Tai)
  Rule(
    name: AppLocalizations.twEarthlyReady,
    description: AppLocalizations.twDescEarthlyReady,
    fan: AppLocalizations.taiCount(25),
    fanValue: 25,
    explanation: AppLocalizations.twExplEarthlyReady,
    validator: null,
    exampleTiles: [],
  ),
];

// ============================================================
// Taiwan-specific informational rules (non-scoring)
// These are displayed as separate sections in the rules screen.
// ============================================================

/// Instant payment items (即時付錢項目)
/// Events that require immediate payment during gameplay.
List<Rule> get twInstantPayRules => [
  Rule(
    name: AppLocalizations.twChaseRule,
    description: AppLocalizations.twChaseDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twChaseDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twConcealedKongPay,
    description: AppLocalizations.twConcealedKongPayDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twConcealedKongExpl,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twFlowerSeasonSetPay,
    description: AppLocalizations.twFlowerSeasonSetPayDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twFlowerSeasonSetPayDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twFlowerGroupPay,
    description: AppLocalizations.twFlowerGroupPayDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twFlowerGroupPayDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twFalseWinPay,
    description: AppLocalizations.twFalseWinPayDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twFalseWinPayDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twCalledPongPenalty,
    description: AppLocalizations.twCalledPongPenaltyDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twCalledPongPenaltyDesc,
    exampleTiles: [],
  ),
];

/// Penalty rules (特殊處罰規則)
/// Rules about win eligibility and scoring penalties.
List<Rule> get twPenaltyRules => [
  Rule(
    name: AppLocalizations.twWinPlacementRule,
    description: AppLocalizations.twWinPlacementDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twWinPlacementDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twMissedWinRule,
    description: AppLocalizations.twMissedWinDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twMissedWinDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twKongRevealRule,
    description: AppLocalizations.twKongRevealDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twKongRevealDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twDealerMarkerRule,
    description: AppLocalizations.twDealerMarkerDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twDealerMarkerDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twFlowerOrderRule,
    description: AppLocalizations.twFlowerOrderDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twFlowerOrderDesc,
    exampleTiles: [],
  ),
];

/// 「拉」Settlement rules (拉結算規則)
/// Carry-over settlement system affecting consecutive rounds.
List<Rule> get twLaSettlementRules => [
  Rule(
    name: AppLocalizations.twLaMultiplier,
    description: AppLocalizations.twLaMultiplierDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twLaMultiplierDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twLaReduction,
    description: AppLocalizations.twLaReductionDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twLaReductionDesc,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.twLaStopRule,
    description: AppLocalizations.twLaStopRuleDesc,
    fan: '',
    fanValue: 0,
    explanation: AppLocalizations.twLaStopRuleDesc,
    exampleTiles: [],
  ),
];

/// Dealer bonus rules (莊家加成規則)
List<Rule> get twDealerBonusRules => [
  Rule(
    name: AppLocalizations.twDealerBonusBase,
    description: AppLocalizations.twDealerBonusFormula,
    fan: '',
    fanValue: 0,
    explanation:
        '${AppLocalizations.twDealerBonusExample1}\n${AppLocalizations.twDealerBonusExample2}\n${AppLocalizations.twDealerBonusExample3}\n\n${AppLocalizations.twDealerBonusResponsibility}',
    exampleTiles: [],
  ),
];
