import '../services/settings_service.dart';

class AppLocalizations {
  static String get _language => SettingsService.instance.language;
  static bool get _isZh => _language == 'Traditional Chinese';

  // App Title
  static String get appTitle => _isZh ? '麻將計分器' : 'Mahjong Score Calculator';
  
  // Home Screen
  static String get homeTitle => _isZh ? '麻將計分器' : 'Mahjong Calculator';
  static String get welcomeBack => _isZh ? '歡迎回來!' : 'Welcome Back!';
  static String get newGroup => _isZh ? '新群組' : 'New Group';
  static String get history => _isZh ? '歷史紀錄' : 'History';
  static String get historyComingSoon => _isZh ? '歷史紀錄功能即將推出...' : 'History feature coming soon...';
  static String get testFirebase => _isZh ? '測試 Firebase' : 'Test Firebase';
  static String get firebaseSuccess => _isZh ? 'Firebase 連線成功: ' : 'Firebase connected: ';
  static String get firebaseFailed => _isZh ? 'Firebase 連線失敗: ' : 'Firebase failed: ';
  static String get savedGroups => _isZh ? '已儲存的群組' : 'Saved Player Groups';
  static String get viewAll => _isZh ? '檢視全部' : 'View All';
  static String get noSavedGroups => _isZh ? '沒有已儲存的群組' : 'No saved player groups';
  static String get createFirstGroupHint => _isZh ? '建立您的第一個群組以開始使用' : 'Create your first group to get started'; // Added
  static String get createGroup => _isZh ? '建立群組' : 'Create Player Group';
  static String get players => _isZh ? '名玩家' : 'players';
  static String get createdAt => _isZh ? '建立於: ' : 'Created: ';
  static String get edit => _isZh ? '編輯' : 'Edit';
  static String get start => _isZh ? '開始' : 'Start';
  static String get allGroups => _isZh ? '所有群組' : 'All Player Groups';
  static String get editGroupComingSoon => _isZh ? '編輯群組功能即將推出...' : 'Edit group feature coming soon...';
  static String get scoreUpdated => _isZh ? '群組分數已更新: ' : 'Score updated for group: ';
  
  // Player Setup Screen
  static String get playerSetupTitle => _isZh ? '玩家設定' : 'Player Setup';
  static String get groupName => _isZh ? '群組名稱' : 'Group Name';
  static String get groupNameHint => _isZh ? '輸入群組名稱' : 'Enter group name';
  static String get groupNameError => _isZh ? '請輸入群組名稱' : 'Please enter a group name';
  static String get playerName => _isZh ? '玩家名稱' : 'Player Name';
  static String get playerNameHint => _isZh ? '輸入玩家名稱' : 'Enter player name';
  static String get addPlayer => _isZh ? '新增玩家' : 'Add Player';
  static String get minimumPlayers => _isZh ? '至少需要 2 名玩家' : 'At least 2 players required';
  static String get duplicatePlayer => _isZh ? '玩家已存在' : 'Player already exists';
  static String get saveGroup => _isZh ? '儲存群組' : 'Save Group';
  static String get saveAndPlay => _isZh ? '儲存並開始' : 'Save & Play';
  static String get cancel => _isZh ? '取消' : 'Cancel';
  static String get remove => _isZh ? '移除' : 'Remove';
  static String get playerList => _isZh ? '玩家列表' : 'Player List';
  static String get groupSaved => _isZh ? '群組儲存成功!' : 'Group saved successfully!';
  static String get groupSaveFailed => _isZh ? '儲存群組失敗' : 'Failed to save group';
  static String get minFan => _isZh ? '最少番數' : 'Min Fan';
  static String get maxFan => _isZh ? '最大番數' : 'Max Fan';
  static String get noLimit => _isZh ? '無上限' : 'No Limit';
  static String get fanLimitSettings => _isZh ? '番數限制設定' : 'Fan Range Settings';
  
  // Score Recording Screen
  static String get scoreRecording => _isZh ? '計分板' : 'Score Recording';
  static String get round => _isZh ? '局數' : 'Round';
  static String get of => _isZh ? '/' : 'of';
  static String get dealer => _isZh ? '莊家' : 'Dealer';
  static String get calculateScore => _isZh ? '計算分數' : 'Calculate Score';
  static String get endGame => _isZh ? '結束遊戲' : 'End Game';
  static String get gameResults => _isZh ? '遊戲結果' : 'Game Results';
  static String get finalScores => _isZh ? '最終分數' : 'Final Scores';
  static String get winner => _isZh ? '贏家' : 'Winner';
  static String get close => _isZh ? '關閉' : 'Close';
  static String get nextRound => _isZh ? '下一局' : 'Next Round';
  static String get stats => _isZh ? '統計' : 'Stats';
  static String get roundsPlayed => _isZh ? '已進行局數' : 'Rounds Played';
  static String get selfDrawn => _isZh ? '自摸' : 'Self-Drawn';
  static String get winningRate => _isZh ? '勝率' : 'Winning Rate';

