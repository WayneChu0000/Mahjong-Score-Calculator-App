// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_gen.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '麻將計分器';

  @override
  String get homeTitle => '麻將計分器';

  @override
  String get welcomeBack => '歡迎回來!';

  @override
  String get newGroup => '新群組';

  @override
  String get history => '歷史紀錄';

  @override
  String get historyComingSoon => '歷史紀錄功能即將推出...';

  @override
  String get testFirebase => '測試 Firebase';

  @override
  String get firebaseSuccess => 'Firebase 連線成功: ';

  @override
  String get firebaseFailed => 'Firebase 連線失敗: ';

  @override
  String get savedGroups => '已儲存的群組';

  @override
  String get viewAll => '檢視全部';

  @override
  String get noSavedGroups => '沒有已儲存的群組';

  @override
  String get createFirstGroupHint => '建立您的第一個群組以開始使用';

  @override
  String get createGroup => '建立群組';

  @override
  String get players => '名玩家';

  @override
  String get createdAt => '建立於: ';

  @override
  String get edit => '編輯';

  @override
  String get start => '開始';

  @override
  String get allGroups => '所有群組';

  @override
  String get editGroupComingSoon => '編輯群組功能即將推出...';

  @override
  String get scoreUpdated => '群組分數已更新: ';

  @override
  String get playerSetupTitle => '玩家設定';

  @override
  String get groupName => '群組名稱';

  @override
  String get groupNameHint => '輸入群組名稱';

  @override
  String get groupNameError => '請輸入群組名稱';

  @override
  String get playerName => '玩家名稱';

  @override
  String get playerNameHint => '輸入玩家名稱';

  @override
  String get addPlayer => '新增玩家';

  @override
  String get minimumPlayers => '至少需要 2 名玩家';

  @override
  String get duplicatePlayer => '玩家已存在';

  @override
  String get saveGroup => '儲存群組';

  @override
  String get saveAndPlay => '儲存並開始';

  @override
  String get cancel => '取消';

  @override
  String get remove => '移除';

  @override
  String get playerList => '玩家列表';

  @override
  String get groupSaved => '群組儲存成功!';

  @override
  String get groupSaveFailed => '儲存群組失敗';

  @override
  String get minFan => '最少番數';

  @override
  String get maxFan => '最大番數';

  @override
  String get noLimit => '無上限';

  @override
  String get fanLimitSettings => '番數限制設定';

  @override
  String get gameMode => '遊戲模式';

  @override
  String get hongKongMahjong => '港式麻將 (13張)';

  @override
  String get taiwaneseMahjong => '台式麻將 (16張)';

  @override
  String get baseTai => '底台';

  @override
  String get taiValue => '每台分數';

  @override
  String get tai => '台';

  @override
  String get scoreRecording => '計分板';

  @override
  String get round => '局數';

  @override
  String get ofSeparator => '/';

  @override
  String get dealer => '莊家';

  @override
  String get calculateScore => '計算分數';

  @override
  String get endGame => '結束遊戲';

  @override
  String get gameResults => '遊戲結果';

  @override
  String get finalScores => '最終分數';

  @override
  String get winner => '贏家';

  @override
  String get close => '關閉';

  @override
  String get nextRound => '下一局';

  @override
  String get stats => '統計';

  @override
  String get roundsPlayed => '已進行局數';

  @override
  String get selfDrawn => '自摸';

  @override
  String get winningRate => '勝率';

  @override
  String fan(int f) {
    return '$f 番';
  }

  @override
  String taiCount(int t) {
    return '$t 台';
  }

  @override
  String get totalFan => '總番數';

  @override
  String get totalTai => '總台數';

  @override
  String get scoreCalculation => '分數計算';

  @override
  String get enterScores => '輸入分數';

  @override
  String get specialWinningCondition => '特殊牌型';

  @override
  String currentScore(int score) {
    return '(目前: $score 分)';
  }

  @override
  String totalWin(int score) {
    return '(總計: $score)';
  }

  @override
  String get submit => '送出';

  @override
  String get reset => '重置';

  @override
  String get totalMustBeZero => '總和必須為零';

  @override
  String get confirmSubmit => '確認非零總和?';

  @override
  String get totalIs => '總和為 ';

  @override
  String get continueAnyway => '強制繼續';

  @override
  String get win => '胡牌';

  @override
  String get selfDraw => '自摸';

  @override
  String get discard => '出衝';

  @override
  String get winningPlayer => '胡牌玩家';

  @override
  String get discardPlayer => '放槍玩家';

  @override
  String get roundWind => '圈風';

  @override
  String get seatWind => '門風';

  @override
  String get flowers => '花牌';

  @override
  String get selectFlowers => '選擇花牌';

  @override
  String get handPreviewArea => '手牌預覽區域';

  @override
  String get scanTiles => '掃描牌型';

  @override
  String get selectHand => '選擇牌型';

  @override
  String get analyzingTiles => '正在分析牌型...';

  @override
  String get takePhotoHint => '拍照或點擊以選擇牌型';

  @override
  String get item => '項目';

  @override
  String get value => '數值';

  @override
  String get totalScore => '總分數';

  @override
  String get fanTitle => '番數';

  @override
  String get limit => '爆棚';

  @override
  String get perPerson => ' / 人';

  @override
  String get points => '分';

  @override
  String get twConcealedSelfDraw => '門清自摸';

  @override
  String get descConcealedSelfDraw => '門清狀態下自摸胡牌';

  @override
  String get explConcealedSelfDraw => '沒有碰、上或明槓，牌全在手中（暗槓可），自己摸到胡的牌。';

  @override
  String get twProperWind => '正風牌';

  @override
  String get descProperWind => '碰出與當圈或方位相同的風牌';

  @override
  String get explProperWind => '碰出與當圈或方位相同的東、南、西或北風牌，每組 2 台。';

  @override
  String get twOrdinaryWind => '非正風牌';

  @override
  String get descOrdinaryWind => '碰出非當圈或方位的風牌';

  @override
  String get explOrdinaryWind => '碰出非當圈或方位的風牌，每組 1 台。';

  @override
  String get twDragonPong => '三元牌刻';

  @override
  String get descTwDragonPong => '碰出紅中、發財或白板';

  @override
  String get explTwDragonPong => '碰出紅中、發財或白板，每組 2 台。';

  @override
  String get twEyeOf258 => '將眼 (2,5,8)';

  @override
  String get descEyeOf258 => '以數字 2、5 或 8 的牌作為對子';

  @override
  String get explEyeOf258 => '以數字 2、5 或 8 的牌作為對子（眼），加 1 台。';

  @override
  String get twAllSimples => '斷么';

  @override
  String get descAllSimples => '全副牌沒有么九牌及字牌';

  @override
  String get explAllSimples => '全副牌沒有么九牌（1、9）及字牌。全斷么 5 台，半斷么 3 台。';

  @override
  String get twConcealedDragon => '暗龍';

  @override
  String get descConcealedDragon => '同花色 1 至 9 全在手中';

  @override
  String get explConcealedDragon => '同花色 1 至 9 全在手中（暗擺），20 台。';

  @override
  String get twFiveConcealedPongs => '五暗刻';

  @override
  String get descFiveConcealedPongs => '手中擁有五組暗刻';

  @override
  String get explFiveConcealedPongs => '手中擁有五組暗刻（不包括明碰、明槓），80 台。';

  @override
  String get twDeclaredReady => '聽牌';

  @override
  String get descDeclaredReady => '聲明聽牌，之後不得轉章或暗槓';

  @override
  String get explDeclaredReady => '聲明聽牌後不得轉章或暗槓，5 台。';

  @override
  String get twUnderTheSea => '海底撈月';

  @override
  String get descUnderTheSea => '摸到最後一隻牌自摸';

  @override
  String get explUnderTheSea => '摸到牌牆最後一張牌而自摸胡牌，20 台。';

  @override
  String get twWrongFlower => '爛花';

  @override
  String get descWrongFlower => '花牌數字與自己的座位數字不同';

  @override
  String get explWrongFlower => '花牌數字與自己的座位數字不同，每張 1 台。';

  @override
  String get twProperFlower => '正花';

  @override
  String get descProperFlower => '花牌數字與自己的座位數字相同';

  @override
  String get explProperFlower => '花牌數字與自己的座位數字相同，每張 2 台。';

  @override
  String get twDealerBonus => '莊家加成';

  @override
  String get twConsecutiveDealer => '連莊加成';

  @override
  String consecutiveDealerCount(int count) {
    return '連 $count 拉';
  }

  @override
  String get twDeclaredReadyCondition => '聽牌 (叮)';

  @override
  String get ruleSelfDraw => '自摸';

  @override
  String get ruleNoFlowers => '無花';

  @override
  String get ruleFlowerPlatform14 => '花台 (1-4)';

  @override
  String get ruleFlowerPlatform58 => '花台 (5-8)';

  @override
  String get ruleOwnFlower => '正花';

  @override
  String get ruleOwnSeason => '正花';

  @override
  String get rulePongOfWhite => '白板刻';

  @override
  String get rulePongOfGreen => '發財刻';

  @override
  String get rulePongOfRed => '紅中刻';

  @override
  String get ruleRoundWind => '圈風';

  @override
  String get ruleSeatWind => '門風';

  @override
  String get ruleAllChows => '平胡';

  @override
  String get ruleAllPongs => '對對胡';

  @override
  String get ruleMixedOneSuit => '混一色';

  @override
  String get rulePureOneSuit => '清一色';

  @override
  String get ruleSmallThreeDragons => '小三元';

  @override
  String get ruleBigThreeDragons => '大三元';

  @override
  String get ruleSmallFourWinds => '小四喜';

  @override
  String get ruleBigFourWinds => '大四喜';

  @override
  String get ruleThirteenOrphans => '十三么';

  @override
  String get ruleEightImmortals => '八仙過海';

  @override
  String get ruleFlowerHand => '花胡';

  @override
  String get ruleHiddenTreasure => '坎坎胡';

  @override
  String get ruleAllHonors => '字一色';

  @override
  String get ruleNineGates => '九子連環';

  @override
  String get ruleEighteenArhats => '十八羅漢';

  @override
  String get ruleSevenPairs => '七對子';

  @override
  String get ruleMigui => '嚦咕嚦咕 (八對半)';

  @override
  String get descSevenPairs => '由七個對子組成';

  @override
  String get descMigui => '由八個對子組成 (16張+1)';

  @override
  String get explSevenPairs => '七個對子';

  @override
  String get explMigui => '八個對子';

  @override
  String get ruleHeavenlyHand => '天胡';

  @override
  String get ruleEarthlyHand => '地胡';

  @override
  String get ruleKong => '槓';

  @override
  String get ruleNone => '無';

  @override
  String get east => '東';

  @override
  String get south => '南';

  @override
  String get west => '西';

  @override
  String get north => '北';

  @override
  String get home => '首頁';

  @override
  String get rules => '規則';

  @override
  String get gameRules => '遊戲規則';

  @override
  String get settings => '設定';

  @override
  String get confirm => '確認';

  @override
  String get delete => '刪除';

  @override
  String get save => '儲存';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get ok => '確定';

  @override
  String get error => '錯誤';

  @override
  String get success => '成功';

  @override
  String get loading => '載入中...';

  @override
  String get retry => '重試';

  @override
  String get language => '語言';

  @override
  String get theme => '主題';

  @override
  String get logout => '登出';

  @override
  String get confirmLogout => '確定要登出嗎?';

  @override
  String get langEnglish => '英文';

  @override
  String get langTraditionalChinese => '繁體中文';

  @override
  String get lightMode => '淺色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get themeMode => '主題模式';

  @override
  String get about => '關於';

  @override
  String get aboutDesc => '簡單易用的麻將計分器。';

  @override
  String get copyright => '© 2025 麻將計分器團隊';

  @override
  String get feedback => '意見回饋';

  @override
  String get feedbackContent => '請將您的意見發送至 support@example.com';

  @override
  String get privacyPolicy => '隱私權政策';

  @override
  String get privacyPolicyContent =>
      '我們尊重您的隱私。本應用程式將您的遊戲數據儲存在本地及 Firebase 用於同步。我們不會與第三方分享您的個人數據。';

  @override
  String get confirmDeleteGroup => '確定要刪除此群組嗎?';

  @override
  String get gameInProgressTitle => '開始新遊戲?';

  @override
  String get gameInProgressContent => '有未完成的遊戲。開始新遊戲將會把上一場視為結束並儲存紀錄。';

  @override
  String get startNewGame => '開始新遊戲';

  @override
  String get resumeGame => '繼續遊戲';

  @override
  String get backToGame => '回到遊戲';

  @override
  String get playerStatsTitle => '玩家數據';

  @override
  String get recentGroups => '最近群組';

  @override
  String get mostPlayedGroups => '常用群組';

  @override
  String get editPlayers => '編輯玩家';

  @override
  String get setupPlayers => '設定玩家';

  @override
  String get enterGroupNameHint => '例如: 週末麻將團';

  @override
  String get confirmDelete => '確認刪除';

  @override
  String get deleteGroupWarning => '確定要刪除此群組嗎? 此動作無法復原。';

  @override
  String editPlayerTitle(int index) {
    return '編輯玩家 $index';
  }

  @override
  String get totalGamesMatches => '總局數 (場):';

  @override
  String get descAllChows => '只有順子, 無刻子';

  @override
  String get explAllChows => '全副牌由順子和一對組成，沒刻子或槓';

  @override
  String get descNoFlowers => '沒有花牌';

  @override
  String get explNoFlowers => '沒有持有任何花牌而胡牌';

  @override
  String get descOwnSeason => '花牌對應門風';

  @override
  String get explOwnSeason => '花牌號碼對應你的座位 (1東 2南 3西 4北)';

  @override
  String get descSelfDraw => '自摸胡牌';

  @override
  String get explSelfDraw => '自己摸到獲勝的牌';

  @override
  String get ruleMenQianQing => '門前清';

  @override
  String get descMenQianQing => '沒有鳴牌';

  @override
  String get explMenQianQing => '整副牌皆為門前清（沒有吃、碰、明槓）。';

  @override
  String get ruleDragonWindPong => '番子';

  @override
  String get descDragonWindPong => '三元牌或風牌刻子';

  @override
  String get explDragonWindPong => '擁有中、發、白或圈風、門風的刻子/槓。';

  @override
  String get ruleRobbingKong => '搶槓';

  @override
  String get descRobbingKong => '胡別人加槓的牌';

  @override
  String get explRobbingKong => '當別人進行加槓（小明槓）時，那張牌剛好是你胡的牌。';

  @override
  String get ruleHaidilao => '海底撈月';

  @override
  String get descHaidilao => '自摸最後一張牌';

  @override
  String get explHaidilao => '摸到牌牆的最後一張牌而胡牌。';

  @override
  String get ruleKongOnKong => '槓上槓/花上自摸';

  @override
  String get descKongOnKong => '槓牌或補花後自摸';

  @override
  String get explKongOnKong => '槓牌或補花後，摸到的補牌胡牌。';

  @override
  String get ruleFlowerPlatform => '一台花';

  @override
  String get descFlowerPlatform => '集齊一種花色(1-4)';

  @override
  String get explFlowerPlatform => '集齊一副完整的花牌(春夏秋冬 或 梅蘭菊竹)。';

  @override
  String get ruleSevenFlowers => '七隻花';

  @override
  String get descSevenFlowers => '集齊七張花';

  @override
  String get explSevenFlowers => '拿到七張花牌可立即胡牌(計3番)。';

  @override
  String get descAllPongs => '全為刻子/對子';

  @override
  String get explAllPongs => '全副牌由刻子(或槓)和一對將眼組成。';

  @override
  String get descMixedOneSuit => '單一花色 + 字牌';

  @override
  String get explMixedOneSuit => '由同一花色牌及字牌組成。';

  @override
  String get ruleMixedTerminals => '混么九';

  @override
  String get descMixedTerminals => '么九 + 字牌刻子';

  @override
  String get explMixedTerminals => '全副牌由么九牌(1,9)及字牌的刻子/將眼組成。';

  @override
  String get descSmallThreeDragons => '兩副三元刻 + 一對眼';

  @override
  String get explSmallThreeDragons => '兩副三元牌刻子及一副三元牌將眼。';

  @override
  String get descSmallFourWinds => '三副風刻 + 一對眼';

  @override
  String get explSmallFourWinds => '三副風牌刻子及一副風牌將眼。';

  @override
  String get descThirteenOrphans => '十三種么九字牌';

  @override
  String get explThirteenOrphans => '集齊所有么九牌及字牌各一張，加其中一張做眼。';

  @override
  String get ruleBlessingMan => '人胡';

  @override
  String get ruleBlessingOfMan => '人胡';

  @override
  String get descBlessingMan => '閒家第一輪自摸';

  @override
  String get explBlessingMan => '閒家第一輪自摸。';

  @override
  String get descEarthlyHand => '閒家食莊家首打';

  @override
  String get explEarthlyHand => '閒家食和莊家打出的第一張牌。';

  @override
  String get descHeavenlyHand => '莊家起手即胡';

  @override
  String get explHeavenlyHand => '莊家起手配牌即胡牌。';

  @override
  String get descEighteenArhats => '四個槓 (18張)';

  @override
  String get explEighteenArhats => '四個槓(共18張牌)胡牌。';

  @override
  String get descBigFourWinds => '四副風刻';

  @override
  String get explBigFourWinds => '四副風牌刻子/槓。';

  @override
  String get descEightImmortals => '集齊八張花牌';

  @override
  String get explEightImmortals => '拿到八張花牌可立即胡牌(計8番)。';

  @override
  String get descHiddenTreasure => '四副暗刻 (門前清)';

  @override
  String get explHiddenTreasure => '四副刻子皆為自摸/門前清(四暗刻)。';

  @override
  String get ruleDoubleKong => '槓上槓';

  @override
  String get descDoubleKong => '連續兩次槓後胡';

  @override
  String get explDoubleKong => '連開兩次槓後，補充得來的牌胡牌。';

  @override
  String get descAllHonors => '全副字牌';

  @override
  String get explAllHonors => '全副牌由字牌組成。';

  @override
  String get rulePureTerminals => '清么九';

  @override
  String get descPureTerminals => '全副么九刻子';

  @override
  String get explPureTerminals => '全副牌由么九牌(1,9)的刻子/將眼組成。';

  @override
  String get descNineGates => '同花色 111...999';

  @override
  String get explNineGates => '門前清同一花色：1112345678999 再加任何一張同花色的牌。';

  @override
  String get descPureOneSuit => '單一花色';

  @override
  String get explPureOneSuit => '由同一花色牌組成。';

  @override
  String get descBigThreeDragons => '三副三元刻';

  @override
  String get explBigThreeDragons => '三副三元牌刻子/槓。';

  @override
  String get totalHandsPlayed => '總手数:';

  @override
  String get noResultRate => '流局率:';

  @override
  String get statsWinRate => '勝率';

  @override
  String get statsSelfDraw => '自摸';

  @override
  String get statsRon => '食糊';

  @override
  String get statsDealIn => '放銃';

  @override
  String get selectDealer => '選擇莊家';

  @override
  String get startGame => '開始遊戲';

  @override
  String get gameOver => '遊戲結束';

  @override
  String get totalWindRounds => '總圈數:';

  @override
  String get totalRoundsPlayed => '總局數:';

  @override
  String get totalGames => '總局數';

  @override
  String get finishGame => '結束遊戲';

  @override
  String get changePosition => '交換位置';

  @override
  String swapPositionsContent(String p1, String p2) {
    return '交換 $p1 和 $p2 的位置?';
  }

  @override
  String get swap => '交換';

  @override
  String get resetGameState => '重置遊戲狀態?';

  @override
  String get resetDealer => '重置莊家位置';

  @override
  String get resetDealerSubtitle => '重新選擇莊家';

  @override
  String get resetWind => '重置圈風';

  @override
  String get resetWindSubtitle => '重置為東一局';

  @override
  String get cancelReset => '取消重置';

  @override
  String get apply => '套用';

  @override
  String get currentGameStats => '目前戰況';

  @override
  String get noRoundsPlayed => '尚未進行任何局數。';

  @override
  String get mahjongScoringTitle => '麻將計分';

  @override
  String get windEast => '東';

  @override
  String get windSouth => '南';

  @override
  String get windWest => '西';

  @override
  String get windNorth => '北';

  @override
  String roundInfo(String wind, int game) {
    return '$wind風圈 - 第 $game 局';
  }

  @override
  String get calculate => '計算';

  @override
  String get noResult => '流局';

  @override
  String gameCount(int count) {
    return '第 $count 局';
  }

  @override
  String get mahjong => '麻將';

  @override
  String get windCircleSuffix => '風圈';

  @override
  String get tooltipStats => '遊戲統計';

  @override
  String get tooltipRules => '規則參考';

  @override
  String get tooltipHome => '回到首頁';

  @override
  String get loadFailed => '載入群組失敗: ';

  @override
  String get saveFailed => '儲存失敗: ';

  @override
  String get deleteFailed => '刪除失敗: ';

  @override
  String get noInternet => '無網路連線';

  @override
  String get tryAgain => '請再試一次';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get moreLanguagesComingSoon => '更多語言即將推出...';

  @override
  String get rulesAndTutorial => '規則與教學';

  @override
  String get rulesReference => '規則參考';

  @override
  String get mahjongTutorial => '麻將教學';

  @override
  String get allFan => '全部';

  @override
  String get searchRules => '搜尋規則';

  @override
  String get tutorialWelcome => '歡迎';

  @override
  String get tutorialTiles => '牌型';

  @override
  String get tutorialRules => '規則';

  @override
  String get rulesTitle => '規則';

  @override
  String get tutorialScore => '計分';

  @override
  String get previous => '上一頁';

  @override
  String get next => '下一頁';

  @override
  String get viewExample => '查看範例';

  @override
  String get hideExample => '隱藏範例';

  @override
  String get exampleExplanation => '範例說明:';

  @override
  String playerCount(int count) {
    return '$count 名玩家';
  }

  @override
  String roundOf(int current, int total) {
    return '第 $current / $total 局';
  }

  @override
  String get welcomeTitle => '歡迎使用麻將計分器';

  @override
  String get appDescription => '您的香港麻將全方位助手！';

  @override
  String get keyFeatures => '主要功能：';

  @override
  String get smartCalculatorTitle => '智能計分';

  @override
  String get smartCalculatorDesc => '即時計算番數與分數。支援十三么、九子連環等特殊牌型。';

  @override
  String get gameRecordingTitle => '對局記錄';

  @override
  String get gameRecordingDesc => '逐局記錄分數。自動管理莊家輪替與圈風。';

  @override
  String get rulesReferenceTitle => '規則參考';

  @override
  String get rulesReferenceDesc => '完整的香港麻將計分規則指南，附帶範例。';

  @override
  String get playerManagementTitle => '玩家管理';

  @override
  String get playerManagementDesc => '儲存玩家群組並追蹤總對局數。';

  @override
  String get swipeToLearn => '滑動以學習基礎知識 ->';

  @override
  String get tileTypesTitle => '麻將牌種類';

  @override
  String get characterTiles => '萬子';

  @override
  String get characterTilesDesc => '漢字數字一至九';

  @override
  String get dotsTiles => '筒子';

  @override
  String get dotsTilesDesc => '圓點數量一至九';

  @override
  String get bambooTiles => '索子';

  @override
  String get bambooTilesDesc => '竹條數量一至九';

  @override
  String get honorTiles => '字牌';

  @override
  String get honorTilesDesc => '包含風牌 (東南西北) 與三元牌 (中發白)';

  @override
  String get flowerTiles => '花牌';

  @override
  String get flowerTilesDesc => '花 (梅蘭菊竹) 與 季 (春夏秋冬)';

  @override
  String get basicRulesTitle => '基本規則';

  @override
  String get gameObjectiveTitle => '1. 遊戲目標';

  @override
  String get gameObjectiveDesc1 => '麻將的目標是組成一副完整的牌，通常包含：';

  @override
  String get gameObjectiveDesc2 => '• 4 組 (順子/刻子) + 1 對眼';

  @override
  String get gameObjectiveDesc3 => '• 特殊牌型 (例如：十三么)';

  @override
  String get basicTermsTitle => '2. 基本術語';

  @override
  String get basicTermsChow => '• 上 ：三張連續的牌 (例如：123萬)';

  @override
  String get basicTermsPong => '• 碰 ：三張相同的牌 (例如：333筒)';

  @override
  String get basicTermsEyes => '• 眼 ：一對相同的牌';

  @override
  String get basicTermsSelfDraw => '• 自摸 ：自己摸到獲勝的牌';

  @override
  String get basicTermsDiscard => '• 出衝 ：打出的牌讓別人胡牌';

  @override
  String get startingGameTitle => '3. 遊戲開始';

  @override
  String get startingGameDesc => '莊家 (東) 擲 2 或 3 顆骰子決定開門位置。';

  @override
  String get diceRollTableTitle => '擲骰與開門：';

  @override
  String get counterClockwiseCount => '從莊家開始逆時針數。';

  @override
  String get exampleRoll8 => '範例: 擲出 8 → 數到北位 (左家)。在北牆開門。';

  @override
  String get drawClockwise => '從開門處，順時針數墩數開始抓牌。';

  @override
  String get rememberDirection => '口訣：逆時針打牌，順時針抓牌！';

  @override
  String get dealingProcedureTitle => '配牌流程：';

  @override
  String get dealStep1 => '1. 每位玩家輪流抓 4 張牌 (2 墩)。';

  @override
  String get dealStep2 => '2. 重複直到每人有 12 張牌。';

  @override
  String get dealStep3 => '3. 莊家跳牌抓第 1 和第 3 張 (共 14 張)。';

  @override
  String get dealStep4 => '4. 閒家各抓 1 張 (共 13 張)。';

  @override
  String get dealStep5 => '5. 補花。';

  @override
  String get gameplayProcessTitle => '4. 行牌流程';

  @override
  String get gameplayProcessDesc => '配牌補花後，從莊家開始逆時針進行。';

  @override
  String get standardTurnTitle => '標準回合：';

  @override
  String get drawAction => '摸牌';

  @override
  String get actionAction => '動作';

  @override
  String get discardAction => '打牌';

  @override
  String get turnStep1 => '1. 從牌牆摸一張牌 (莊家首輪跳過)。';

  @override
  String get turnStep2 => '2. 若是花牌，補花。';

  @override
  String get turnStep3 => '3. 選擇是否暗槓、加槓或自摸胡牌。';

  @override
  String get turnStep4 => '4. 打出一張牌結束回合。';

  @override
  String get interactionsTitle => '鳴牌 (偷牌)：';

  @override
  String get interactionsDesc => '其他玩家可以喊出宣告來中斷回合。';

  @override
  String get priorityRuleTitle => '優先權規則：';

  @override
  String get priorityRuleDesc => '胡 > 槓/碰 > 上';

  @override
  String get priorityPongWins => '若一家想上，另一家想碰同一張牌，碰優先。';

  @override
  String get missedWinTitle => '過水規則：';

  @override
  String get missedWinDesc => '若你放棄胡別人打出的牌，在自己下次摸牌/動作前，不能胡同一張牌。';

  @override
  String get missedWinException => '例外：如果新摸到的牌讓你番數增加 (例如：湊成特殊牌型)，視乎家規可能允許胡牌。';

  @override
  String get actionChow => '上 ';

  @override
  String get targetLeftPlayer => '只限上家 (左家)';

  @override
  String get descChowInteract => '組成順子 (例如：1-2-3)';

  @override
  String get actionPong => '碰 ';

  @override
  String get targetAnyPlayer => '任何一家';

  @override
  String get descPongInteract => '組成刻子 (例如：3-3-3) -  中斷順序';

  @override
  String get actionKong => '槓 ';

  @override
  String get descKongInteract => '組成槓子 - 補牌 - 中斷順序';

  @override
  String get actionWinInteract => '胡 ';

  @override
  String get descWinInteract => '完成牌型 - 遊戲結束';

  @override
  String get scoringSystemTitle => '計分系統';

  @override
  String get scoringRulesTitle => '香港麻將計分表';

  @override
  String get scoringRulesDesc => '麻將分數由番數決定。下表顯示各番數對應的分數：';

  @override
  String get fanPointsHeader => '番數';

  @override
  String get byDiscardHeader => '出衝 (放槍)';

  @override
  String get bySelfDrawHeader => '自摸';

  @override
  String get flowerTilesScoringTitle => '花牌計分';

  @override
  String get noFlowersFan => '• 無花 ：1 番';

  @override
  String get ownFlowerFan => '• 正花 ：1 番 (花牌對應門風)';

  @override
  String get flowerMapping => '花牌對應：';

  @override
  String get seat1Flower => '• 1號位 (東)：春、梅';

  @override
  String get seat2Flower => '• 2號位 (南)：夏、蘭';

  @override
  String get seat3Flower => '• 3號位 (西)：秋、菊';

  @override
  String get seat4Flower => '• 4號位 (北)：冬、竹';

  @override
  String get honorTilesScoringTitle => '字牌計分';

  @override
  String get dragonPongFan => '• 三元牌刻/槓 (中發白)：1 番';

  @override
  String get roundWindPongFan => '• 圈風刻/槓：1 番';

  @override
  String get seatWindPongFan => '• 門風刻/槓：1 番';

  @override
  String get winningPatternsTitle => '胡牌牌型一覧';

  @override
  String get winningPatternsDesc => '點擊牌型名稱查看詳情與範例。';

  @override
  String get chickenHand => '雞胡';

  @override
  String get naMinOne => '不適用 (最少 1)';

  @override
  String get limitHand => '爆棚 (上限)';

  @override
  String get selectWinningHand => '選擇胡牌';

  @override
  String get maxTilesAlert => '同一張牌不能超過 4 張';

  @override
  String get maxTotalTilesAlert => '最多選擇 18 張牌';

  @override
  String get minTilesAlert => '請至少選擇 14 張牌';

  @override
  String get selectedCount => '已選：';

  @override
  String get clear => '清除';

  @override
  String get charactersTab => '萬子';

  @override
  String get dotsTab => '筒子';

  @override
  String get bambooTab => '索子';

  @override
  String get honorsTab => '字牌';

  @override
  String get invalidTileCount => '牌數錯誤。必須為 14、15、16、17 或 18 張。';

  @override
  String get winningHandThirteenOrphans => '胡牌 (十三么)！';

  @override
  String get winningHand => '胡牌！';

  @override
  String get winningHandInvalid => '無法胡牌 (需要 4 組 + 1 對眼)。';

  @override
  String get gameHistoryTitle => '對局記錄';

  @override
  String get noHistory => '沒有對局記錄';

  @override
  String gameIndex(int index) {
    return '對局 #$index';
  }

  @override
  String get dateLabel => '日期';

  @override
  String get roundsLabel => '局數';

  @override
  String get tipTitle => '提示：';

  @override
  String get splashTitle => '香港麻將計分器';

  @override
  String get splashSubtitle => '讓計分變得更簡單';

  @override
  String get tipDesc => '使用本應用程式的計分功能可自動計算番數與分數！';

  @override
  String get importantNoteTitle => '重要提示：';

  @override
  String get flowerNote => '如果您持有的花牌與座位不符 (例如：東位持有夏)，該花牌不計番數，並且失去「無花」獎勵。';

  @override
  String get dragonNote => '註：若門風與圈風相同 (例如：東圈東位)，碰出該風牌可得 2 番！';

  @override
  String get diceDealerEast => '莊家 (東)';

  @override
  String get diceSouthRight => '南 (下家)';

  @override
  String get diceWestOpposite => '西 (對家)';

  @override
  String get diceNorthLeft => '北 (上家)';

  @override
  String defaultPlayerName(int index) {
    return '玩家 $index';
  }

  @override
  String get loginTitle => '登入';

  @override
  String get createAccountTitle => '建立帳戶';

  @override
  String get emailLabel => '電子郵件';

  @override
  String get passwordLabel => '密碼';

  @override
  String get loginButton => '登入';

  @override
  String get createAccountButton => '建立帳戶';

  @override
  String get noAccountText => '沒有帳戶？建立一個';

  @override
  String get hasAccountText => '已經有帳戶？登入';

  @override
  String get emailRequired => '請輸入電子郵件';

  @override
  String get emailInvalid => '請輸入有效的電子郵件';

  @override
  String get passwordRequired => '請輸入密碼';

  @override
  String get passwordLengthError => '密碼至少需要 6 個字元';

  @override
  String get genericError => '發生未知錯誤';

  @override
  String get confirmDeleteTitle => '確認刪除';

  @override
  String confirmDeleteContent(String name) {
    return '確定要刪除群組 \"$name\" 嗎？';
  }

  @override
  String groupDeleted(String name) {
    return '群組 \"$name\" 已刪除';
  }

  @override
  String get savedGroupsTitle => '已儲存的群組';

  @override
  String get noAnySavedGroups => '尚未儲存任何群組';

  @override
  String get editGroup => '編輯群組';

  @override
  String get deleteGroup => '刪除群組';

  @override
  String get createdPrefix => '建立時間: ';

  @override
  String get playersListPrefix => '玩家: ';

  @override
  String defaultGroupName(String timestamp) {
    return '群組 $timestamp';
  }

  @override
  String get twRulesTitle => '台灣麻將規則';

  @override
  String get hkRulesTitle => '香港麻將規則';

  @override
  String get hkMode => '港式';

  @override
  String get twMode => '台式';

  @override
  String get twScoringRulesTitle => '台灣麻將計分規則';

  @override
  String get twScoringRulesDesc =>
      '台灣麻將使用『台』制計分。總金額 = 底 + (總台數 × 每台金額)。通常比例為底的五分一為每台金額 (如 \$10底 \$2一台)。';

  @override
  String get twTaiHeader => '台數';

  @override
  String get twScoreHeader => '金額';

  @override
  String get twInstantPayTitle => '即時付錢項目';

  @override
  String get twInstantPayDesc => '以下情況發生時需要立即支付，不需要等到結算。';

  @override
  String get twChaseRule => '追';

  @override
  String get twChaseDesc => '四家連續打出同一隻牌時，第一家打牌的人需支付其他三家每人一個底。';

  @override
  String get twConcealedKongPay => '暗槓即時付';

  @override
  String get twConcealedKongPayDesc =>
      '達成暗槓時，其他三家需各支付一個底。暗槓必須在完結時打開讓其他玩家知道，否則罰兩個底。';

  @override
  String get twFlowerSetPay => '花牌組合即付';

  @override
  String get twFlowerSetPayDesc => '一台草：其他三家每人給半個底。一台花：其他三家每人給一個底。拿了花之後不能再拿草。';

  @override
  String get twFalseWinPay => '詐胡';

  @override
  String get twFalseWinPayDesc => '詐胡時需支付每位玩家 \$100。莊家詐胡則繼續連莊。';

  @override
  String get twCalledPongPenalty => '叫碰不碰';

  @override
  String get twCalledPongPenaltyDesc => '喊了碰卻沒有執行，罰一個底放在台面中央，由該局胡家收取。';

  @override
  String get twPenaltiesTitle => '特殊處罰規則';

  @override
  String get twPenaltiesDesc => '關於胡牌資格或番數計算的處罰性規定。';

  @override
  String get twWinPlacementRule => '胡牌動作規範';

  @override
  String get twWinPlacementDesc => '胡牌時不可將胡的牌拍入自己的牌陣中，必須分開放一旁，否則視為胡牌無效。';

  @override
  String get twMissedWinRule => '過水（揀食胡）限制';

  @override
  String get twMissedWinDesc =>
      '同一巡內若放棄可以胡的牌，在同一個圈內其他人打出相同的牌都不能食胡。必須經過自己摸牌後才恢復胡牌權。';

  @override
  String get twKongRevealRule => '暗槓秀牌規定';

  @override
  String get twKongRevealDesc => '推牌結算時忘記顯示暗槓的牌，罰金雙倍。';

  @override
  String get twDealerMarkerRule => '莊家拉莊標記';

  @override
  String get twDealerMarkerDesc =>
      '莊家連莊時忘記在牌前放置對應數字的骰子，胡牌時不能計算連莊翻數；若莊家出沖，仍需賠付連莊翻數給胡家。';

  @override
  String get twFlowerOrderRule => '補花順序';

  @override
  String get twFlowerOrderDesc =>
      '起手補花有嚴格順序。莊家補完叫「請」，下家才可補，依此類推。最後一家補完叫「請」後莊家才能打牌。';

  @override
  String get twLaSettlementTitle => '「拉」結算規則';

  @override
  String get twLaSettlementDesc => '影響連續局數輸贏金額的累積結算方式。';

  @override
  String get twLaMultiplier => '加乘效果';

  @override
  String get twLaMultiplierDesc =>
      '若上一舖胡家在此舖又胡牌，上一舖輸錢的玩家欠款先乘以 1.5 倍，再加上此舖新輸的錢。';

  @override
  String get twLaReduction => '扣減補償';

  @override
  String get twLaReductionDesc => '若前一舖輸錢的人在此舖自摸，或前一舖的胡家在此舖出沖，輸家原本累積的債務可以扣回一半。';

  @override
  String get twLaApplied => '拉（累計結算）';

  @override
  String get twLaMultiplierApplied => '拉 ×1.5 累計';

  @override
  String get twLaReductionApplied => '拉 債務減半';

  @override
  String get twLaCarryDebt => '上舖累計欠款';

  @override
  String get twDealerBonusTitle => '莊家加成規則';

  @override
  String get twDealerBonusDesc => '莊家胡牌可獲額外台數，根據連莊次數遞增。';

  @override
  String get twDealerBonusBase => '做莊：+1 台';

  @override
  String get twDealerBonusFormula => '連莊公式：(連莊次數 × 2) + 1';

  @override
  String get twDealerBonusExample1 => '連一拉一：3 台';

  @override
  String get twDealerBonusExample2 => '連二拉二：5 台';

  @override
  String get twDealerBonusExample3 => '連五拉五：11 台';

  @override
  String get twDealerBonusResponsibility => '若別家自摸或莊家出沖，莊家也必須支付連莊台數給胡家。';

  @override
  String get twNoStackRule => '注意：類似的番數不可重複計算。例如計了「缺一門」就不能再計「無字」。';

  @override
  String get twScoringFormulaTitle => '計分公式';

  @override
  String get twScoringFormulaDesc => '總金額 = (總台數 × 每台金額) + 底';

  @override
  String get twScoringExample =>
      '範例：\$10底 \$2一台，胡出 13 台 = (13 × \$2) + \$10 = \$36';

  @override
  String get twScoringDefault => '若未聲明，通常默認為 \$10底 \$10一台';

  @override
  String get twConcealedKongRule => '暗槓';

  @override
  String get twConcealedKongDesc => '手中持有4張相同牌可宣告暗槓。';

  @override
  String get twConcealedKongExpl => '其他三家各付一底。完結時須秀出暗槓，忘記秀牌罰金加倍。';

  @override
  String get twNoHonors => '無字';

  @override
  String get twDescNoHonors => '整副牌中沒有任何字牌（風牌或箭牌）。';

  @override
  String get twExplNoHonors => '整副牌沒有風牌也沒有三元牌。1 台。';

  @override
  String get twNoHonorsNoFlowers => '無字花';

  @override
  String get twDescNoHonorsNoFlowers => '整副牌中既沒有字牌也沒有花牌。';

  @override
  String get twExplNoHonorsNoFlowers => '沒有字牌也沒有花牌。5 台。';

  @override
  String get twNoHonorsNoFlowersPingHu => '大平胡';

  @override
  String get twDescNoHonorsNoFlowersPingHu => '無字、無花，且符合平胡牌型。';

  @override
  String get twExplNoHonorsNoFlowersPingHu => '無字無花加平胡。15 台。';

  @override
  String get twChickenHand => '雞胡';

  @override
  String get twDescChickenHand => '胡牌時（不計莊前）僅得 1 番的基礎牌型。';

  @override
  String get twExplChickenHand => '最基本的胡牌。固定賠付 10 台。';

  @override
  String get twDoublePong => '對碰';

  @override
  String get twDescDoublePong => '胡牌時等待兩對中的其中一張成刻。';

  @override
  String get twExplDoublePong => '又稱「對對倒」。1 台。';

  @override
  String get twFakeSingle => '假獨 / 假碰';

  @override
  String get twDescFakeSingle => '可以胡兩頭卻選擇胡單騎或偏章。';

  @override
  String get twExplFakeSingle => '本來可以兩面聽卻偏聽單張。1 台。';

  @override
  String get twTrueSingle => '獨獨';

  @override
  String get twDescTrueSingle => '單釣一張牌或胡中洞、邊張。';

  @override
  String get twExplTrueSingle => '單釣、中洞或邊張胡牌。2 台。';

  @override
  String get twOldYoung => '老少';

  @override
  String get twDescOldYoung => '同一門牌中同時擁有「一二三」與「七八九」的順子。';

  @override
  String get twExplOldYoung => '同花色的頭尾順子（123 和 789）。2 台。';

  @override
  String get twExposedKong => '明槓';

  @override
  String get twDescExposedKong => '手中有三張相同，碰他家打出的第四張牌。';

  @override
  String get twExplExposedKong => '用別家的牌完成四張一組的槓。1 台。';

  @override
  String get twConcealedKongTai => '暗槓';

  @override
  String get twDescConcealedKongTai => '自己摸到四張相同的牌。';

  @override
  String get twExplConcealedKongTai => '四張全靠自摸。2 台。';

  @override
  String get twFlowerWin => '花上食胡';

  @override
  String get twDescFlowerWin => '摸到花牌補牌時剛好自摸。';

  @override
  String get twExplFlowerWin => '補花時摸到的牌剛好胡牌。1 台。';

  @override
  String get twKongWin => '槓上食胡';

  @override
  String get twDescKongWin => '開槓補牌時剛好自摸。';

  @override
  String get twExplKongWin => '開槓後補的牌剛好胡牌。1 台。';

  @override
  String get twRobbingKong => '搶槓食胡';

  @override
  String get twDescRobbingKong => '他家明槓的牌剛好是你胡的牌。';

  @override
  String get twExplRobbingKong => '不視為自摸，由被搶槓者出沖，不加一番。1 台。';

  @override
  String get twDoubleKongWin => '槓上槓食胡';

  @override
  String get twDescDoubleKongWin => '連續兩次開槓後補牌自摸。';

  @override
  String get twExplDoubleKongWin => '連開兩次槓後補牌自摸。30 台。';

  @override
  String get twRobbingDoubleKong => '搶槓上槓食胡';

  @override
  String get twDescRobbingDoubleKong => '在他家嘗試連續開槓時搶槓胡牌。';

  @override
  String get twExplRobbingDoubleKong => '連續槓時被搶槓胡牌。30 台。';

  @override
  String get twTwoConcealedPongs => '二暗刻';

  @override
  String get twDescTwoConcealedPongs => '手牌中有兩組自己摸到的刻子。';

  @override
  String get twExplTwoConcealedPongs => '兩組暗刻。3 台。';

  @override
  String get twThreeConcealedPongs => '三暗刻';

  @override
  String get twDescThreeConcealedPongs => '手牌中有三組自己摸到的刻子。';

  @override
  String get twExplThreeConcealedPongs => '三組暗刻。10 台。';

  @override
  String get twFourConcealedPongs => '四暗刻';

  @override
  String get twDescFourConcealedPongs => '手牌中有四組自己摸到的刻子。';

  @override
  String get twExplFourConcealedPongs => '四組暗刻。30 台。';

  @override
  String get twIdenticalSequenceTwo => '一般高';

  @override
  String get twDescIdenticalSequenceTwo => '兩個完全一樣的順子。';

  @override
  String get twExplIdenticalSequenceTwo => '同花色同數字的兩個順子。3 台。';

  @override
  String get twIdenticalSequenceThree => '三般高';

  @override
  String get twDescIdenticalSequenceThree => '三個完全一樣的順子。';

  @override
  String get twExplIdenticalSequenceThree => '三個相同順子。明 15 台 / 暗 20 台。';

  @override
  String get twIdenticalSequenceFour => '四般高';

  @override
  String get twDescIdenticalSequenceFour => '四個完全一樣的順子。';

  @override
  String get twExplIdenticalSequenceFour => '四個相同順子。30 台。';

  @override
  String get twMixedDoubleSeq => '二相逢';

  @override
  String get twDescMixedDoubleSeq => '兩個款式不同但數字一樣的順子。';

  @override
  String get twExplMixedDoubleSeq => '不同花色但數字相同的兩個順子。2 台。';

  @override
  String get twMixedTripleSeq => '三相逢';

  @override
  String get twDescMixedTripleSeq => '三個款式不同但數字一樣的順子。';

  @override
  String get twExplMixedTripleSeq => '三個花色同數字的順子。明 15 台 / 暗 20 台。';

  @override
  String get twFiveIdenticalSeq => '五同順';

  @override
  String get twDescFiveIdenticalSeq => '五個數字一樣的順子，不論款式。';

  @override
  String get twExplFiveIdenticalSeq => '五個同數字順子（包含三花色組合）。45 台。';

  @override
  String get twTwoBrothers => '二兄弟';

  @override
  String get twDescTwoBrothers => '兩款數字一樣的刻子。';

  @override
  String get twExplTwoBrothers => '不同花色但同數字的兩個刻子。3 台。';

  @override
  String get twSmallThreeBrothers => '小三兄弟';

  @override
  String get twDescSmallThreeBrothers => '兩款同數字刻子加上第三款同數字的對子做眼。';

  @override
  String get twExplSmallThreeBrothers => '兩個同數刻子加一個同數對子。10 台。';

  @override
  String get twBigThreeBrothers => '大三兄弟';

  @override
  String get twDescBigThreeBrothers => '三款數字一樣的刻子。';

  @override
  String get twExplBigThreeBrothers => '三個花色同數字的刻子。15 台。';

  @override
  String get twSmallThreeSisters => '小三姊妹';

  @override
  String get twDescSmallThreeSisters => '兩副同款式且數字相連的刻子，加上一對數字相連的眼。';

  @override
  String get twExplSmallThreeSisters => '兩組同花色連續刻子加一對連續眼。8 台。';

  @override
  String get twBigThreeSisters => '大三姊妹';

  @override
  String get twDescBigThreeSisters => '三副同款式且數字相連的刻子。';

  @override
  String get twExplBigThreeSisters => '三組同花色連續刻子（如 333-444-555）。15 台。';

  @override
  String get twFourToOne => '四歸一';

  @override
  String get twDescFourToOne => '四張相同的牌分配在順子與刻子中。';

  @override
  String get twExplFourToOne => '明 3 台 / 暗 5 台。';

  @override
  String get twFourToTwo => '四歸二';

  @override
  String get twDescFourToTwo => '四張相同的牌中，兩張做眼，另外兩張在順子裡。';

  @override
  String get twExplFourToTwo => '兩張做眼兩張在順子中。10 台。';

  @override
  String get twFourToFour => '四歸四';

  @override
  String get twDescFourToFour => '四張相同的牌都在順子裡。';

  @override
  String get twExplFourToFour => '四張同牌全在順子中。20 台。';

  @override
  String get twExposedDragon => '明龍';

  @override
  String get twDescExposedDragon => '同一款式有一至九的牌，部分是上來的。';

  @override
  String get twExplExposedDragon => '同花色 1-9 順子，含有上碰來的牌。10 台。';

  @override
  String get twExposedMixedDragon => '明雜龍';

  @override
  String get twDescExposedMixedDragon => '一至九的龍由不同款式組成，部分是上來的。';

  @override
  String get twExplExposedMixedDragon => '跨花色 1-9 順子，含有上碰來的牌。8 台。';

  @override
  String get twConcealedMixedDragon => '暗雜龍';

  @override
  String get twDescConcealedMixedDragon => '一至九的龍由不同款式組成且全在手裡。';

  @override
  String get twExplConcealedMixedDragon => '跨花色 1-9 順子，全部暗持。15 台。';

  @override
  String get twFiveGates => '五門齊';

  @override
  String get twDescFiveGates => '胡牌時包含萬、筒、索、風、箭牌五種。';

  @override
  String get twExplFiveGates => '五種牌型全齊。5 台。';

  @override
  String get twMissingOneSuit => '缺一門';

  @override
  String get twDescMissingOneSuit => '整副牌中缺少筒、索或萬其中一門。';

  @override
  String get twExplMissingOneSuit => '缺少三門中的其中一門。3 台。';

  @override
  String get twAllRevealed => '全求人';

  @override
  String get twDescAllRevealed => '全副牌皆落地（上、碰、明槓），單釣出沖胡牌。';

  @override
  String get twExplAllRevealed => '所有組合都露出，只剩單釣，出沖胡。15 台。';

  @override
  String get twHalfRevealed => '半求人';

  @override
  String get twDescHalfRevealed => '全副牌皆落地，單釣自摸胡牌。';

  @override
  String get twExplHalfRevealed => '所有組合都露出，只剩單釣，自摸胡。8 台。';

  @override
  String get twLastSevenTiles => '七只內';

  @override
  String get twDescLastSevenTiles => '在牌堆剩餘七隻牌內胡牌。';

  @override
  String get twExplLastSevenTiles => '牌牆剩餘 7 張以內時胡牌。20 台。';

  @override
  String get twLastTenTiles => '十只內';

  @override
  String get twDescLastTenTiles => '在牌堆剩餘十隻牌內胡牌。';

  @override
  String get twExplLastTenTiles => '牌牆剩餘 10 張以內時胡牌。10 台。';

  @override
  String get twSmallThreeWinds => '小三風';

  @override
  String get twDescSmallThreeWinds => '東南西北中兩組刻子與一組對子。';

  @override
  String get twExplSmallThreeWinds => '兩組風牌刻子加一組風牌對子。15 台。';

  @override
  String get twBigThreeWinds => '大三風';

  @override
  String get twDescBigThreeWinds => '東南西北中三組刻子。';

  @override
  String get twExplBigThreeWinds => '三組風牌刻子。30 台。';

  @override
  String get twSixteenNonMatching => '十六不搭';

  @override
  String get twDescSixteenNonMatching => '由特定間隔的數字牌與字牌組成，不能搭上。';

  @override
  String get twExplSixteenNonMatching => '16 張牌無法組成任何有效組合。50 台。';

  @override
  String get twOneFlowerSet => '一台花';

  @override
  String get twDescOneFlowerSet => '收集齊同一系列的四隻花牌。';

  @override
  String get twExplOneFlowerSet => '集齊春夏秋冬或梅蘭竹菊其中一套。10 台。';

  @override
  String get twTwoFlowerSets => '兩台花（花胡）';

  @override
  String get twDescTwoFlowerSets => '收集齊八隻花牌，可立刻食胡。';

  @override
  String get twExplTwoFlowerSets => '集齊全部八張花牌即可立刻胡牌。30 台。手牌不計。';

  @override
  String get twMixedTerminalsPongs => '混么';

  @override
  String get twDescMixedTerminalsPongs => '整副牌都是一、九及字牌。';

  @override
  String get twExplMixedTerminalsPongs => '全副由么九和字牌組成。30 台。';

  @override
  String get twPureTerminalsTw => '清么';

  @override
  String get twDescPureTerminalsTw => '整副牌都是一、九。';

  @override
  String get twExplPureTerminalsTw => '全副只有 1 和 9。80 台。';

  @override
  String get twMixedTerminalChows => '全帶混么';

  @override
  String get twDescMixedTerminalChows => '每一組牌都含有一、九或字牌。';

  @override
  String get twExplMixedTerminalChows => '所有組合都包含么九或字牌。10 台。';

  @override
  String get twPureTerminalChows => '全帶么';

  @override
  String get twDescPureTerminalChows => '每一組牌都含有一、九，且無字牌。';

  @override
  String get twExplPureTerminalChows => '所有組合都包含么九牌但無字牌。15 台。';

  @override
  String get twHumanWin => '人胡';

  @override
  String get twDescHumanWin => '在第一巡內，閒家胡他家出沖的牌。';

  @override
  String get twExplHumanWin => '第一巡閒家食他家出沖胡牌。80 台。';

  @override
  String get twSevenRobOne => '七搶一';

  @override
  String get twDescSevenRobOne => '拿到七隻花牌時，可胡另外一隻在別家手上的花牌。';

  @override
  String get twExplSevenRobOne => '持有七張花牌搶奪最後一張。15 台。';

  @override
  String get twHeavenlyReady => '天聽';

  @override
  String get twDescHeavenlyReady => '莊家起手即宣布聽牌（已包叮）。';

  @override
  String get twExplHeavenlyReady => '莊家起手聽牌宣告。已包含叮的 5 台。50 台。';

  @override
  String get twEarthlyReady => '地聽';

  @override
  String get twDescEarthlyReady => '閒家第一巡即宣布聽牌（已包叮）。';

  @override
  String get twExplEarthlyReady => '閒家首輪聽牌宣告。已包含叮的 5 台。25 台。';

  @override
  String get twMiguiTw => '嚦咕嚦咕';

  @override
  String get twDescMiguiTw => '八個對子，其中不能有三張一樣的碰出。';

  @override
  String get twExplMiguiTw => '八個不同對子。不可有碰出的三張同牌。40 台。';

  @override
  String get twStackRulesTitle => '不可重複計算規則';

  @override
  String get twStackRulesDesc => '部分台數不可同時計算。高等級牌型通常覆蓋低等級的相關牌型。';

  @override
  String get twStackRule1 => '五同順已包含三相逢、一般高、兩般高、三般高。';

  @override
  String get twStackRule2 => '缺一門不可與無字重複計算。';

  @override
  String get twStackRule3 => '天聽 (50) 和地聽 (25) 已包含叮 (5) 的台數。';

  @override
  String get twStackRule4 => '兩台花（花胡, 30）立刻食胡，不須計手上的牌。';

  @override
  String get twStackRule5 => '清一色 (80) 已覆蓋混一色和無字。';

  @override
  String get twStackRule6 => '搶槓食胡不視為自摸，由被搶槓者出沖。';

  @override
  String get twStackRule7 => '雞胡 (10) 僅在莊前只有 1 台時才適用。';

  @override
  String get achvTitle => '成就';

  @override
  String get achvUnlocked => '已解鎖';

  @override
  String get achvLocked => '未解鎖';

  @override
  String achvProgress(String current, String target) {
    return '$current/$target';
  }

  @override
  String achvUnlockedAt(String date) {
    return '$date 達成';
  }

  @override
  String get achvNewUnlock => '成就解鎖！';

  @override
  String get achvViewAll => '查看成就';

  @override
  String get achvTabAll => '全部';

  @override
  String get achvTabGeneral => '通用';

  @override
  String get achvTabHk => '港式';

  @override
  String get achvTabTw => '台式';

  @override
  String get achvTabMilestone => '里程碑';

  @override
  String get achvTierBronze => '銅牌';

  @override
  String get achvTierSilver => '銀牌';

  @override
  String get achvTierGold => '金牌';

  @override
  String get achvTierDiamond => '鑽石';

  @override
  String achvSummary(String unlocked, String total) {
    return '$unlocked / $total';
  }

  @override
  String get achvGenFirstGameTitle => '初出茅廬';

  @override
  String get achvGenFirstGameDesc => '完成第一局';

  @override
  String get achvGenTenGamesTitle => '十戰老兵';

  @override
  String get achvGenTenGamesDesc => '累計完成 10 局';

  @override
  String get achvGenHundredGamesTitle => '百戰將軍';

  @override
  String get achvGenHundredGamesDesc => '累計完成 100 局';

  @override
  String get achvGenFirstWinTitle => '首勝之喜';

  @override
  String get achvGenFirstWinDesc => '第一次胡牌';

  @override
  String get achvGenWinStreak3Title => '連勝達人';

  @override
  String get achvGenWinStreak3Desc => '連續贏 3 局';

  @override
  String get achvGenWinStreak5Title => '五連霸';

  @override
  String get achvGenWinStreak5Desc => '連續贏 5 局';

  @override
  String get achvGenSelfDraw10Title => '自摸達人';

  @override
  String get achvGenSelfDraw10Desc => '累計自摸 10 次';

  @override
  String get achvGenSelfDraw50Title => '自摸之王';

  @override
  String get achvGenSelfDraw50Desc => '累計自摸 50 次';

  @override
  String get achvGenDealerStreak3Title => '莊家霸主';

  @override
  String get achvGenDealerStreak3Desc => '連莊 3 次';

  @override
  String get achvGenNeverDealInTitle => '鐵壁防守';

  @override
  String get achvGenNeverDealInDesc => '一場完整對局中從未放銃';

  @override
  String get achvGenComebackTitle => '大逆轉';

  @override
  String get achvGenComebackDesc => '最後一局從末位逆轉為首位';

  @override
  String get achvHkFirstWinTitle => '港式初體驗';

  @override
  String get achvHkFirstWinDesc => '在港式麻將中首次胡牌';

  @override
  String get achvHkFan3Title => '三番起步';

  @override
  String get achvHkFan3Desc => '以 3 番或以上胡牌';

  @override
  String get achvHkFullFlushTitle => '清一色達人';

  @override
  String get achvHkFullFlushDesc => '胡出清一色';

  @override
  String get achvHkAllPongs5Title => '碰碰胡愛好者';

  @override
  String get achvHkAllPongs5Desc => '累計胡出對對胡 5 次';

  @override
  String get achvHkBigThreeDragonsTitle => '大三元';

  @override
  String get achvHkBigThreeDragonsDesc => '胡出大三元';

  @override
  String get achvHkBigFourWindsTitle => '大四喜';

  @override
  String get achvHkBigFourWindsDesc => '胡出大四喜';

  @override
  String get achvHkThirteenOrphansTitle => '十三么';

  @override
  String get achvHkThirteenOrphansDesc => '胡出十三么';

  @override
  String get achvHkNineGatesTitle => '九子連環';

  @override
  String get achvHkNineGatesDesc => '胡出九子連環';

  @override
  String get achvHkConcealedHand10Title => '門清高手';

  @override
  String get achvHkConcealedHand10Desc => '累計門清胡牌 10 次';

  @override
  String get achvHkLastTileWinTitle => '海底撈月';

  @override
  String get achvHkLastTileWinDesc => '以海底撈月胡牌';

  @override
  String get achvHkRobbingKongTitle => '搶槓食胡';

  @override
  String get achvHkRobbingKongDesc => '搶槓胡牌';

  @override
  String get achvHkMaxFanTitle => '爆棚大師';

  @override
  String get achvHkMaxFanDesc => '達成最高番數上限';

  @override
  String get achvTwFirstWinTitle => '台灣入門';

  @override
  String get achvTwFirstWinDesc => '在台式麻將中首次胡牌';

  @override
  String get achvTwTai10Title => '十台達成';

  @override
  String get achvTwTai10Desc => '胡出 10 台或以上';

  @override
  String get achvTwTai30Title => '三十台豪華';

  @override
  String get achvTwTai30Desc => '胡出 30 台或以上';

  @override
  String get achvTwTai80Title => '八十台傳說';

  @override
  String get achvTwTai80Desc => '胡出 80 台或以上';

  @override
  String get achvTwCommonHand10Title => '平胡專家';

  @override
  String get achvTwCommonHand10Desc => '累計胡出平胡 10 次';

  @override
  String get achvTwConcealedSelfDrawn5Title => '門清自摸王';

  @override
  String get achvTwConcealedSelfDrawn5Desc => '累計門清自摸 5 次';

  @override
  String get achvTwDealerStreak5Title => '拉莊達人';

  @override
  String get achvTwDealerStreak5Desc => '連莊 5 次或以上';

  @override
  String get achvTwKongWinTitle => '槓上開花';

  @override
  String get achvTwKongWinDesc => '槓上食胡';

  @override
  String get achvTwFlowerWinTitle => '花胡奇蹟';

  @override
  String get achvTwFlowerWinDesc => '以花胡（兩台花）胡牌';

  @override
  String get achvTwSevenRobOneTitle => '七搶一壯舉';

  @override
  String get achvTwSevenRobOneDesc => '七搶一';

  @override
  String get achvTwHeavenlyListenTitle => '天聽宣告';

  @override
  String get achvTwHeavenlyListenDesc => '達成天聽';

  @override
  String get achvTwChickenHand10Title => '雞胡之王';

  @override
  String get achvTwChickenHand10Desc => '累計雞胡 10 次';

  @override
  String get achvTwLikulikuTitle => '嚦咕嚦咕';

  @override
  String get achvTwLikulikuDesc => '胡出嚦咕嚦咕';

  @override
  String get achvMsWins100Title => '百勝達成';

  @override
  String get achvMsWins100Desc => '累計贏 100 局';

  @override
  String get achvMsWins500Title => '五百勝達成';

  @override
  String get achvMsWins500Desc => '累計贏 500 局';

  @override
  String get achvMsScore10000Title => '萬分大師';

  @override
  String get achvMsScore10000Desc => '累計總得分超過 10,000';

  @override
  String get achvMsScore100000Title => '十萬富翁';

  @override
  String get achvMsScore100000Desc => '累計總得分超過 100,000';

  @override
  String get achvMsDualModeTitle => '雙棲玩家';

  @override
  String get achvMsDualModeDesc => '在港式和台式各打過 10 局以上';

  @override
  String get continueLastGame => '繼續遊戲';

  @override
  String get greetingMorning => '早安！準備好打一局了嗎？';

  @override
  String get greetingAfternoon => '午安！來打麻將吧？';

  @override
  String get greetingEvening => '晚安！正是打麻將的好時候。';

  @override
  String get quickStart => '快速開局';

  @override
  String get hkQuickStart => '港式\n麻將';

  @override
  String get twQuickStart => '台式\n麻將';

  @override
  String get dailyTipLabel => '💡 每日小知識：';

  @override
  String get tipDayTitle1 => '雞糊';

  @override
  String get tipDayContent1 => '港式麻將中「雞糊」是指 0 番胡牠——在設有起糊番數的規則下通常不允許胡牠。';

  @override
  String get tipDayTitle2 => '花牌與季牌';

  @override
  String get tipDayContent2 => '台式麻將每人 16 張牌，花牌和季牌是額外的獎勵牌，摘到即自動加番。';

  @override
  String get tipDayTitle3 => '對對糊';

  @override
  String get tipDayContent3 => '全部由碰/槓組成（無吃）的牌型稱為對對糊，港式規則中值 3 番。';

  @override
  String get tipDayTitle4 => '門前清';

  @override
  String get tipDayContent4 => '沒有任何明牌即胡牠稱為門前清，港式值 1 番，台式更高。';

  @override
  String get tipDayTitle5 => '莊家優勢';

  @override
  String get tipDayContent5 => '莊家在許多規則中可以收付雙倍。莊家胡牠可以繼續連莊！';

  @override
  String get tipDayTitle6 => '混一色';

  @override
  String get tipDayContent6 => '混一色使用一種花色加字牌，是最常見的高分牌型之一，值 3 番。';

  @override
  String get tipDayTitle7 => '清一色';

  @override
  String get tipDayContent7 => '清一色只用一種花色且無字牌，港式值 7 番。難以隱藏！';

  @override
  String get tipDayTitle8 => '自摸加番';

  @override
  String get tipDayContent8 => '自摸胡牠在大多數規則中可額外加番，且其他三家都要付款。';

  @override
  String get tipDayTitle9 => '十三么';

  @override
  String get tipDayContent9 => '十三么需要每種幺九牌和字牌各一張加一張重複——是滿貫牌型！';

  @override
  String get tipDayTitle10 => '拉（La）規則';

  @override
  String get tipDayContent10 => '台式麻將中，拉規則會將前一局的欠款乘以 1.5 倍，當同一玩家連續胡牠時生效。';
}