  // Score Calculation Screen  
  static String get scoreCalculation => _isZh ? '分數計算' : 'Score Calculation';
  static String get enterScores => _isZh ? '輸入分數' : 'Enter Scores';
  static String get specialWinningCondition => _isZh ? '特殊牌型' : 'Special Winning Condition'; // Added 
  static String currentScore(int score) => _isZh ? '(目前: $score 分)' : '(Current: $score pts)'; // Added
  static String totalWin(int score) => _isZh ? '(總計: $score)' : '(Total: $score)';
  static String get submit => _isZh ? '送出' : 'Submit';
  static String get reset => _isZh ? '重置' : 'Reset';
  static String get totalMustBeZero => _isZh ? '總和必須為零' : 'Total must be zero';
  static String get confirmSubmit => _isZh ? '確認非零總和?' : 'Confirm non-zero total?';
  static String get totalIs => _isZh ? '總和為 ' : 'Total is ';
  static String get continueAnyway => _isZh ? '強制繼續' : 'Continue Anyway';
  static String get win => _isZh ? '胡牌' : 'Win';
  static String get selfDraw => _isZh ? '自摸' : 'Self-Draw';
  static String get discard => _isZh ? '出衝' : 'Discard';
  static String get winningPlayer => _isZh ? '胡牌玩家' : 'Winning Player';
  static String get discardPlayer => _isZh ? '放槍玩家' : 'Discard Player';
  static String get roundWind => _isZh ? '圈風' : 'Round Wind';
  static String get seatWind => _isZh ? '門風' : 'Seat Wind';
  static String get flowers => _isZh ? '花牌' : 'Flowers';
  static String get selectFlowers => _isZh ? '選擇花牌' : 'Select Flowers';
  static String get handPreviewArea => _isZh ? '手牌預覽區域' : 'Hand Preview Area';
  static String get scanTiles => _isZh ? '掃描牌型' : 'Scan Tiles';
  static String get selectHand => _isZh ? '選擇牌型' : 'Select Hand';
  static String get analyzingTiles => _isZh ? '正在分析牌型...' : 'Analyzing tiles...';
  static String get takePhotoHint => _isZh ? '拍照或點擊以選擇牌型' : 'Take photo or click to select hand pattern';
  static String get item => _isZh ? '項目' : 'Item';
  static String get value => _isZh ? '數值' : 'Value';
  static String get totalFan => _isZh ? '總番數' : 'Total Fan';
  static String get totalScore => _isZh ? '總分數' : 'Total Score';
  static String get fanTitle => _isZh ? '番數' : 'Fan';
  static String get limit => _isZh ? '爆棚' : 'Limit';
  static String get perPerson => _isZh ? ' / 人' : ' / person';
  static String get points => _isZh ? '分' : 'points';
  
  // Rules
  static String get ruleSelfDraw => _isZh ? '自摸' : 'Self-Draw';
  static String get ruleNoFlowers => _isZh ? '無花' : 'No Flowers';
  static String get ruleFlowerPlatform14 => _isZh ? '花台 (1-4)' : 'Flower Platform (1-4)';
  static String get ruleFlowerPlatform58 => _isZh ? '花台 (5-8)' : 'Flower Platform (5-8)';
  static String get ruleOwnFlower => _isZh ? '正花' : 'Own Flower';
  static String get ruleOwnSeason => _isZh ? '正花' : 'Own Season';
  static String get rulePongOfWhite => _isZh ? '白板刻' : 'Pong of White Dragon';
  static String get rulePongOfGreen => _isZh ? '發財刻' : 'Pong of Green Dragon';
  static String get rulePongOfRed => _isZh ? '紅中刻' : 'Pong of Red Dragon';
  static String get ruleRoundWind => _isZh ? '圈風' : 'Round Wind';
  static String get ruleSeatWind => _isZh ? '門風' : 'Seat Wind';
  static String get ruleAllChows => _isZh ? '平胡' : 'All Chows';
  static String get ruleAllPongs => _isZh ? '對對胡' : 'All Pongs';
  static String get ruleMixedOneSuit => _isZh ? '混一色' : 'Mixed One Suit';
  static String get rulePureOneSuit => _isZh ? '清一色' : 'Pure One Suit';
  static String get ruleSmallThreeDragons => _isZh ? '小三元' : 'Small Three Dragons';
  static String get ruleBigThreeDragons => _isZh ? '大三元' : 'Big Three Dragons';
  static String get ruleSmallFourWinds => _isZh ? '小四喜' : 'Small Four Winds';
  static String get ruleBigFourWinds => _isZh ? '大四喜' : 'Big Four Winds';
  static String get ruleThirteenOrphans => _isZh ? '十三么' : 'Thirteen Orphans';
  static String get ruleEightImmortals => _isZh ? '八仙過海' : 'Eight Immortals';
  static String get ruleFlowerHand => _isZh ? '花胡' : 'Flower Hand';
  static String get ruleHiddenTreasure => _isZh ? '坎坎胡' : 'Hidden Treasure';
  static String get ruleAllHonors => _isZh ? '字一色' : 'All Honors';
  static String get ruleNineGates => _isZh ? '九子連環' : 'Nine Gates';
  static String get ruleEighteenArhats => _isZh ? '十八羅漢' : 'Eighteen Arhats';
  static String get ruleHeavenlyHand => _isZh ? '天胡' : 'Heavenly Hand';
  static String get ruleEarthlyHand => _isZh ? '地胡' : 'Earthly Hand';
  static String get ruleKong => _isZh ? '槓' : 'Kong';
  
  static String get ruleNone => _isZh ? '無' : 'None';
  
  // Winds
  static String get east => _isZh ? '東' : 'East';
  static String get south => _isZh ? '南' : 'South';
  static String get west => _isZh ? '西' : 'West';
  static String get north => _isZh ? '北' : 'North';

  // Common
  static String get home => _isZh ? '首頁' : 'Home';   
  static String get rules => _isZh ? '規則' : 'Rules';
  static String get gameRules => _isZh ? '遊戲規則' : 'Game Rules';
  static String get settings => _isZh ? '設定' : 'Settings';
  static String get confirm => _isZh ? '確認' : 'Confirm';
  static String get delete => _isZh ? '刪除' : 'Delete';
  static String get save => _isZh ? '儲存' : 'Save';
  static String get yes => _isZh ? '是' : 'Yes';
  static String get no => _isZh ? '否' : 'No';
  static String get ok => _isZh ? '確定' : 'OK';
  static String get error => _isZh ? '錯誤' : 'Error';
  static String get success => _isZh ? '成功' : 'Success';
  static String get loading => _isZh ? '載入中...' : 'Loading...';
  static String get retry => _isZh ? '重試' : 'Retry';
  
  // Settings
  static String get language => _isZh ? '語言' : 'Language';
  static String get theme => _isZh ? '主題' : 'Theme';
  static String get logout => _isZh ? '登出' : 'Logout';
  static String get confirmLogout => _isZh ? '確定要登出嗎?' : 'Are you sure you want to logout?';
  
  static String get langEnglish => _isZh ? '英文' : 'English';
  static String get langTraditionalChinese => _isZh ? '繁體中文' : 'Traditional Chinese';
  
  static String get lightMode => _isZh ? '淺色模式' : 'Light Mode';
  static String get darkMode => _isZh ? '深色模式' : 'Dark Mode';
  static String get themeMode => _isZh ? '主題模式' : 'Theme Mode';
  
  static String get about => _isZh ? '關於' : 'About';
  static String get aboutDesc => _isZh ? '簡單易用的麻將計分器。' : 'A simple and easy-to-use Mahjong score calculator.';
  static String get copyright => _isZh ? '© 2025 麻將計分器團隊' : '© 2025 Mahjong Calculator Team';
  
  static String get feedback => _isZh ? '意見回饋' : 'Feedback';
  static String get feedbackContent => _isZh ? '請將您的意見發送至 support@example.com' : 'Please send your feedback to support@example.com';
  
  static String get privacyPolicy => _isZh ? '隱私權政策' : 'Privacy Policy';
  static String get privacyPolicyContent => _isZh 
      ? '我們尊重您的隱私。本應用程式將您的遊戲數據儲存在本地及 Firebase 用於同步。我們不會與第三方分享您的個人數據。' 
      : 'We respect your privacy. This app stores your game data locally and on Firebase for synchronization purposes. We do not share your personal data with third parties.';

  // Dialogs & Messages
  static String get confirmDeleteGroup => _isZh ? '確定要刪除此群組嗎?' : 'Are you sure you want to delete this group?';
  static String get gameInProgressTitle => _isZh ? '開始新遊戲?' : 'Start New Game?';
  static String get gameInProgressContent => _isZh 
      ? '有未完成的遊戲。開始新遊戲將會把上一場視為結束並儲存紀錄。' 
      : 'There is a game in progress. Starting a new game will assume the previous one is finished and stats will be saved.';
  static String get startNewGame => _isZh ? '開始新遊戲' : 'Start New Game';
  static String get resumeGame => _isZh ? '繼續遊戲' : 'Resume Game';
  static String get backToGame => _isZh ? '回到遊戲' : 'Back to Game';
  static String get playerStatsTitle => _isZh ? '玩家數據' : 'Player Statistics';
  static String get recentGroups => _isZh ? '最近群組' : 'Recent Groups';
  static String get editPlayers => _isZh ? '編輯玩家' : 'Edit Players';
  static String get setupPlayers => _isZh ? '設定玩家' : 'Setup Players';
  static String get enterGroupNameHint => _isZh ? '例如: 週末麻將團' : 'e.g., Weekend Mahjong Group';
  
  static String get confirmDelete => _isZh ? '確認刪除' : 'Confirm Delete';
  static String get deleteGroupWarning => _isZh ? '確定要刪除此群組嗎? 此動作無法復原。' : 'Are you sure you want to delete this player group? This action cannot be undone.';
  
  static String editPlayerTitle(int index) => _isZh ? '編輯玩家 $index' : 'Edit Player $index';

  static String get totalGamesMatches => _isZh ? '總局數 (場):' : 'Total Games (Matches):';

  // Rule Descriptions & Explanations
  static String get descAllChows => _isZh ? '只有順子, 無刻子' : 'Hand with only Chows, no Pongs.';
  static String get explAllChows => _isZh ? '全副牌由順子和一對組成，沒刻子或槓' : 'Hand composed entirely of Chows (sequences) and a pair. No Pongs or Kongs.';
  
  static String get descNoFlowers => _isZh ? '沒有花牌' : 'No Flower tiles.';
  static String get explNoFlowers => _isZh ? '沒有持有任何花牌而胡牌' : 'Winning without any Flower tiles.';
  
  static String get descOwnSeason => _isZh ? '花牌對應門風' : 'Flower tile matches your seat wind.';
  static String get explOwnSeason => _isZh ? '花牌號碼對應你的座位 (1東 2南 3西 4北)' : 'The Flower tile number corresponds to your seat wind (1=East, 2=South, 3=West, 4=North).';
  
  static String get descSelfDraw => _isZh ? '自摸胡牌' : 'Winning by self-drawn tile.';
  static String get explSelfDraw => _isZh ? '自己摸到獲勝的牌' : 'Drawing the winning tile yourself adds 1 fan.';

  static String get ruleMenQianQing => _isZh ? '門前清' : 'Men Qian Qing';
  static String get descMenQianQing => _isZh ? '沒有鳴牌' : 'Winning without melding exposed tiles.';
  static String get explMenQianQing => _isZh ? '整副牌皆為門前清（沒有吃、碰、明槓）。' : 'Concealed hand. No exposed melds before winning.';

  static String get ruleDragonWindPong => _isZh ? '番子' : 'Dragon/Wind Pong';
  static String get descDragonWindPong => _isZh ? '三元牌或風牌刻子' : 'Pong of Dragons or Seat/Round Wind.';
  static String get explDragonWindPong => _isZh ? '擁有中、發、白或圈風、門風的刻子/槓。' : 'A Pong/Kong of Dragons or Seat/Round Wind.';

  static String get ruleRobbingKong => _isZh ? '搶槓' : 'Robbing the Kong';
  static String get descRobbingKong => _isZh ? '胡別人加槓的牌' : 'Winning off a Kong.';
  static String get explRobbingKong => _isZh ? '當別人進行加槓（小明槓）時，那張牌剛好是你胡的牌。' : 'Winning when another player declares a Kong with a tile you need.';

  static String get ruleHaidilao => _isZh ? '海底撈月' : 'Haidilao';
  static String get descHaidilao => _isZh ? '自摸最後一張牌' : 'Winning on the last tile.';
  static String get explHaidilao => _isZh ? '摸到牌牆的最後一張牌而胡牌。' : 'Winning by drawing the very last tile of the wall.';

  static String get ruleKongOnKong => _isZh ? '槓上槓/花上自摸' : 'Kong on Kong/Flower';
  static String get descKongOnKong => _isZh ? '槓牌或補花後自摸' : 'Winning after a Kong or Flower replacement.';
  static String get explKongOnKong => _isZh ? '槓牌或補花後，摸到的補牌胡牌。' : 'Drawing the winning tile from the dead wall after declaring a Kong or getting a Flower.';
  
  static String get ruleFlowerPlatform => _isZh ? '一台花' : 'Flower Platform';
  static String get descFlowerPlatform => _isZh ? '集齊一種花色(1-4)' : 'Complete set of Flowers.';
  static String get explFlowerPlatform => _isZh ? '集齊一副完整的花牌(春夏秋冬 或 梅蘭菊竹)。' : 'Collecting a full set of numbered Flowers (1-4) or Seasons (1-4).';

  static String get ruleSevenFlowers => _isZh ? '七隻花' : 'Flower Hand (7 Flowers)';
  static String get descSevenFlowers => _isZh ? '集齊七張花' : 'Seven Flowers.';
  static String get explSevenFlowers => _isZh ? '拿到七張花牌可立即胡牌(計3番)。' : 'Collecting 7 Flower tiles allows for an immediate win.';
  
  static String get descAllPongs => _isZh ? '全為刻子/對子' : '4 Pongs/Kongs & Pair.';
  static String get explAllPongs => _isZh ? '全副牌由刻子(或槓)和一對將眼組成。' : 'Hand composed entirely of Pongs (triplets) or Kongs and a pair.';

  static String get descMixedOneSuit => _isZh ? '單一花色 + 字牌' : 'One suit & Honors.';
  static String get explMixedOneSuit => _isZh ? '由同一花色牌及字牌組成。' : 'Hand composed of one suit and Honor tiles.';
  
  static String get ruleMixedTerminals => _isZh ? '混么九' : 'Mixed Terminals';
  static String get descMixedTerminals => _isZh ? '么九 + 字牌刻子' : 'Terminals & Honors.';
  static String get explMixedTerminals => _isZh ? '全副牌由么九牌(1,9)及字牌的刻子/將眼組成。' : 'All Pongs/Kongs composed of Terminals (1/9) and Honor tiles.';

  static String get descSmallThreeDragons => _isZh ? '兩副三元刻 + 一對眼' : '2 Dragon Pongs + Pair.';
  static String get explSmallThreeDragons => _isZh ? '兩副三元牌刻子及一副三元牌將眼。' : 'Two Pongs/Kongs of Dragons and a pair of the third Dragon.';
  
  static String get descSmallFourWinds => _isZh ? '三副風刻 + 一對眼' : '3 Wind Pongs + Pair.';
  static String get explSmallFourWinds => _isZh ? '三副風牌刻子及一副風牌將眼。' : 'Three Pongs/Kongs of Winds and a pair of the fourth Wind.';
  
  static String get descThirteenOrphans => _isZh ? '十三種么九字牌' : '13 Unique Terminals.';
  static String get explThirteenOrphans => _isZh ? '集齊所有么九牌及字牌各一張，加其中一張做眼。' : 'One of each Terminal and Honor tile + one pair.';
  
  static String get ruleBlessingMan => _isZh ? '人胡' : 'Blessing of Man';
  static String get ruleBlessingOfMan => _isZh ? '人胡' : 'Blessing of Man';
  static String get descBlessingMan => _isZh ? '閒家第一輪自摸' : 'Non-Dealer 1st Turn Win.';
  static String get explBlessingMan => _isZh ? '閒家第一輪自摸。' : 'As non-dealer, you win on your first turn with a self-pick.';
  
  static String get descEarthlyHand => _isZh ? '閒家食莊家首打' : 'Win on Dealer\'s Discard.';
  static String get explEarthlyHand => _isZh ? '閒家食和莊家打出的第一張牌。' : 'As non-dealer, you win using the dealer\'s first discard.';
  
  static String get descHeavenlyHand => _isZh ? '莊家起手即胡' : 'Dealer Initial Win.';
  static String get explHeavenlyHand => _isZh ? '莊家起手配牌即胡牌。' : 'As dealer, your beginning hand wins.';
  
  static String get descEighteenArhats => _isZh ? '四個槓 (18張)' : '4 Kongs + Pair.';
  static String get explEighteenArhats => _isZh ? '四個槓(共18張牌)胡牌。' : 'Winning with four Kongs (18 tiles total).';
  
  static String get descBigFourWinds => _isZh ? '四副風刻' : '4 Wind Pongs.';
  static String get explBigFourWinds => _isZh ? '四副風牌刻子/槓。' : 'Four Pongs/Kongs of East, South, West, and North Winds.';
  
  static String get descEightImmortals => _isZh ? '集齊八張花牌' : 'All 8 Flowers.';
  static String get explEightImmortals => _isZh ? '拿到八張花牌可立即胡牌(計8番)。' : 'Collecting all 8 Flower tiles allows for an immediate win.';

  static String get descHiddenTreasure => _isZh ? '四副暗刻 (門前清)' : '4 Concealed Pongs.';
  static String get explHiddenTreasure => _isZh ? '四副刻子皆為自摸/門前清(四暗刻)。' : 'Four Pongs/Kongs that were all self-drawn (concealed).';

  static String get ruleDoubleKong => _isZh ? '槓上槓' : 'Double Kong Replacement';
  static String get descDoubleKong => _isZh ? '連續兩次槓後胡' : 'Win on 2nd Kong.';
  static String get explDoubleKong => _isZh ? '連開兩次槓後，補充得來的牌胡牌。' : 'If you call a kong, call a second kong using the replacement tile, then win on the second replacement.';

  static String get descAllHonors => _isZh ? '全副字牌' : 'All Honors.';
  static String get explAllHonors => _isZh ? '全副牌由字牌組成。' : 'Hand composed entirely of Honor tiles.';

  static String get rulePureTerminals => _isZh ? '清么九' : 'Pure Terminals';
  static String get descPureTerminals => _isZh ? '全副么九刻子' : 'All 1s and 9s.';
  static String get explPureTerminals => _isZh ? '全副牌由么九牌(1,9)的刻子/將眼組成。' : 'All Pongs/Kongs composed entirely of Terminal tiles (1 and 9).';

  static String get descNineGates => _isZh ? '同花色 111...999' : '1-9 of one suit hand.';
  static String get explNineGates => _isZh ? '門前清同一花色：1112345678999 再加任何一張同花色的牌。' : 'Concealed hand of one suit: 1112345678999 + any tile of the same suit.';
  
  static String get descPureOneSuit => _isZh ? '單一花色' : 'All one suit.';
  static String get explPureOneSuit => _isZh ? '由同一花色牌組成。' : 'Hand composed entirely of tiles from a single suit.';
  
  static String get descBigThreeDragons => _isZh ? '三副三元刻' : '3 Dragon Pongs.';
  static String get explBigThreeDragons => _isZh ? '三副三元牌刻子/槓。' : 'Three Pongs/Kongs of Red, Green, and White Dragons.';
  static String get totalHandsPlayed => _isZh ? '總手数:' : 'Total Hands Played:';
  static String get noResultRate => _isZh ? '流局率:' : 'No Result Rate:';
  static String get statsWinRate => _isZh ? '勝率' : 'Win Rate';
  static String get statsSelfDraw => _isZh ? '自摸' : 'Self-Draw';
  static String get statsRon => _isZh ? '食糊' : 'Discard';
  static String get statsDealIn => _isZh ? '放銃' : 'Deal-in';
  static String get selectDealer => _isZh ? '選擇莊家' : 'Select Dealer';
  static String get startGame => _isZh ? '開始遊戲' : 'Start Game';
  
  static String get gameOver => _isZh ? '遊戲結束' : 'Game Over';
  static String get totalWindRounds => _isZh ? '總圈數:' : 'Total Wind Rounds:';
  static String get totalRoundsPlayed => _isZh ? '總局數:' : 'Total Games Played:';

  static String get totalGames => _isZh ? '總局數' : 'Total Games';
  
  static String get finishGame => _isZh ? '結束遊戲' : 'Finish Game';
  static String get changePosition => _isZh ? '交換位置' : 'Change Position';
  static String swapPositionsContent(String p1, String p2) => _isZh ? '交換 $p1 和 $p2 的位置?' : 'Swap positions of $p1 and $p2?';
  static String get swap => _isZh ? '交換' : 'Swap';
  static String get resetGameState => _isZh ? '重置遊戲狀態?' : 'Reset Game State?';
  static String get resetDealer => _isZh ? '重置莊家位置' : 'Reset Dealer Position';
  static String get resetDealerSubtitle => _isZh ? '重新選擇莊家' : 'Choose a new dealer';
  static String get resetWind => _isZh ? '重置圈風' : 'Reset Wind Round';
  static String get resetWindSubtitle => _isZh ? '重置為東一局' : 'Reset to East 1';
  static String get cancelReset => _isZh ? '取消重置' : 'Cancel Reset';
  static String get apply => _isZh ? '套用' : 'Apply';
  static String get currentGameStats => _isZh ? '目前戰況' : 'Current Game Stats';
  static String get noRoundsPlayed => _isZh ? '尚未進行任何局數。' : 'No rounds played yet.';
  
  static String get mahjongScoringTitle => _isZh ? '麻將計分' : 'Mahjong Scoring';
  
  static String get windEast => _isZh ? '東' : 'East';
  static String get windSouth => _isZh ? '南' : 'South';
  static String get windWest => _isZh ? '西' : 'West';
  static String get windNorth => _isZh ? '北' : 'North';
  static String roundInfo(String wind, int game) => _isZh ? '$wind風圈 - 第 $game 局' : '$wind Round - Game $game';
  
  static String get calculate => _isZh ? '計算' : 'Calculate';
  static String get noResult => _isZh ? '流局' : 'No Result';

  static String gameCount(int count) => _isZh ? '第 $count 局' : 'Game $count';
  static String get mahjong => _isZh ? '麻將' : 'Mahjong';

  static String get windCircleSuffix => _isZh ? '風圈' : ' Round';
  static String get tooltipStats => _isZh ? '遊戲統計' : 'Game Statistics';
  static String get tooltipRules => _isZh ? '規則參考' : 'Rules Reference';
  static String get tooltipHome => _isZh ? '回到首頁' : 'Back to Home';


  // Messages
  static String get loadFailed => _isZh ? '載入群組失敗: ' : 'Failed to load player groups: ';
  static String get saveFailed => _isZh ? '儲存失敗: ' : 'Failed to save: ';
  static String get deleteFailed => _isZh ? '刪除失敗: ' : 'Failed to delete: ';
  static String get noInternet => _isZh ? '無網路連線' : 'No internet connection';
  static String get tryAgain => _isZh ? '請再試一次' : 'Please try again';
  static String get selectLanguage => _isZh ? '選擇語言' : 'Select Language';
  static String get moreLanguagesComingSoon => _isZh ? '更多語言即將推出...' : 'More languages coming soon...';
  
  static String get rulesAndTutorial => _isZh ? '規則與教學' : 'Rules & Tutorial';
  static String get rulesReference => _isZh ? '規則參考' : 'Rules Reference';
  static String get mahjongTutorial => _isZh ? '麻將教學' : 'Mahjong Tutorial';
  static String get allFan => _isZh ? '全部' : 'All';
  static String get searchRules => _isZh ? '搜尋規則' : 'Search Rules';

  static String get tutorialWelcome => _isZh ? '歡迎' : 'Welcome';
  static String get tutorialTiles => _isZh ? '牌型' : 'Tiles';
  static String get tutorialRules => _isZh ? '規則' : 'Rules';
  static String get rulesTitle => _isZh ? '規則' : 'Rules';
  static String get tutorialScore => _isZh ? '計分' : 'Score';
  static String get previous => _isZh ? '上一頁' : 'Previous';
  static String get next => _isZh ? '下一頁' : 'Next';
  static String get viewExample => _isZh ? '查看範例' : 'View Example';
  static String get hideExample => _isZh ? '隱藏範例' : 'Hide Example';
  static String get exampleExplanation => _isZh ? '範例說明:' : 'Example Explanation:';

  // Format strings
  static String playerCount(int count) => _isZh ? '$count 名玩家' : '$count $players';
  static String roundOf(int current, int total) => _isZh ? '第 $current / $total 局' : 'Round $current of $total';
  static String fan(int count) => _isZh ? '$count 番' : '$count fan';

  // Tutorial - Introduction
  static String get welcomeTitle => _isZh ? '歡迎使用麻將計分器' : 'Welcome to Mahjong Score Calculator';
  static String get appDescription => _isZh ? '您的香港麻將全方位助手！' : 'Your all-in-one companion for Hong Kong Mahjong!';
  static String get keyFeatures => _isZh ? '主要功能：' : 'Key Features:';
  
  static String get smartCalculatorTitle => _isZh ? '智能計分' : 'Smart Calculator';
  static String get smartCalculatorDesc => _isZh ? '即時計算番數與分數。支援十三么、九子連環等特殊牌型。' : 'Instantly calculate Fan and Score. Supports special hands like Thirteen Orphans and Nine Gates.';
  
  static String get gameRecordingTitle => _isZh ? '對局記錄' : 'Game Recording';
  static String get gameRecordingDesc => _isZh ? '逐局記錄分數。自動管理莊家輪替與圈風。' : 'Track scores round-by-round. Auto-manages Dealer rotation and Round Winds.';
  
  static String get rulesReferenceTitle => _isZh ? '規則參考' : 'Rules Reference';
  static String get rulesReferenceDesc => _isZh ? '完整的香港麻將計分規則指南，附帶範例。' : 'Complete guide to HK Mahjong scoring patterns with examples.';
  
  static String get playerManagementTitle => _isZh ? '玩家管理' : 'Player Management';
  static String get playerManagementDesc => _isZh ? '儲存玩家群組並追蹤總對局數。' : 'Save player groups and keep track of total games played.';
  
  static String get swipeToLearn => _isZh ? '滑動以學習基礎知識 ->' : 'Swipe to learn the basics ->';

  // Tutorial - Tile Types
  static String get tileTypesTitle => _isZh ? '麻將牌種類' : 'Types of Mahjong Tiles';
  static String get characterTiles => _isZh ? '萬子' : 'Character Tiles';
  static String get characterTilesDesc => _isZh ? '漢字數字一至九' : 'Numbered 1 to 9 in characters';
  static String get dotsTiles => _isZh ? '筒子' : 'Dots Tiles';
  static String get dotsTilesDesc => _isZh ? '圓點數量一至九' : 'Numbered 1 to 9 in dots';
  static String get bambooTiles => _isZh ? '索子' : 'Bamboo Tiles';
  static String get bambooTilesDesc => _isZh ? '竹條數量一至九' : 'Numbered 1 to 9 in bamboo';
  static String get honorTiles => _isZh ? '字牌' : 'Honor Tiles';
  static String get honorTilesDesc => _isZh ? '包含風牌 (東南西北) 與三元牌 (中發白)' : 'Include Wind tiles (East/South/West/North) and Dragon tiles (Red/Green/White)';
  static String get flowerTiles => _isZh ? '花牌' : 'Flower Tiles';
  static String get flowerTilesDesc => _isZh ? '花 (梅蘭菊竹) 與 季 (春夏秋冬)' : 'Flowers (Plum, Orchid, Chrysanthemum, Bamboo) and Seasons (Spring, Summer, Autumn, Winter)';

  // Tutorial - Basic Rules
  static String get basicRulesTitle => _isZh ? '基本規則' : 'Basic Rules';
  static String get gameObjectiveTitle => _isZh ? '1. 遊戲目標' : '1. Game Objective';
  static String get gameObjectiveDesc1 => _isZh ? '麻將的目標是組成一副完整的牌，通常包含：' : 'The goal of mahjong is to form a complete hand, usually consisting of:';
  static String get gameObjectiveDesc2 => _isZh ? '• 4 組 (順子/刻子) + 1 對眼' : '• 4 sets (chow/pong) + 1 pair (eyes)';
  static String get gameObjectiveDesc3 => _isZh ? '• 特殊牌型 (例如：十三么)' : '• Special hands (e.g., Thirteen Orphans)';
  
  static String get basicTermsTitle => _isZh ? '2. 基本術語' : '2. Basic Terms';
  static String get basicTermsChow => _isZh ? '• 上 ：三張連續的牌 (例如：123萬)' : '• Chow: Three consecutive tiles (e.g., 1m-2m-3m)';
  static String get basicTermsPong => _isZh ? '• 碰 ：三張相同的牌 (例如：333筒)' : '• Pong: Three identical tiles (e.g., 5p-5p-5p)';
  static String get basicTermsEyes => _isZh ? '• 眼 ：一對相同的牌' : '• Eyes: A pair of identical tiles';
  static String get basicTermsSelfDraw => _isZh ? '• 自摸 ：自己摸到獲勝的牌' : '• Self-Draw: Draw your own winning tile';
  static String get basicTermsDiscard => _isZh ? '• 出衝 ：打出的牌讓別人胡牌' : '• Discard: Discard a tile that lets others win';
  
  static String get startingGameTitle => _isZh ? '3. 遊戲開始' : '3. Starting the Game';
  static String get startingGameDesc => _isZh ? '莊家 (東) 擲 2 或 3 顆骰子決定開門位置。' : 'The Dealer (East) rolls 2 or 3 dice to determine which wall to break.';
  static String get diceRollTableTitle => _isZh ? '擲骰與開門：' : 'Dice Roll & Wall Selection:';

  // Tutorial - Basic Rules Continued
  static String get counterClockwiseCount => _isZh ? '從莊家開始逆時針數。' : 'Count counter-clockwise starting from Dealer as 1.';
  static String get exampleRoll8 => _isZh ? '範例: 擲出 8 → 數到北位 (左家)。在北牆開門。' : 'Example: Roll 8 → Count to North (Left). Break North wall.';
  static String get drawClockwise => _isZh ? '從開門處，順時針數墩數開始抓牌。' : 'From the chosen wall, count stacks clockwise (skipping the rolled number) to start drawing.';
  static String get rememberDirection => _isZh ? '口訣：逆時針打牌，順時針抓牌！' : 'Remember: Play Counter-Clockwise, Draw Clockwise!';
  
  static String get dealingProcedureTitle => _isZh ? '配牌流程：' : 'Dealing Procedure:';
  static String get dealStep1 => _isZh ? '1. 每位玩家輪流抓 4 張牌 (2 墩)。' : '1. Each player takes 4 tiles (2 stacks) in order.';
  static String get dealStep2 => _isZh ? '2. 重複直到每人有 12 張牌。' : '2. Repeat until everyone has 12 tiles.';
  static String get dealStep3 => _isZh ? '3. 莊家跳牌抓第 1 和第 3 張 (共 14 張)。' : '3. Dealer takes 1st and 3rd tile from end (14 total).';
  static String get dealStep4 => _isZh ? '4. 閒家各抓 1 張 (共 13 張)。' : '4. Others take 1 tile (13 total).';
  static String get dealStep5 => _isZh ? '5. 補花。' : '5. Replace Flower tiles from the back of the wall.';
  
  static String get gameplayProcessTitle => _isZh ? '4. 行牌流程' : '4. Gameplay Process';
  static String get gameplayProcessDesc => _isZh ? '配牌補花後，從莊家開始逆時針進行。' : 'After dealing and flower replacement, the game proceeds counter-clockwise starting from the Dealer.';
  static String get standardTurnTitle => _isZh ? '標準回合：' : 'Standard Turn:';
  static String get drawAction => _isZh ? '摸牌' : 'Draw';
  static String get actionAction => _isZh ? '動作' : 'Action';
  static String get discardAction => _isZh ? '打牌' : 'Discard';
  
  static String get turnStep1 => _isZh ? '1. 從牌牆摸一張牌 (莊家首輪跳過)。' : '1. Draw a tile from the wall (Dealer skips this on first turn).';
  static String get turnStep2 => _isZh ? '2. 若是花牌，補花。' : '2. If it\'s a Flower, reveal it and draw a replacement from the back.';
  static String get turnStep3 => _isZh ? '3. 選擇是否暗槓、加槓或自摸胡牌。' : '3. Choose to Kong (Concealed/Added) or Win (Self-Draw).';
  static String get turnStep4 => _isZh ? '4. 打出一張牌結束回合。' : '4. Discard one tile to end your turn.';
  
  static String get interactionsTitle => _isZh ? '鳴牌 (偷牌)：' : 'Interactions (Stealing):';
  static String get interactionsDesc => _isZh ? '其他玩家可以喊出宣告來中斷回合。' : 'Other players can interrupt the turn by claiming a discard.';
  
  static String get priorityRuleTitle => _isZh ? '優先權規則：' : 'Priority Rule:';
  static String get priorityRuleDesc => _isZh ? '胡 > 槓/碰 > 上' : 'Win > Kong/Pong > Chow';
  static String get priorityPongWins => _isZh ? '若一家想上，另一家想碰同一張牌，碰優先。' : 'If one player wants to Chow and another wants to Pong the same tile, Pong wins.';
  
  static String get missedWinTitle => _isZh ? '過水規則：' : 'Missed Win Rule :';
  static String get missedWinDesc => _isZh ? '若你放棄胡別人打出的牌，在自己下次摸牌/動作前，不能胡同一張牌。' : 'If you can win on a discard but choose not to (e.g., to try for a higher score), you cannot win on that same tile from another player until you complete your next turn (draw/action).';
  static String get missedWinException => _isZh ? '例外：如果新摸到的牌讓你番數增加 (例如：湊成特殊牌型)，視乎家規可能允許胡牌。' : 'Exception: If the new tile gives you a higher Fan count (e.g., completing a specific pattern), you may be allowed to win depending on house rules.';
  
  static String get actionChow => _isZh ? '上 ' : 'Chow ';
  static String get targetLeftPlayer => _isZh ? '只限上家 (左家)' : 'Left Player Only';
  static String get descChowInteract => _isZh ? '組成順子 (例如：1-2-3)' : 'Form a sequence (e.g., 1-2-3).';
  
  static String get actionPong => _isZh ? '碰 ' : 'Pong ';
  static String get targetAnyPlayer => _isZh ? '任何一家' : 'Any Player';
  static String get descPongInteract => _isZh ? '組成刻子 (例如：3-3-3) -  中斷順序' : 'Form a triplet (e.g., 3-3-3). Interrupts turn order.';

  static String get actionKong => _isZh ? '槓 ' : 'Kong ';
  static String get descKongInteract => _isZh ? '組成槓子 - 補牌 - 中斷順序' : 'Form a quad. Draw replacement. Interrupts turn order.';
  
  static String get actionWinInteract => _isZh ? '胡 ' : 'Win ';
  static String get descWinInteract => _isZh ? '完成牌型 - 遊戲結束' : 'Complete the hand. Ends the game.';
  
  // Tutorial - Scoring
  static String get scoringSystemTitle => _isZh ? '計分系統' : 'Scoring System';
  static String get scoringRulesTitle => _isZh ? '香港麻將計分表' : 'Hong Kong Mahjong Scoring Rules';
  static String get scoringRulesDesc => _isZh ? '麻將分數由番數決定。下表顯示各番數對應的分數：' : 'Mahjong scoring is determined by fan count. The table below shows the points for each fan count:';
  
  static String get fanPointsHeader => _isZh ? '番數' : 'Fan Points';
  static String get byDiscardHeader => _isZh ? '出衝 (放槍)' : 'By Discard';
  static String get bySelfDrawHeader => _isZh ? '自摸' : 'By Self-Draw';
  
  static String get flowerTilesScoringTitle => _isZh ? '花牌計分' : 'Flower Tiles Scoring';
  static String get noFlowersFan => _isZh ? '• 無花 ：1 番' : '• No Flowers: 1 Fan';
  static String get ownFlowerFan => _isZh ? '• 正花 ：1 番 (花牌對應門風)' : '• Own Flower: 1 Fan (Flower matches seat wind)';
  static String get flowerMapping => _isZh ? '花牌對應：' : 'Flower Mapping:';
  static String get seat1Flower => _isZh ? '• 1號位 (東)：春、梅' : '• Seat 1 (East): Spring, Plum';
  static String get seat2Flower => _isZh ? '• 2號位 (南)：夏、蘭' : '• Seat 2 (South): Summer, Orchid';
  static String get seat3Flower => _isZh ? '• 3號位 (西)：秋、菊' : '• Seat 3 (West): Autumn, Chrysanthemum';
  static String get seat4Flower => _isZh ? '• 4號位 (北)：冬、竹' : '• Seat 4 (North): Winter, Bamboo';
  
  static String get honorTilesScoringTitle => _isZh ? '字牌計分' : 'Honor Tiles Scoring';
  static String get dragonPongFan => _isZh ? '• 三元牌刻/槓 (中發白)：1 番' : '• Dragon Pong/Kong: 1 Fan (Red, Green, or White Dragon)';
  static String get roundWindPongFan => _isZh ? '• 圈風刻/槓：1 番' : '• Round Wind Pong/Kong: 1 Fan (Matches the current round wind)';
  static String get seatWindPongFan => _isZh ? '• 門風刻/槓：1 番' : '• Seat Wind Pong/Kong: 1 Fan (Matches your seat wind)';
  
  static String get winningPatternsTitle => _isZh ? '胡牌牌型一覧' : 'Winning Patterns (Fan List)';
  static String get winningPatternsDesc => _isZh ? '點擊牌型名稱查看詳情與範例。' : 'Click on a pattern name to see details and examples.';
  
  static String get chickenHand => _isZh ? '雞胡' : '0 (Chicken)';
  static String get naMinOne => _isZh ? '不適用 (最少 1)' : 'N/A (min 1)';
  static String get limitHand => _isZh ? '爆棚 (上限)' : '13 (Limit)';
  
  // Tile Selection
  static String get selectWinningHand => _isZh ? '選擇胡牌' : 'Select Winning Hand';
  static String get maxTilesAlert => _isZh ? '同一張牌不能超過 4 張' : 'Cannot select more than 4 of the same tile';
  static String get maxTotalTilesAlert => _isZh ? '最多選擇 18 張牌' : 'Maximum 18 tiles allowed';
  static String get minTilesAlert => _isZh ? '請至少選擇 14 張牌' : 'Select at least 14 tiles';
  static String get selectedCount => _isZh ? '已選：' : 'Selected:';
  static String get clear => _isZh ? '清除' : 'Clear';
  static String get charactersTab => _isZh ? '萬子' : 'Characters';
  static String get dotsTab => _isZh ? '筒子' : 'Dots';
  static String get bambooTab => _isZh ? '索子' : 'Bamboo';
  static String get honorsTab => _isZh ? '字牌' : 'Honors';

  // Mahjong Logic Messages
  static String get invalidTileCount => _isZh ? '牌數錯誤。必須為 14、15、16、17 或 18 張。' : 'Invalid number of tiles. Must be 14, 15, 16, 17, or 18.';
  static String get winningHandThirteenOrphans => _isZh ? '胡牌 (十三么)！' : 'Winning Hand (Thirteen Orphans)!';
  static String get winningHand => _isZh ? '胡牌！' : 'Winning Hand!';
  static String get winningHandInvalid => _isZh ? '無法胡牌 (需要 4 組 + 1 對眼)。' : 'Cannot form a winning hand (4 sets + 1 pair).';

  // History
  static String get gameHistoryTitle => _isZh ? '對局記錄' : 'Game History';
  static String get noHistory => _isZh ? '沒有對局記錄' : 'No history records';
  static String gameIndex(int index) => _isZh ? '對局 #$index' : 'Game #$index';
  static String get dateLabel => _isZh ? '日期' : 'Date';
  static String get roundsLabel => _isZh ? '局數' : 'Rounds';

  static String get tipTitle => _isZh ? '提示：' : 'Tip:';

  static String get splashTitle => _isZh ? '香港麻將計分器' : 'Mahjong Calculator';
  static String get splashSubtitle => _isZh ? '讓計分變得更簡單' : 'Making Scoring Easier';

  static String get tipDesc => _isZh ? '使用本應用程式的計分功能可自動計算番數與分數！' : 'Use this app\'s scoring feature to automatically calculate fan and score!';

  static String get importantNoteTitle => _isZh ? '重要提示：' : 'Important Note:';
  static String get flowerNote => _isZh ? '如果您持有的花牌與座位不符 (例如：東位持有夏)，該花牌不計番數，並且失去「無花」獎勵。' : 'If you have flowers but none match your seat (e.g., East seat holding Summer), you get 0 Fan for flowers and lose the "No Flower" bonus.';
  static String get dragonNote => _isZh ? '註：若門風與圈風相同 (例如：東圈東位)，碰出該風牌可得 2 番！' : 'Note: If your seat wind matches the round wind (e.g., East Seat in East Round), a Pong of East Wind gives 2 Fan!';

  static String get diceDealerEast => _isZh ? '莊家 (東)' : 'Dealer (East)';
  static String get diceSouthRight => _isZh ? '南 (下家)' : 'South (Right)';
  static String get diceWestOpposite => _isZh ? '西 (對家)' : 'West (Opposite)';
  static String get diceNorthLeft => _isZh ? '北 (上家)' : 'North (Left)';
  
  static String defaultPlayerName(int index) => _isZh ? '玩家 $index' : 'Player $index';

  // Tutorial - Scoring
  static String fanCount(String count) => _isZh ? count.replaceAll("Fan", "番") : count;
  
  // Login Screen
  static String get loginTitle => _isZh ? '登入' : 'Login';
  static String get createAccountTitle => _isZh ? '建立帳戶' : 'Create Account';
  static String get emailLabel => _isZh ? '電子郵件' : 'Email';
  static String get passwordLabel => _isZh ? '密碼' : 'Password';
  static String get loginButton => _isZh ? '登入' : 'Login';
  static String get createAccountButton => _isZh ? '建立帳戶' : 'Create Account';
  static String get noAccountText => _isZh ? '沒有帳戶？建立一個' : 'Don\'t have an account? Create one';
  static String get hasAccountText => _isZh ? '已經有帳戶？登入' : 'Already have an account? Login';
  static String get emailRequired => _isZh ? '請輸入電子郵件' : 'Please enter your email';
  static String get emailInvalid => _isZh ? '請輸入有效的電子郵件' : 'Please enter a valid email';
  static String get passwordRequired => _isZh ? '請輸入密碼' : 'Please enter your password';
  static String get passwordLengthError => _isZh ? '密碼至少需要 6 個字元' : 'Password must be at least 6 characters';
  static String get genericError => _isZh ? '發生未知錯誤' : 'An unexpected error occurred';
  
  // Saved Groups Screen
  static String get confirmDeleteTitle => _isZh ? '確認刪除' : 'Confirm Delete';
  static String confirmDeleteContent(String name) => _isZh ? '確定要刪除群組 "$name" 嗎？' : 'Are you sure you want to delete group "$name"?';
  static String groupDeleted(String name) => _isZh ? '群組 "$name" 已刪除' : 'Group "$name" deleted';
  static String get savedGroupsTitle => _isZh ? '已儲存的群組' : 'Saved Player Groups';
  
  static String get noAnySavedGroups => _isZh ? '尚未儲存任何群組' : 'No saved player groups yet';
  static String get editGroup => _isZh ? '編輯群組' : 'Edit Group';
  static String get deleteGroup => _isZh ? '刪除群組' : 'Delete Group';
  static String get createdPrefix => _isZh ? '建立時間: ' : 'Created: ';
  static String get playersListPrefix => _isZh ? '玩家: ' : 'Players: ';
  
  static String defaultGroupName(String timestamp) => _isZh ? '群組 $timestamp' : 'Group $timestamp';
}
