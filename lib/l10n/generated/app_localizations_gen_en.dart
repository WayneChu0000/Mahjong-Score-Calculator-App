// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_gen.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mahjong Score Calculator';

  @override
  String get homeTitle => 'Mahjong Calculator';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get newGroup => 'New Group';

  @override
  String get history => 'History';

  @override
  String get historyComingSoon => 'History feature coming soon...';

  @override
  String get testFirebase => 'Test Firebase';

  @override
  String get firebaseSuccess => 'Firebase connected: ';

  @override
  String get firebaseFailed => 'Firebase failed: ';

  @override
  String get savedGroups => 'Saved Player Groups';

  @override
  String get viewAll => 'View All';

  @override
  String get noSavedGroups => 'No saved player groups';

  @override
  String get createFirstGroupHint => 'Create your first group to get started';

  @override
  String get createGroup => 'Create Player Group';

  @override
  String get players => 'players';

  @override
  String get createdAt => 'Created: ';

  @override
  String get edit => 'Edit';

  @override
  String get start => 'Start';

  @override
  String get allGroups => 'All Player Groups';

  @override
  String get editGroupComingSoon => 'Edit group feature coming soon...';

  @override
  String get scoreUpdated => 'Score updated for group: ';

  @override
  String get playerSetupTitle => 'Player Setup';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupNameHint => 'Enter group name';

  @override
  String get groupNameError => 'Please enter a group name';

  @override
  String get playerName => 'Player Name';

  @override
  String get playerNameHint => 'Enter player name';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get minimumPlayers => 'At least 2 players required';

  @override
  String get duplicatePlayer => 'Player already exists';

  @override
  String get saveGroup => 'Save Group';

  @override
  String get saveAndPlay => 'Save & Play';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get playerList => 'Player List';

  @override
  String get groupSaved => 'Group saved successfully!';

  @override
  String get groupSaveFailed => 'Failed to save group';

  @override
  String get minFan => 'Min Fan';

  @override
  String get maxFan => 'Max Fan';

  @override
  String get noLimit => 'No Limit';

  @override
  String get fanLimitSettings => 'Fan Range Settings';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get hongKongMahjong => 'Hong Kong Style (13 Tiles)';

  @override
  String get taiwaneseMahjong => 'Taiwan Style (16 Tiles)';

  @override
  String get baseTai => 'Base Tai';

  @override
  String get taiValue => 'Score per Tai';

  @override
  String get tai => 'Tai';

  @override
  String get scoreRecording => 'Score Recording';

  @override
  String get round => 'Round';

  @override
  String get ofSeparator => 'of';

  @override
  String get dealer => 'Dealer';

  @override
  String get calculateScore => 'Calculate Score';

  @override
  String get endGame => 'End Game';

  @override
  String get gameResults => 'Game Results';

  @override
  String get finalScores => 'Final Scores';

  @override
  String get winner => 'Winner';

  @override
  String get close => 'Close';

  @override
  String get nextRound => 'Next Round';

  @override
  String get stats => 'Stats';

  @override
  String get roundsPlayed => 'Rounds Played';

  @override
  String get selfDrawn => 'Self-Drawn';

  @override
  String get winningRate => 'Winning Rate';

  @override
  String fan(int f) {
    return '$f Fan';
  }

  @override
  String taiCount(int t) {
    return '$t Tai';
  }

  @override
  String get totalFan => 'Total Fan';

  @override
  String get totalTai => 'Total Tai';

  @override
  String get scoreCalculation => 'Score Calculation';

  @override
  String get enterScores => 'Enter Scores';

  @override
  String get specialWinningCondition => 'Special Winning Condition';

  @override
  String currentScore(int score) {
    return '(Current: $score pts)';
  }

  @override
  String totalWin(int score) {
    return '(Total: $score)';
  }

  @override
  String get submit => 'Submit';

  @override
  String get reset => 'Reset';

  @override
  String get totalMustBeZero => 'Total must be zero';

  @override
  String get confirmSubmit => 'Confirm non-zero total?';

  @override
  String get totalIs => 'Total is ';

  @override
  String get continueAnyway => 'Continue Anyway';

  @override
  String get win => 'Win';

  @override
  String get selfDraw => 'Self-Draw';

  @override
  String get discard => 'Discard';

  @override
  String get winningPlayer => 'Winning Player';

  @override
  String get discardPlayer => 'Discard Player';

  @override
  String get roundWind => 'Round Wind';

  @override
  String get seatWind => 'Seat Wind';

  @override
  String get flowers => 'Flowers';

  @override
  String get selectFlowers => 'Select Flowers';

  @override
  String get handPreviewArea => 'Hand Preview Area';

  @override
  String get scanTiles => 'Scan Tiles';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get selectHand => 'Select Hand';

  @override
  String get analyzingTiles => 'Analyzing tiles...';

  @override
  String get takePhotoHint =>
      'Take photo, upload image, or click to select hand pattern';

  @override
  String get item => 'Item';

  @override
  String get value => 'Value';

  @override
  String get totalScore => 'Total Score';

  @override
  String get fanTitle => 'Fan';

  @override
  String get limit => 'Limit';

  @override
  String get perPerson => ' / person';

  @override
  String get points => 'points';

  @override
  String get twConcealedSelfDraw => 'Concealed Self-Drawn';

  @override
  String get descConcealedSelfDraw => 'Self-drawn win with a concealed hand.';

  @override
  String get explConcealedSelfDraw =>
      'Winning by self-draw with no exposed melds (concealed Kongs allowed).';

  @override
  String get twProperWind => 'Wind of the Round/Seat';

  @override
  String get descProperWind => 'Pong of Wind matching Round or Seat.';

  @override
  String get explProperWind =>
      'Pong/Kong of a Wind tile matching either the Round Wind or your Seat Wind. 2 Tai each.';

  @override
  String get twOrdinaryWind => 'Ordinary Wind';

  @override
  String get descOrdinaryWind => 'Pong of non-matching Wind.';

  @override
  String get explOrdinaryWind =>
      'Pong/Kong of a Wind tile not matching either the Round Wind or Seat Wind. 1 Tai each.';

  @override
  String get twDragonPong => 'Dragon Pong';

  @override
  String get descTwDragonPong => 'Pong of Red, Green, or White Dragon.';

  @override
  String get explTwDragonPong =>
      'Pong/Kong of a Dragon tile (Red, Green, or White). 2 Tai each.';

  @override
  String get twEyeOf258 => 'Eye of 2, 5, 8';

  @override
  String get descEyeOf258 => 'Pair of 2, 5, or 8 as the eyes.';

  @override
  String get explEyeOf258 =>
      'Using a tile numbered 2, 5, or 8 as the pair (eyes). +1 Tai.';

  @override
  String get twAllSimples => 'All Simples';

  @override
  String get descAllSimples => 'No terminals (1, 9) or honor tiles.';

  @override
  String get explAllSimples =>
      'Hand with no terminals (1, 9) or honor tiles. Full: 5 Tai, Half: 3 Tai.';

  @override
  String get twConcealedDragon => 'Concealed Dragon';

  @override
  String get descConcealedDragon => 'All 1-9 of one suit concealed in hand.';

  @override
  String get explConcealedDragon =>
      'Having all tiles numbered 1-9 of the same suit concealed in hand. 20 Tai.';

  @override
  String get twFiveConcealedPongs => 'Five Concealed Pungs';

  @override
  String get descFiveConcealedPongs => 'Five concealed Pungs in hand.';

  @override
  String get explFiveConcealedPongs =>
      'Having five concealed Pungs in hand (no exposed melds). 80 Tai.';

  @override
  String get twJianJianHu => 'Concealed All Pongs Self-Draw';

  @override
  String get descJianJianHu => 'Self-draw + Concealed + All Pongs.';

  @override
  String get explJianJianHu =>
      'Win by self-draw with a fully concealed hand composed entirely of Pongs (All Pongs). 100 Tai. Does not count Self-Draw, Concealed Hand, All Pongs, or Five Concealed Pungs.';

  @override
  String get twDeclaredReady => 'Declared Ready';

  @override
  String get descDeclaredReady =>
      'Declared ready to win, cannot change hand after.';

  @override
  String get explDeclaredReady =>
      'After declaring ready, you cannot change your hand or declare concealed kongs. 5 Tai.';

  @override
  String get twUnderTheSea => 'Under the Sea';

  @override
  String get descUnderTheSea =>
      'Self-drawn win on the very last tile of the wall.';

  @override
  String get explUnderTheSea =>
      'Winning by self-drawing the very last tile of the wall. 20 Tai.';

  @override
  String get twWrongFlower => 'Wrong Flower';

  @override
  String get descWrongFlower => 'Flower not matching your seat.';

  @override
  String get explWrongFlower =>
      'Each flower tile whose number does not match your seat position. 1 Tai each.';

  @override
  String get twProperFlower => 'Proper Flower';

  @override
  String get descProperFlower => 'Flower matching your seat.';

  @override
  String get explProperFlower =>
      'Each flower tile whose number matches your seat position. 2 Tai each.';

  @override
  String get twDealerBonus => 'Dealer Bonus';

  @override
  String get twConsecutiveDealer => 'Consecutive Dealer Bonus';

  @override
  String consecutiveDealerCount(int count) {
    return 'Consecutive $count';
  }

  @override
  String get twDeclaredReadyCondition => 'Declared Ready';

  @override
  String get ruleSelfDraw => 'Self-Draw';

  @override
  String get ruleNoFlowers => 'No Flowers';

  @override
  String get ruleFlowerPlatform14 => 'Flower Platform (1-4)';

  @override
  String get ruleFlowerPlatform58 => 'Flower Platform (5-8)';

  @override
  String get ruleOwnFlower => 'Own Flower';

  @override
  String get ruleOwnSeason => 'Own Season';

  @override
  String get rulePongOfWhite => 'Pong of White Dragon';

  @override
  String get rulePongOfGreen => 'Pong of Green Dragon';

  @override
  String get rulePongOfRed => 'Pong of Red Dragon';

  @override
  String get ruleRoundWind => 'Round Wind';

  @override
  String get ruleSeatWind => 'Seat Wind';

  @override
  String get ruleAllChows => 'All Chows';

  @override
  String get ruleAllPongs => 'All Pongs';

  @override
  String get ruleMixedOneSuit => 'Mixed One Suit';

  @override
  String get rulePureOneSuit => 'Pure One Suit';

  @override
  String get ruleSmallThreeDragons => 'Small Three Dragons';

  @override
  String get ruleBigThreeDragons => 'Big Three Dragons';

  @override
  String get ruleSmallFourWinds => 'Small Four Winds';

  @override
  String get ruleBigFourWinds => 'Big Four Winds';

  @override
  String get ruleThirteenOrphans => 'Thirteen Orphans';

  @override
  String get ruleEightImmortals => 'Eight Immortals';

  @override
  String get ruleFlowerHand => 'Flower Hand';

  @override
  String get ruleHiddenTreasure => 'Hidden Treasure';

  @override
  String get ruleAllHonors => 'All Honors';

  @override
  String get ruleNineGates => 'Nine Gates';

  @override
  String get ruleEighteenArhats => 'Eighteen Arhats';

  @override
  String get ruleSevenPairs => 'Seven Pairs';

  @override
  String get ruleMigui => 'Migui (Eight Pairs)';

  @override
  String get descSevenPairs => 'Hand consisting of 7 pairs';

  @override
  String get descMigui => 'Hand consisting of 8 pairs (16 tiles + 1)';

  @override
  String get explSevenPairs => 'Seven Pairs';

  @override
  String get explMigui => 'Eight Pairs';

  @override
  String get ruleHeavenlyHand => 'Heavenly Hand';

  @override
  String get ruleEarthlyHand => 'Earthly Hand';

  @override
  String get ruleKong => 'Kong';

  @override
  String get ruleNone => 'None';

  @override
  String get east => 'East';

  @override
  String get south => 'South';

  @override
  String get west => 'West';

  @override
  String get north => 'North';

  @override
  String get home => 'Home';

  @override
  String get rules => 'Rules';

  @override
  String get gameRules => 'Game Rules';

  @override
  String get settings => 'Settings';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get langEnglish => 'English';

  @override
  String get langTraditionalChinese => 'Traditional Chinese';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get about => 'About';

  @override
  String get aboutDesc => 'A simple and easy-to-use Mahjong score calculator.';

  @override
  String get copyright => '© 2025 Mahjong Calculator Team';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackContent =>
      'Please send your feedback to support@example.com';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyContent =>
      'We respect your privacy. This app stores your game data locally and on Firebase for synchronization purposes. We do not share your personal data with third parties.';

  @override
  String get confirmDeleteGroup =>
      'Are you sure you want to delete this group?';

  @override
  String get gameInProgressTitle => 'Start New Game?';

  @override
  String get gameInProgressContent =>
      'There is a game in progress. Starting a new game will assume the previous one is finished and stats will be saved.';

  @override
  String get startNewGame => 'Start New Game';

  @override
  String get resumeGame => 'Resume Game';

  @override
  String get backToGame => 'Back to Game';

  @override
  String get playerStatsTitle => 'Player Statistics';

  @override
  String get recentGroups => 'Recent Groups';

  @override
  String get mostPlayedGroups => 'Most Played Groups';

  @override
  String get editPlayers => 'Edit Players';

  @override
  String get setupPlayers => 'Setup Players';

  @override
  String get enterGroupNameHint => 'e.g., Weekend Mahjong Group';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteGroupWarning =>
      'Are you sure you want to delete this player group? This action cannot be undone.';

  @override
  String editPlayerTitle(int index) {
    return 'Edit Player $index';
  }

  @override
  String get totalGamesMatches => 'Total Games (Matches):';

  @override
  String get descAllChows => 'Hand with only Chows, no Pongs.';

  @override
  String get explAllChows =>
      'Hand composed entirely of Chows (sequences) and a pair. No Pongs or Kongs.';

  @override
  String get descNoFlowers => 'No Flower tiles.';

  @override
  String get explNoFlowers => 'Winning without any Flower tiles.';

  @override
  String get descOwnSeason => 'Flower tile matches your seat wind.';

  @override
  String get explOwnSeason =>
      'The Flower tile number corresponds to your seat wind (1=East, 2=South, 3=West, 4=North).';

  @override
  String get descSelfDraw => 'Winning by self-drawn tile.';

  @override
  String get explSelfDraw => 'Drawing the winning tile yourself adds 1 fan.';

  @override
  String get ruleMenQianQing => 'Men Qian Qing';

  @override
  String get descMenQianQing => 'Winning without melding exposed tiles.';

  @override
  String get explMenQianQing =>
      'Concealed hand. No exposed melds before winning.';

  @override
  String get ruleDragonWindPong => 'Dragon/Wind Pong';

  @override
  String get descDragonWindPong => 'Pong of Dragons or Seat/Round Wind.';

  @override
  String get explDragonWindPong => 'A Pong/Kong of Dragons or Seat/Round Wind.';

  @override
  String get ruleRobbingKong => 'Robbing the Kong';

  @override
  String get descRobbingKong => 'Winning off a Kong.';

  @override
  String get explRobbingKong =>
      'Winning when another player declares a Kong with a tile you need.';

  @override
  String get ruleHaidilao => 'Haidilao';

  @override
  String get descHaidilao => 'Winning on the last tile.';

  @override
  String get explHaidilao =>
      'Winning by drawing the very last tile of the wall.';

  @override
  String get ruleKongOnKong => 'Kong on Kong/Flower';

  @override
  String get descKongOnKong => 'Winning after a Kong or Flower replacement.';

  @override
  String get explKongOnKong =>
      'Drawing the winning tile from the dead wall after declaring a Kong or getting a Flower.';

  @override
  String get ruleFlowerPlatform => 'Flower Platform';

  @override
  String get descFlowerPlatform => 'Complete set of Flowers.';

  @override
  String get explFlowerPlatform =>
      'Collecting a full set of numbered Flowers (1-4) or Seasons (1-4).';

  @override
  String get ruleSevenFlowers => 'Flower Hand (7 Flowers)';

  @override
  String get descSevenFlowers => 'Seven Flowers.';

  @override
  String get explSevenFlowers =>
      'Collecting 7 Flower tiles allows for an immediate win.';

  @override
  String get descAllPongs => '4 Pongs/Kongs & Pair.';

  @override
  String get explAllPongs =>
      'Hand composed entirely of Pongs (triplets) or Kongs and a pair.';

  @override
  String get descMixedOneSuit => 'One suit & Honors.';

  @override
  String get explMixedOneSuit => 'Hand composed of one suit and Honor tiles.';

  @override
  String get ruleMixedTerminals => 'Mixed Terminals';

  @override
  String get descMixedTerminals => 'Terminals & Honors.';

  @override
  String get explMixedTerminals =>
      'All Pongs/Kongs composed of Terminals (1/9) and Honor tiles.';

  @override
  String get descSmallThreeDragons => '2 Dragon Pongs + Pair.';

  @override
  String get explSmallThreeDragons =>
      'Two Pongs/Kongs of Dragons and a pair of the third Dragon.';

  @override
  String get descSmallFourWinds => '3 Wind Pongs + Pair.';

  @override
  String get explSmallFourWinds =>
      'Three Pongs/Kongs of Winds and a pair of the fourth Wind.';

  @override
  String get descThirteenOrphans => '13 Unique Terminals.';

  @override
  String get explThirteenOrphans =>
      'One of each Terminal and Honor tile + one pair.';

  @override
  String get ruleBlessingMan => 'Blessing of Man';

  @override
  String get ruleBlessingOfMan => 'Blessing of Man';

  @override
  String get descBlessingMan => 'Non-Dealer 1st Turn Win.';

  @override
  String get explBlessingMan =>
      'As non-dealer, you win on your first turn with a self-pick.';

  @override
  String get descEarthlyHand => 'Win on Dealer\'s Discard.';

  @override
  String get explEarthlyHand =>
      'As non-dealer, you win using the dealer\'s first discard.';

  @override
  String get descHeavenlyHand => 'Dealer Initial Win.';

  @override
  String get explHeavenlyHand => 'As dealer, your beginning hand wins.';

  @override
  String get descEighteenArhats => '4 Kongs + Pair.';

  @override
  String get explEighteenArhats => 'Winning with four Kongs (18 tiles total).';

  @override
  String get descBigFourWinds => '4 Wind Pongs.';

  @override
  String get explBigFourWinds =>
      'Four Pongs/Kongs of East, South, West, and North Winds.';

  @override
  String get descEightImmortals => 'All 8 Flowers.';

  @override
  String get explEightImmortals =>
      'Collecting all 8 Flower tiles allows for an immediate win.';

  @override
  String get descHiddenTreasure => '4 Concealed Pongs.';

  @override
  String get explHiddenTreasure =>
      'Four Pongs/Kongs that were all self-drawn (concealed).';

  @override
  String get ruleDoubleKong => 'Double Kong Replacement';

  @override
  String get descDoubleKong => 'Win on 2nd Kong.';

  @override
  String get explDoubleKong =>
      'If you call a kong, call a second kong using the replacement tile, then win on the second replacement.';

  @override
  String get descAllHonors => 'All Honors.';

  @override
  String get explAllHonors => 'Hand composed entirely of Honor tiles.';

  @override
  String get rulePureTerminals => 'Pure Terminals';

  @override
  String get descPureTerminals => 'All 1s and 9s.';

  @override
  String get explPureTerminals =>
      'All Pongs/Kongs composed entirely of Terminal tiles (1 and 9).';

  @override
  String get descNineGates => '1-9 of one suit hand.';

  @override
  String get explNineGates =>
      'Concealed hand of one suit: 1112345678999 + any tile of the same suit.';

  @override
  String get descPureOneSuit => 'All one suit.';

  @override
  String get explPureOneSuit =>
      'Hand composed entirely of tiles from a single suit.';

  @override
  String get descBigThreeDragons => '3 Dragon Pongs.';

  @override
  String get explBigThreeDragons =>
      'Three Pongs/Kongs of Red, Green, and White Dragons.';

  @override
  String get totalHandsPlayed => 'Total Hands Played:';

  @override
  String get noResultRate => 'No Result Rate:';

  @override
  String get statsWinRate => 'Win Rate';

  @override
  String get statsSelfDraw => 'Self-Draw';

  @override
  String get statsRon => 'Discard';

  @override
  String get statsDealIn => 'Deal-in';

  @override
  String get selectDealer => 'Select Dealer';

  @override
  String get startGame => 'Start Game';

  @override
  String get gameOver => 'Game Over';

  @override
  String get totalWindRounds => 'Total Wind Rounds:';

  @override
  String get totalRoundsPlayed => 'Total Games Played:';

  @override
  String get totalGames => 'Total Games';

  @override
  String get finishGame => 'Finish Game';

  @override
  String get changePosition => 'Change Position';

  @override
  String swapPositionsContent(String p1, String p2) {
    return 'Swap positions of $p1 and $p2?';
  }

  @override
  String get swap => 'Swap';

  @override
  String get resetGameState => 'Reset Game State?';

  @override
  String get resetDealer => 'Reset Dealer Position';

  @override
  String get resetDealerSubtitle => 'Choose a new dealer';

  @override
  String get resetWind => 'Reset Wind Round';

  @override
  String get resetWindSubtitle => 'Reset to East 1';

  @override
  String get cancelReset => 'Cancel Reset';

  @override
  String get apply => 'Apply';

  @override
  String get currentGameStats => 'Current Game Stats';

  @override
  String get noRoundsPlayed => 'No rounds played yet.';

  @override
  String get mahjongScoringTitle => 'Mahjong Scoring';

  @override
  String get windEast => 'East';

  @override
  String get windSouth => 'South';

  @override
  String get windWest => 'West';

  @override
  String get windNorth => 'North';

  @override
  String roundInfo(String wind, int game) {
    return '$wind Round - Game $game';
  }

  @override
  String get calculate => 'Calculate';

  @override
  String get noResult => 'No Result';

  @override
  String gameCount(int count) {
    return 'Game $count';
  }

  @override
  String get mahjong => 'Mahjong';

  @override
  String get windCircleSuffix => ' Round';

  @override
  String get tooltipStats => 'Game Statistics';

  @override
  String get tooltipRules => 'Rules Reference';

  @override
  String get tooltipHome => 'Back to Home';

  @override
  String get loadFailed => 'Failed to load player groups: ';

  @override
  String get saveFailed => 'Failed to save: ';

  @override
  String get deleteFailed => 'Failed to delete: ';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get tryAgain => 'Please try again';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get moreLanguagesComingSoon => 'More languages coming soon...';

  @override
  String get rulesAndTutorial => 'Rules & Tutorial';

  @override
  String get rulesReference => 'Rules Reference';

  @override
  String get mahjongTutorial => 'Mahjong Tutorial';

  @override
  String get allFan => 'All';

  @override
  String get searchRules => 'Search Rules';

  @override
  String get tutorialWelcome => 'Welcome';

  @override
  String get tutorialTiles => 'Tiles';

  @override
  String get tutorialRules => 'Rules';

  @override
  String get rulesTitle => 'Rules';

  @override
  String get tutorialScore => 'Score';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get viewExample => 'View Example';

  @override
  String get hideExample => 'Hide Example';

  @override
  String get exampleExplanation => 'Example Explanation:';

  @override
  String get exampleTagConcealed => 'Concealed';

  @override
  String get exampleTagExposed => 'Exposed';

  @override
  String get exampleTagEyes => 'Eyes';

  @override
  String playerCount(int count) {
    return '$count players';
  }

  @override
  String roundOf(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String get welcomeTitle => 'Welcome to Mahjong Score Calculator';

  @override
  String get appDescription =>
      'Your all-in-one companion for Hong Kong Mahjong!';

  @override
  String get keyFeatures => 'Key Features:';

  @override
  String get smartCalculatorTitle => 'Smart Calculator';

  @override
  String get smartCalculatorDesc =>
      'Instantly calculate Fan and Score. Supports special hands like Thirteen Orphans and Nine Gates.';

  @override
  String get gameRecordingTitle => 'Game Recording';

  @override
  String get gameRecordingDesc =>
      'Track scores round-by-round. Auto-manages Dealer rotation and Round Winds.';

  @override
  String get rulesReferenceTitle => 'Rules Reference';

  @override
  String get rulesReferenceDesc =>
      'Complete guide to HK Mahjong scoring patterns with examples.';

  @override
  String get playerManagementTitle => 'Player Management';

  @override
  String get playerManagementDesc =>
      'Save player groups and keep track of total games played.';

  @override
  String get swipeToLearn => 'Swipe to learn the basics ->';

  @override
  String get tileTypesTitle => 'Types of Mahjong Tiles';

  @override
  String get characterTiles => 'Character Tiles';

  @override
  String get characterTilesDesc => 'Numbered 1 to 9 in characters';

  @override
  String get dotsTiles => 'Dots Tiles';

  @override
  String get dotsTilesDesc => 'Numbered 1 to 9 in dots';

  @override
  String get bambooTiles => 'Bamboo Tiles';

  @override
  String get bambooTilesDesc => 'Numbered 1 to 9 in bamboo';

  @override
  String get honorTiles => 'Honor Tiles';

  @override
  String get honorTilesDesc =>
      'Include Wind tiles (East/South/West/North) and Dragon tiles (Red/Green/White)';

  @override
  String get flowerTiles => 'Flower Tiles';

  @override
  String get flowerTilesDesc =>
      'Flowers (Plum, Orchid, Chrysanthemum, Bamboo) and Seasons (Spring, Summer, Autumn, Winter)';

  @override
  String get basicRulesTitle => 'Basic Rules';

  @override
  String get gameObjectiveTitle => '1. Game Objective';

  @override
  String get gameObjectiveDesc1 =>
      'The goal of mahjong is to form a complete hand, usually consisting of:';

  @override
  String get gameObjectiveDesc2 => '• 4 sets (chow/pong) + 1 pair (eyes)';

  @override
  String get gameObjectiveDesc3 => '• Special hands (e.g., Thirteen Orphans)';

  @override
  String get basicTermsTitle => '2. Basic Terms';

  @override
  String get basicTermsChow =>
      '• Chow: Three consecutive tiles (e.g., 1m-2m-3m)';

  @override
  String get basicTermsPong => '• Pong: Three identical tiles (e.g., 5p-5p-5p)';

  @override
  String get basicTermsEyes => '• Eyes: A pair of identical tiles';

  @override
  String get basicTermsSelfDraw => '• Self-Draw: Draw your own winning tile';

  @override
  String get basicTermsDiscard =>
      '• Discard: Discard a tile that lets others win';

  @override
  String get startingGameTitle => '3. Starting the Game';

  @override
  String get startingGameDesc =>
      'The Dealer (East) rolls 2 or 3 dice to determine which wall to break.';

  @override
  String get diceRollTableTitle => 'Dice Roll & Wall Selection:';

  @override
  String get counterClockwiseCount =>
      'Count counter-clockwise starting from Dealer as 1.';

  @override
  String get exampleRoll8 =>
      'Example: Roll 8 → Count to North (Left). Break North wall.';

  @override
  String get drawClockwise =>
      'From the chosen wall, count stacks clockwise (skipping the rolled number) to start drawing.';

  @override
  String get rememberDirection =>
      'Remember: Play Counter-Clockwise, Draw Clockwise!';

  @override
  String get dealingProcedureTitle => 'Dealing Procedure:';

  @override
  String get dealStep1 => '1. Each player takes 4 tiles (2 stacks) in order.';

  @override
  String get dealStep2 => '2. Repeat until everyone has 12 tiles.';

  @override
  String get dealStep3 =>
      '3. Dealer takes 1st and 3rd tile from end (14 total).';

  @override
  String get dealStep4 => '4. Others take 1 tile (13 total).';

  @override
  String get dealStep5 => '5. Replace Flower tiles from the back of the wall.';

  @override
  String get twGameObjectiveDesc1 => 'Taiwan Mahjong winning objective:';

  @override
  String get twGameObjectiveDesc2 =>
      '• 5 sets (chow/pong/kong) + 1 pair (eyes)';

  @override
  String get twGameObjectiveDesc3 =>
      '• 16 concealed tiles + 1 winning tile (17 tiles total)';

  @override
  String get twDealStep1 => '1. Each player takes 4 tiles (2 stacks) in order.';

  @override
  String get twDealStep2 => '2. Repeat until each player has 16 tiles.';

  @override
  String get twDealStep3 =>
      '3. Dealer starts with 17 tiles (first-turn draw included).';

  @override
  String get twDealStep4 =>
      '4. Replace Flower tiles from the back of the wall immediately.';

  @override
  String get twDealStep5 => '5. Dealer discards first to start the round.';

  @override
  String get gameplayProcessTitle => '4. Gameplay Process';

  @override
  String get gameplayProcessDesc =>
      'After dealing and flower replacement, the game proceeds counter-clockwise starting from the Dealer.';

  @override
  String get standardTurnTitle => 'Standard Turn:';

  @override
  String get drawAction => 'Draw';

  @override
  String get actionAction => 'Action';

  @override
  String get discardAction => 'Discard';

  @override
  String get turnStep1 =>
      '1. Draw a tile from the wall (Dealer skips this on first turn).';

  @override
  String get turnStep2 =>
      '2. If it\'s a Flower, reveal it and draw a replacement from the back.';

  @override
  String get turnStep3 =>
      '3. Choose to Kong (Concealed/Added) or Win (Self-Draw).';

  @override
  String get turnStep4 => '4. Discard one tile to end your turn.';

  @override
  String get interactionsTitle => 'Interactions (Stealing):';

  @override
  String get interactionsDesc =>
      'Other players can interrupt the turn by claiming a discard.';

  @override
  String get priorityRuleTitle => 'Priority Rule:';

  @override
  String get priorityRuleDesc => 'Win > Kong/Pong > Chow';

  @override
  String get priorityPongWins =>
      'If one player wants to Chow and another wants to Pong the same tile, Pong wins.';

  @override
  String get missedWinTitle => 'Missed Win Rule :';

  @override
  String get missedWinDesc =>
      'If you can win on a discard but choose not to (e.g., to try for a higher score), you cannot win on that same tile from another player until you complete your next turn (draw/action).';

  @override
  String get missedWinException =>
      'Exception: If the new tile gives you a higher Fan count (e.g., completing a specific pattern), you may be allowed to win depending on house rules.';

  @override
  String get actionChow => 'Chow ';

  @override
  String get targetLeftPlayer => 'Left Player Only';

  @override
  String get descChowInteract => 'Form a sequence (e.g., 1-2-3).';

  @override
  String get actionPong => 'Pong ';

  @override
  String get targetAnyPlayer => 'Any Player';

  @override
  String get descPongInteract =>
      'Form a triplet (e.g., 3-3-3). Interrupts turn order.';

  @override
  String get actionKong => 'Kong ';

  @override
  String get descKongInteract =>
      'Form a quad. Draw replacement. Interrupts turn order.';

  @override
  String get actionWinInteract => 'Win ';

  @override
  String get descWinInteract => 'Complete the hand. Ends the game.';

  @override
  String get scoringSystemTitle => 'Scoring System';

  @override
  String get scoringRulesTitle => 'Hong Kong Mahjong Scoring Rules';

  @override
  String get scoringRulesDesc =>
      'Mahjong scoring is determined by fan count. The table below shows the points for each fan count:';

  @override
  String get fanPointsHeader => 'Fan Points';

  @override
  String get byDiscardHeader => 'By Discard';

  @override
  String get bySelfDrawHeader => 'By Self-Draw';

  @override
  String get flowerTilesScoringTitle => 'Flower Tiles Scoring';

  @override
  String get noFlowersFan => '• No Flowers: 1 Fan';

  @override
  String get ownFlowerFan => '• Own Flower: 1 Fan (Flower matches seat wind)';

  @override
  String get flowerMapping => 'Flower Mapping:';

  @override
  String get seat1Flower => '• Seat 1 (East): Spring, Plum';

  @override
  String get seat2Flower => '• Seat 2 (South): Summer, Orchid';

  @override
  String get seat3Flower => '• Seat 3 (West): Autumn, Chrysanthemum';

  @override
  String get seat4Flower => '• Seat 4 (North): Winter, Bamboo';

  @override
  String get honorTilesScoringTitle => 'Honor Tiles Scoring';

  @override
  String get dragonPongFan =>
      '• Dragon Pong/Kong: 1 Fan (Red, Green, or White Dragon)';

  @override
  String get roundWindPongFan =>
      '• Round Wind Pong/Kong: 1 Fan (Matches the current round wind)';

  @override
  String get seatWindPongFan =>
      '• Seat Wind Pong/Kong: 1 Fan (Matches your seat wind)';

  @override
  String get winningPatternsTitle => 'Winning Patterns (Fan List)';

  @override
  String get winningPatternsDesc =>
      'Click on a pattern name to see details and examples.';

  @override
  String get chickenHand => '0 (Chicken)';

  @override
  String get naMinOne => 'N/A (min 1)';

  @override
  String get limitHand => '13 (Limit)';

  @override
  String get selectWinningHand => 'Select Winning Hand';

  @override
  String get maxTilesAlert => 'Cannot select more than 4 of the same tile';

  @override
  String get maxTotalTilesAlert => 'Maximum 18 tiles allowed';

  @override
  String get minTilesAlert => 'Select at least 14 tiles';

  @override
  String get selectedCount => 'Selected:';

  @override
  String get clear => 'Clear';

  @override
  String get charactersTab => 'Characters';

  @override
  String get dotsTab => 'Dots';

  @override
  String get bambooTab => 'Bamboo';

  @override
  String get honorsTab => 'Honors';

  @override
  String get invalidTileCount =>
      'Invalid number of tiles. Must be 14, 15, 16, 17, or 18.';

  @override
  String get winningHandThirteenOrphans => 'Winning Hand (Thirteen Orphans)!';

  @override
  String get winningHandSixteenNonMatching =>
      'Winning Hand (Sixteen Non-Matching)!';

  @override
  String get winningHand => 'Winning Hand!';

  @override
  String get winningHandInvalid =>
      'Cannot form a winning hand (4 sets + 1 pair).';

  @override
  String get gameHistoryTitle => 'Game History';

  @override
  String get noHistory => 'No history records';

  @override
  String gameIndex(int index) {
    return 'Game #$index';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get roundsLabel => 'Rounds';

  @override
  String get tipTitle => 'Tip:';

  @override
  String get splashTitle => 'Mahjong Calculator';

  @override
  String get splashSubtitle => 'Making Scoring Easier';

  @override
  String get tipDesc =>
      'Use this app\'s scoring feature to automatically calculate fan and score!';

  @override
  String get importantNoteTitle => 'Important Note:';

  @override
  String get flowerNote =>
      'If you have flowers but none match your seat (e.g., East seat holding Summer), you get 0 Fan for flowers and lose the \"No Flower\" bonus.';

  @override
  String get dragonNote =>
      'Note: If your seat wind matches the round wind (e.g., East Seat in East Round), a Pong of East Wind gives 2 Fan!';

  @override
  String get diceDealerEast => 'Dealer (East)';

  @override
  String get diceSouthRight => 'South (Right)';

  @override
  String get diceWestOpposite => 'West (Opposite)';

  @override
  String get diceNorthLeft => 'North (Left)';

  @override
  String defaultPlayerName(int index) {
    return 'Player $index';
  }

  @override
  String get loginTitle => 'Login';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get noAccountText => 'Don\'t have an account? Create one';

  @override
  String get hasAccountText => 'Already have an account? Login';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get setPassword => 'Set Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordMismatchError => 'Passwords do not match';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully';

  @override
  String get genericError => 'An unexpected error occurred';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String confirmDeleteContent(String name) {
    return 'Are you sure you want to delete group \"$name\"?';
  }

  @override
  String groupDeleted(String name) {
    return 'Group \"$name\" deleted';
  }

  @override
  String get savedGroupsTitle => 'Saved Player Groups';

  @override
  String get noAnySavedGroups => 'No saved player groups yet';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String get createdPrefix => 'Created: ';

  @override
  String get playersListPrefix => 'Players: ';

  @override
  String defaultGroupName(String timestamp) {
    return 'Group $timestamp';
  }

  @override
  String get twRulesTitle => 'Taiwan Mahjong Rules';

  @override
  String get hkRulesTitle => 'Hong Kong Mahjong Rules';

  @override
  String get hkMode => 'HK';

  @override
  String get twMode => 'TW';

  @override
  String get twScoringRulesTitle => 'Taiwan Mahjong Scoring Rules';

  @override
  String get twScoringRulesDesc =>
      'Taiwan Mahjong uses a Tai system. In this app\'s TW calculator, each Tai is fixed at 1 point, so total payment points are Base Tai plus Total Tai, with dealer bonus when applicable.';

  @override
  String get twTaiHeader => 'Tai Count';

  @override
  String get twScoreHeader => 'Score';

  @override
  String get twInstantPayTitle => 'Instant Payment Rules';

  @override
  String get twInstantPayDesc =>
      'Some events require immediate payment during gameplay, not just at settlement.';

  @override
  String get twChaseRule => 'Chase';

  @override
  String get twChaseDesc =>
      'When four players consecutively discard the same tile, the first player must pay each of the other three players one base amount.';

  @override
  String get twConcealedKongPay => 'Concealed Kong Payment';

  @override
  String get twConcealedKongPayDesc =>
      'When a player declares a concealed Kong, each of the other three players must pay one base amount. The Kong must be revealed at settlement; failure to do so incurs a 2× base penalty.';

  @override
  String get twFlowerSetPay => 'Flower Set Bonus';

  @override
  String get twFlowerSetPayDesc =>
      'One complete season set: each opponent pays half a base. One complete flower set: each opponent pays one base. Note: claiming flowers forfeits the season-set bonus.';

  @override
  String get twFlowerSeasonSetPay => 'Season Set Payment';

  @override
  String get twFlowerSeasonSetPayDesc =>
      'Collecting all 4 season tiles (Spring/Summer/Autumn/Winter). Each opponent pays the specified amount.';

  @override
  String get twFlowerGroupPay => 'Flower Group Payment';

  @override
  String get twFlowerGroupPayDesc =>
      'Collecting all 4 flower tiles (Plum/Orchid/Bamboo/Chrysanthemum). Each opponent pays the specified amount.';

  @override
  String get builtInPayment => 'Built-in';

  @override
  String get twFalseWinPay => 'False Win Penalty';

  @override
  String get twFalseWinPayDesc =>
      'A false win declaration usually costs \$100 per player. If the dealer makes a false win, they must continue as dealer.';

  @override
  String get twCalledPongPenalty => 'Called Pong Penalty';

  @override
  String get twCalledPongPenaltyDesc =>
      'If a player calls Pong but fails to execute, they must pay one base as a penalty placed in the center. The round winner collects it.';

  @override
  String get twPenaltiesTitle => 'Special Penalty Rules';

  @override
  String get twPenaltiesDesc =>
      'Rules regarding win eligibility and scoring penalties.';

  @override
  String get twWinPlacementRule => 'Win Tile Placement';

  @override
  String get twWinPlacementDesc =>
      'The winning tile must be placed separately, not mixed into your hand. Failure to do so invalidates the win.';

  @override
  String get twMissedWinRule => 'Missed Win Restriction';

  @override
  String get twMissedWinDesc =>
      'If you pass on a winning tile in a turn cycle, you cannot win on the same tile from another player until you complete your next draw.';

  @override
  String get twKongRevealRule => 'Concealed Kong Reveal';

  @override
  String get twKongRevealDesc =>
      'If you forget to reveal concealed Kongs at settlement, the penalty is doubled.';

  @override
  String get twDealerMarkerRule => 'Dealer Marker (Dice)';

  @override
  String get twDealerMarkerDesc =>
      'If the dealer forgets to place dice markers for consecutive deals, the consecutive dealer bonus cannot be counted when winning. However, if the dealer discards the winning tile, they still must pay the bonus.';

  @override
  String get twFlowerOrderRule => 'Flower Replacement Order';

  @override
  String get twFlowerOrderDesc =>
      'Opening flower replacement follows strict order. The dealer replaces first and says \'please\', then each player proceeds in turn. The dealer can only start playing after the last player finishes.';

  @override
  String get twLaSettlementTitle => 'La Settlement Rules';

  @override
  String get twLaSettlementDesc =>
      'A carry-over settlement system where debt is tracked from each round\'s Tai/Fan-unit result (not a base-money formula). Debt accumulates during a winning streak and is settled when the streak ends.';

  @override
  String get twLaMultiplier => 'Multiplier Effect (×1.5)';

  @override
  String get twLaMultiplierDesc =>
      'If the same player wins consecutively, each debtor\'s previous debt is multiplied by 1.5× before adding the new round\'s Tai/Fan-unit loss. Self-draw: all debtors compound. Discard: only the discarder compounds.';

  @override
  String get twLaReduction => 'Debt Reduction (÷2)';

  @override
  String get twLaReductionDesc =>
      'When the streak ends: if the streak winner discards the winning tile, or if a debtor self-draws, ONLY that specific player\'s debt is halved. Other debtors pay full.';

  @override
  String get twLaStopRule => 'Forced Stop Rule';

  @override
  String get twLaStopRuleDesc =>
      'If a player loses to the same streak winner at any multiple of 3 (3, 6, 9, ...), they can force an immediate full-debt settlement (no reduction opportunity).';

  @override
  String get twLaStopRuleTitle => 'Force Settlement';

  @override
  String twLaStopRuleMessage(
    String playerName,
    int lossCount,
    String streakWinnerName,
  ) {
    return '$playerName has lost $lossCount consecutive times to $streakWinnerName. Force settle debt now (no reduction chance)?';
  }

  @override
  String get twLaStopRuleContinue => 'Continue Playing';

  @override
  String get twLaStopRuleSettle => 'Force Settle';

  @override
  String get twLaApplied => 'La Carry-over';

  @override
  String get twLaMultiplierApplied => 'La ×1.5 carry-over';

  @override
  String get twLaReductionApplied => 'La debt halved';

  @override
  String get twLaCarryDebt => 'Carry-over debt from previous round';

  @override
  String get twLaDebtTracker => 'La Debt Tracker';

  @override
  String get twLaStreakWinner => 'Streak Winner';

  @override
  String get twLaDebtTotal => 'Total Debt';

  @override
  String get twLaDebtApplied => 'Already Applied';

  @override
  String get twLaDebtPending => 'Pending Settlement';

  @override
  String twLaLosses(int count) {
    return '$count losses';
  }

  @override
  String get twLaSettled => 'Settled';

  @override
  String get twLaForceSettleAction => 'Force Settle';

  @override
  String get twLaNoActiveStreak => 'No active La streak';

  @override
  String twLaStreakRounds(int count) {
    return '$count round streak';
  }

  @override
  String get twDealerBonusTitle => 'Dealer Bonus Rules';

  @override
  String get twDealerBonusDesc =>
      'The dealer gets extra Tai based on consecutive wins.';

  @override
  String get twDealerBonusBase => 'Being Dealer: +1 Tai';

  @override
  String get twDealerPaysExtra => 'Dealer Pays Extra';

  @override
  String get twDealerBonusFormula =>
      'Consecutive Dealer Formula: (Consecutive Count × 2) + 1';

  @override
  String get twDealerBonusExample1 => 'Consecutive 1: 3 Tai';

  @override
  String get twDealerBonusExample2 => 'Consecutive 2: 5 Tai';

  @override
  String get twDealerBonusExample3 => 'Consecutive 5: 11 Tai';

  @override
  String get twDealerBonusResponsibility =>
      'If another player self-draws or the dealer discards the winning tile, the dealer must pay the consecutive bonus Tai to the winner.';

  @override
  String get twNoStackRule =>
      'Note: Some Tai are mutually exclusive. For example, \'Missing One Suit\' cannot be stacked with \'Mixed One Suit\' or \'Pure One Suit\'.';

  @override
  String get twScoringFormulaTitle => 'Scoring Formula';

  @override
  String get twScoringFormulaDesc =>
      'Total Payment Points = Base Tai + Total Tai (Tai value fixed at 1)';

  @override
  String get twScoringExample =>
      'Example: Base Tai 5 and winning total Tai 13 => total payment points = 5 + 13 = 18';

  @override
  String get twScoringDefault =>
      'Default if not agreed: Base Tai = 5, Tai value fixed at 1 in TW calculation';

  @override
  String get twConcealedKongRule => 'Concealed Kong';

  @override
  String get twConcealedKongDesc =>
      'Declare a concealed Kong with 4 identical tiles in hand.';

  @override
  String get twConcealedKongExpl =>
      'Each opponent pays one base. Must be revealed at end of round; failure to reveal incurs double penalty.';

  @override
  String get twNoHonors => 'No Honors';

  @override
  String get twDescNoHonors =>
      'Hand contains no honor tiles (winds or dragons).';

  @override
  String get twExplNoHonors =>
      'The entire hand has no wind or dragon tiles. 1 Tai.';

  @override
  String get twNoHonorsNoFlowers => 'No Honors No Flowers';

  @override
  String get twDescNoHonorsNoFlowers =>
      'Hand contains no honor tiles and no flower tiles.';

  @override
  String get twExplNoHonorsNoFlowers =>
      'No wind, dragon, or flower tiles in the hand. 5 Tai.';

  @override
  String get twNoHonorsNoFlowersPingHu => 'Grand Ping Hu';

  @override
  String get twDescNoHonorsNoFlowersPingHu =>
      'No honors, no flowers, and qualifies as Ping Hu.';

  @override
  String get twExplNoHonorsNoFlowersPingHu =>
      'No honor tiles, no flowers, and the hand is all chows with a pair. 15 Tai.';

  @override
  String get twChickenHand => 'Chicken Hand';

  @override
  String get twDescChickenHand =>
      'A winning hand worth only 1 Tai (before dealer bonus).';

  @override
  String get twExplChickenHand =>
      'The base minimum win. Gets a fixed 10 Tai payout.';

  @override
  String get twDoublePong => 'Double Pong Wait';

  @override
  String get twDescDoublePong =>
      'Waiting on either of two pairs to become a pong for the win.';

  @override
  String get twExplDoublePong =>
      'Also known as a double-sided pong wait. 2 Tai.';

  @override
  String get twFakeSingle => 'Fake Single Wait';

  @override
  String get twDescFakeSingle =>
      'Could win on two sides but chose single/edge wait.';

  @override
  String get twExplFakeSingle =>
      'Waiting on a single tile when a two-sided wait was available. 1 Tai.';

  @override
  String get twTrueSingle => 'True Single Wait';

  @override
  String get twDescTrueSingle => 'Single tile wait, middle wait, or edge wait.';

  @override
  String get twExplTrueSingle =>
      'Winning on a single tile, closed wait, or edge wait. 2 Tai.';

  @override
  String get twOldYoung => 'Old & Young';

  @override
  String get twDescOldYoung =>
      'In one suit, must be either 1-2-3 + 7-8-9 or 1-1-1 + 9-9-9.';

  @override
  String get twExplOldYoung =>
      'Same-suit end combination (123+789 or 111+999). 3 Tai.';

  @override
  String get twExposedKong => 'Exposed Kong';

  @override
  String get twDescExposedKong =>
      'Four identical tiles with one claimed from another player.';

  @override
  String get twExplExposedKong =>
      'Declare a kong using a tile discarded by another player. 1 Tai.';

  @override
  String get twConcealedKongTai => 'Concealed Kong';

  @override
  String get twDescConcealedKongTai =>
      'Four identical tiles all drawn by yourself.';

  @override
  String get twExplConcealedKongTai =>
      'All four tiles drawn from the wall. 2 Tai.';

  @override
  String get twFlowerWin => 'Win on Flower Replacement';

  @override
  String get twDescFlowerWin =>
      'Self-draw win on the tile drawn to replace a flower.';

  @override
  String get twExplFlowerWin =>
      'Drawing a replacement tile for a flower and winning. 1 Tai.';

  @override
  String get twKongWin => 'Win on Kong Replacement';

  @override
  String get twDescKongWin =>
      'Self-draw win on the tile drawn after declaring a kong.';

  @override
  String get twExplKongWin =>
      'Drawing a replacement tile after a kong and winning. 1 Tai.';

  @override
  String get twRobbingKong => 'Robbing the Kong';

  @override
  String get twDescRobbingKong =>
      'Win on a tile another player uses to upgrade a pong to kong.';

  @override
  String get twExplRobbingKong =>
      'The player upgrading their pong is considered the discarder. Not counted as self-draw. 1 Tai.';

  @override
  String get twDoubleKongWin => 'Double Kong Win';

  @override
  String get twDescDoubleKongWin =>
      'Win after declaring two consecutive kongs.';

  @override
  String get twExplDoubleKongWin =>
      'Winning on the replacement tile after two consecutive kong declarations. 30 Tai.';

  @override
  String get twRobbingDoubleKong => 'Robbing Double Kong';

  @override
  String get twDescRobbingDoubleKong =>
      'Robbing a kong during a consecutive kong sequence.';

  @override
  String get twExplRobbingDoubleKong =>
      'Winning by robbing during consecutive kongs. 30 Tai.';

  @override
  String get twTwoConcealedPongs => 'Two Concealed Pongs';

  @override
  String get twDescTwoConcealedPongs =>
      'Two pongs formed entirely from self-drawn tiles.';

  @override
  String get twExplTwoConcealedPongs =>
      'Two concealed (self-drawn) pongs. 3 Tai.';

  @override
  String get twThreeConcealedPongs => 'Three Concealed Pongs';

  @override
  String get twDescThreeConcealedPongs =>
      'Three pongs formed entirely from self-drawn tiles.';

  @override
  String get twExplThreeConcealedPongs => 'Three concealed pongs. 10 Tai.';

  @override
  String get twFourConcealedPongs => 'Four Concealed Pongs';

  @override
  String get twDescFourConcealedPongs =>
      'Four pongs formed entirely from self-drawn tiles.';

  @override
  String get twExplFourConcealedPongs => 'Four concealed pongs. 30 Tai.';

  @override
  String get twIdenticalSequenceTwo => 'Two Identical Sequences';

  @override
  String get twDescIdenticalSequenceTwo =>
      'Two exactly identical chow sequences.';

  @override
  String get twExplIdenticalSequenceTwo =>
      'Two identical chows (same suit, same numbers). 3 Tai.';

  @override
  String get twIdenticalSequenceThree => 'Second Identical Sequences';

  @override
  String get twDescIdenticalSequenceThree =>
      'Three exactly identical chow sequences.';

  @override
  String get twExplIdenticalSequenceThree =>
      'Three identical chows. Open: 15 Tai, Concealed: 20 Tai.';

  @override
  String get twIdenticalSequenceFour => 'Third Identical Sequences';

  @override
  String get twDescIdenticalSequenceFour =>
      'Four exactly identical chow sequences.';

  @override
  String get twExplIdenticalSequenceFour => 'Four identical chows. 30 Tai.';

  @override
  String get twMixedDoubleSeq => 'Two Mixed Sequences';

  @override
  String get twDescMixedDoubleSeq =>
      'Same number sequences from two different suits.';

  @override
  String get twExplMixedDoubleSeq =>
      'Two chows with same numbers in different suits. 1 Tai.';

  @override
  String get twMixedTripleSeq => 'Three Mixed Sequences';

  @override
  String get twDescMixedTripleSeq =>
      'Same number sequences from three different suits.';

  @override
  String get twExplMixedTripleSeq =>
      'Three chows with same numbers in three suits. Open: 15 Tai, Concealed: 20 Tai.';

  @override
  String get twFiveIdenticalSeq => 'Five Identical Sequences';

  @override
  String get twDescFiveIdenticalSeq =>
      'Five sequences with the same numbers across suits.';

  @override
  String get twExplFiveIdenticalSeq =>
      'Five same-number sequences (includes 3-suit combo). 45 Tai.';

  @override
  String get twTwoBrothers => 'Two Brothers';

  @override
  String get twDescTwoBrothers =>
      'Two pongs of the same number in different suits.';

  @override
  String get twExplTwoBrothers => 'Same-number pongs in two suits. 3 Tai.';

  @override
  String get twSmallThreeBrothers => 'Small Three Brothers';

  @override
  String get twDescSmallThreeBrothers =>
      'Two same-number pongs plus a pair of the third suit.';

  @override
  String get twExplSmallThreeBrothers =>
      'Two pongs and one pair, all same number in three suits. 10 Tai.';

  @override
  String get twBigThreeBrothers => 'Big Three Brothers';

  @override
  String get twDescBigThreeBrothers =>
      'Three pongs of the same number in all three suits.';

  @override
  String get twExplBigThreeBrothers =>
      'Same-number pongs in all three suits. 15 Tai.';

  @override
  String get twSmallThreeSisters => 'Small Three Sisters';

  @override
  String get twDescSmallThreeSisters =>
      'Two consecutive pongs of same suit plus a consecutive pair.';

  @override
  String get twExplSmallThreeSisters =>
      'Two same-suit consecutive pongs and a consecutive pair. 8 Tai.';

  @override
  String get twBigThreeSisters => 'Big Three Sisters';

  @override
  String get twDescBigThreeSisters =>
      'Three consecutive pongs of the same suit.';

  @override
  String get twExplBigThreeSisters =>
      'Three same-suit consecutive pongs (e.g., 333-444-555). 15 Tai.';

  @override
  String get twFourToOne => 'Four-to-One';

  @override
  String get twDescFourToOne =>
      'Four identical tiles split across chow and pong sets.';

  @override
  String get twExplFourToOne => 'Open: 3 Tai, Concealed: 5 Tai.';

  @override
  String get twFourToTwo => 'Four-to-Two';

  @override
  String get twDescFourToTwo =>
      'Four identical tiles: two as the pair, two in chows.';

  @override
  String get twExplFourToTwo =>
      'Two of the same tile as pair, two in sequences. 10 Tai.';

  @override
  String get twFourToFour => 'Four-to-Four';

  @override
  String get twDescFourToFour =>
      'Four identical tiles all in separate chow sequences.';

  @override
  String get twExplFourToFour =>
      'All four of a tile distributed in sequences. 20 Tai.';

  @override
  String get twExposedDragon => 'Exposed Dragon';

  @override
  String get twDescExposedDragon =>
      'A 1-9 straight of one suit, partially claimed from others.';

  @override
  String get twExplExposedDragon =>
      'Complete 1-9 run of one suit with some tiles from others. 10 Tai.';

  @override
  String get twExposedMixedDragon => 'Exposed Mixed Dragon';

  @override
  String get twDescExposedMixedDragon =>
      'A 1-9 straight across different suits, partially claimed.';

  @override
  String get twExplExposedMixedDragon =>
      '1-9 run across suits with some tiles from others. 5 Tai.';

  @override
  String get twConcealedMixedDragon => 'Concealed Mixed Dragon';

  @override
  String get twDescConcealedMixedDragon =>
      'A 1-9 straight across different suits, all self-drawn.';

  @override
  String get twExplConcealedMixedDragon =>
      '1-9 run across suits, entirely concealed. 10 Tai.';

  @override
  String get twFiveGates => 'Five Gates';

  @override
  String get twDescFiveGates =>
      'Hand contains all five tile types: man, pin, sou, wind, dragon.';

  @override
  String get twExplFiveGates => 'Having tiles from all five categories. 5 Tai.';

  @override
  String get twMissingOneSuit => 'Missing One Suit';

  @override
  String get twDescMissingOneSuit =>
      'Hand is missing one of the three number suits.';

  @override
  String get twExplMissingOneSuit =>
      'Lacking bamboo, dots, or characters entirely. 3 Tai.';

  @override
  String get twAllRevealed => 'All Revealed (Full Exposed)';

  @override
  String get twDescAllRevealed =>
      'All sets are exposed (chow/pong/kong), win by discard only.';

  @override
  String get twExplAllRevealed =>
      'Single tile wait with all groups exposed, win by discard. 15 Tai.';

  @override
  String get twHalfRevealed => 'Half Revealed';

  @override
  String get twDescHalfRevealed =>
      'All sets are exposed, win by self-draw on single wait.';

  @override
  String get twExplHalfRevealed =>
      'All groups exposed but winning by self-draw. 8 Tai.';

  @override
  String get twLastSevenTiles => 'Last 7 Tiles';

  @override
  String get twDescLastSevenTiles =>
      'Win when only 7 tiles remain in the wall.';

  @override
  String get twExplLastSevenTiles =>
      'Winning within the last 7 remaining tiles. 20 Tai.';

  @override
  String get twLastTenTiles => 'Last 10 Tiles';

  @override
  String get twDescLastTenTiles => 'Win when only 10 tiles remain in the wall.';

  @override
  String get twExplLastTenTiles =>
      'Winning within the last 10 remaining tiles. 10 Tai.';

  @override
  String get twSmallThreeWinds => 'Small Three Winds';

  @override
  String get twDescSmallThreeWinds => 'Two wind pongs and one wind pair.';

  @override
  String get twExplSmallThreeWinds =>
      'Two pongs and one pair of wind tiles. 15 Tai.';

  @override
  String get twBigThreeWinds => 'Big Three Winds';

  @override
  String get twDescBigThreeWinds => 'Three wind pongs.';

  @override
  String get twExplBigThreeWinds => 'Three pongs of wind tiles. 30 Tai.';

  @override
  String get twSixteenNonMatching => 'Sixteen Non-Matching';

  @override
  String get twDescSixteenNonMatching =>
      '16 tiles with specific spacing that cannot form any set.';

  @override
  String get twExplSixteenNonMatching =>
      'A special hand of 16 tiles that form no valid sets. 50 Tai.';

  @override
  String get twOneFlowerSet => 'One Flower Set';

  @override
  String get twDescOneFlowerSet =>
      'Collected all 4 tiles of one flower series.';

  @override
  String get twExplOneFlowerSet =>
      'A complete season (Spring/Summer/Fall/Winter) or plant (Plum/Orchid/Bamboo/Chrysanthemum) set. 10 Tai.';

  @override
  String get twTwoFlowerSets => 'Two Flower Sets (Flower Win)';

  @override
  String get twDescTwoFlowerSets =>
      'Collected all 8 flower tiles. Instant win.';

  @override
  String get twExplTwoFlowerSets =>
      'Having all 8 flowers is an instant win. 30 Tai. Hand tiles do not count.';

  @override
  String get twMixedTerminalsPongs => 'Mixed Terminals';

  @override
  String get twDescMixedTerminalsPongs =>
      'All sets contain 1/9 or honor tiles.';

  @override
  String get twExplMixedTerminalsPongs =>
      'Every set includes a terminal (1,9) or honor tile. 30 Tai.';

  @override
  String get twPureTerminalsTw => 'Pure Terminals';

  @override
  String get twDescPureTerminalsTw => 'All tiles are 1s and 9s only.';

  @override
  String get twExplPureTerminalsTw =>
      'Entire hand made of 1 and 9 tiles only. 80 Tai.';

  @override
  String get twMixedTerminalChows => 'Mixed Terminal Chows';

  @override
  String get twDescMixedTerminalChows =>
      'Every group contains a terminal (1/9) or honors, and honors must be present.';

  @override
  String get twExplMixedTerminalChows =>
      'Every group (chow, pong, pair) includes a terminal or honors, with honors present. 10 Tai.';

  @override
  String get twPureTerminalChows => 'Pure Terminal Chows';

  @override
  String get twDescPureTerminalChows =>
      'Every group contains a terminal (1/9), with no honors.';

  @override
  String get twExplPureTerminalChows =>
      'Every group (chow, pong, pair) includes a terminal, with no honors. 15 Tai.';

  @override
  String get twQuanHunYao => 'Pure Terminal Groups';

  @override
  String get twDescQuanHunYao =>
      'Every group contains a terminal (1 or 9), no honors. Any composition.';

  @override
  String get twExplQuanHunYao =>
      'Every group (chow, pong, pair) includes a terminal tile, no honors. 15 Tai.';

  @override
  String get twBanDaiHunYao => 'Mixed Terminal Groups';

  @override
  String get twDescBanDaiHunYao =>
      'Every group contains a terminal (1/9) or honor. Must have honors.';

  @override
  String get twExplBanDaiHunYao =>
      'Every group includes a terminal or honor tile, with honors present. 10 Tai.';

  @override
  String get twHumanWin => 'Human Win';

  @override
  String get twDescHumanWin =>
      'Non-dealer wins by discard in the first turn cycle.';

  @override
  String get twExplHumanWin =>
      'A non-dealer wins on a discard during the very first go-around. 80 Tai.';

  @override
  String get twSevenRobOne => 'Seven Rob One';

  @override
  String get twDescSevenRobOne =>
      'With 7 flower tiles, win the 8th from another player.';

  @override
  String get twExplSevenRobOne =>
      'Having 7 flowers and claiming the last one from another player. 15 Tai.';

  @override
  String get twHeavenlyReady => 'Heavenly Ready';

  @override
  String get twDescHeavenlyReady =>
      'Dealer declares ready on opening hand (includes Ding bonus).';

  @override
  String get twExplHeavenlyReady =>
      'Dealer declares Tenpai immediately. Includes the 5 Tai for Ding. 50 Tai.';

  @override
  String get twEarthlyReady => 'Earthly Ready';

  @override
  String get twDescEarthlyReady =>
      'Non-dealer declares ready on first draw (includes Ding bonus).';

  @override
  String get twExplEarthlyReady =>
      'Non-dealer declares Tenpai on first turn. Includes 5 Tai for Ding. 25 Tai.';

  @override
  String get twMiguiTw => 'Eight Pairs';

  @override
  String get twDescMiguiTw => 'Eight pairs in hand (no triplets allowed).';

  @override
  String get twExplMiguiTw =>
      'Eight distinct pairs. Cannot have three of the same tile melded. 40 Tai.';

  @override
  String get twStackRulesTitle => 'Stacking Rules';

  @override
  String get twStackRulesDesc =>
      'Some Tai combinations cannot be counted together. Higher-level patterns override lower ones.';

  @override
  String get twStackRule1 =>
      'Five Identical Seq. already includes Three Mixed Seq., Two/Three/Four Identical Seq.';

  @override
  String get twStackRule2 =>
      'Missing One Suit cannot be stacked with Mixed One Suit or Pure One Suit.';

  @override
  String get twStackRule3 =>
      'Heavenly Ready (50) and Earthly Ready (25) already include Ding (5).';

  @override
  String get twStackRule4 =>
      'Two Flower Sets (Flower Win, 30) overrides One Flower Set only; other hand patterns may still count.';

  @override
  String get twStackRule5 =>
      'Pure One Suit (80) overrides Mixed One Suit; No Honors may still be counted.';

  @override
  String get twStackRule6 =>
      'Robbing Kong is not counted as self-draw; the kong player pays.';

  @override
  String get twStackRule7 =>
      'Chicken Hand (10) only applies when hand is worth exactly 1 Tai before dealer bonus.';

  @override
  String get achvTitle => 'Achievements';

  @override
  String get achvUnlocked => 'Unlocked';

  @override
  String get achvLocked => 'Locked';

  @override
  String achvProgress(String current, String target) {
    return '$current/$target';
  }

  @override
  String achvUnlockedAt(String date) {
    return 'Unlocked on $date';
  }

  @override
  String get achvNewUnlock => 'Achievement Unlocked!';

  @override
  String get achvViewAll => 'View Achievements';

  @override
  String get achvTabAll => 'All';

  @override
  String get achvTabGeneral => 'General';

  @override
  String get achvTabHk => 'HK';

  @override
  String get achvTabTw => 'TW';

  @override
  String get achvTabMilestone => 'Milestone';

  @override
  String get achvTierBronze => 'Bronze';

  @override
  String get achvTierSilver => 'Silver';

  @override
  String get achvTierGold => 'Gold';

  @override
  String get achvTierDiamond => 'Diamond';

  @override
  String achvSummary(String unlocked, String total) {
    return '$unlocked / $total';
  }

  @override
  String get achvGenFirstGameTitle => 'Beginner';

  @override
  String get achvGenFirstGameDesc => 'Complete your first round';

  @override
  String get achvGenTenGamesTitle => 'Veteran';

  @override
  String get achvGenTenGamesDesc => 'Complete 10 rounds';

  @override
  String get achvGenHundredGamesTitle => 'General';

  @override
  String get achvGenHundredGamesDesc => 'Complete 100 rounds';

  @override
  String get achvGenFirstWinTitle => 'First Joy';

  @override
  String get achvGenFirstWinDesc => 'Win a round for the first time';

  @override
  String get achvGenWinStreak3Title => 'Win Streak';

  @override
  String get achvGenWinStreak3Desc => 'Win 3 rounds in a row';

  @override
  String get achvGenWinStreak5Title => 'Dominant';

  @override
  String get achvGenWinStreak5Desc => 'Win 5 rounds in a row';

  @override
  String get achvGenSelfDraw10Title => 'Self-Draw Expert';

  @override
  String get achvGenSelfDraw10Desc => 'Self-draw win 10 times';

  @override
  String get achvGenSelfDraw50Title => 'Self-Draw King';

  @override
  String get achvGenSelfDraw50Desc => 'Self-draw win 50 times';

  @override
  String get achvGenDealerStreak3Title => 'Dealer Overlord';

  @override
  String get achvGenDealerStreak3Desc => 'Win as dealer 3 times in a row';

  @override
  String get achvGenNeverDealInTitle => 'Iron Wall';

  @override
  String get achvGenNeverDealInDesc =>
      'Complete a full game without dealing in';

  @override
  String get achvGenComebackTitle => 'Great Comeback';

  @override
  String get achvGenComebackDesc =>
      'Go from last place to first in the final round';

  @override
  String get achvHkFirstWinTitle => 'HK Debut';

  @override
  String get achvHkFirstWinDesc => 'Win your first round in Hong Kong mode';

  @override
  String get achvHkFan3Title => '3 Fan Starter';

  @override
  String get achvHkFan3Desc => 'Win with 3 or more Fan';

  @override
  String get achvHkFullFlushTitle => 'Full Flush Master';

  @override
  String get achvHkFullFlushDesc => 'Win with Full Flush';

  @override
  String get achvHkAllPongs5Title => 'Pong Enthusiast';

  @override
  String get achvHkAllPongs5Desc => 'Win with All Pongs 5 times';

  @override
  String get achvHkBigThreeDragonsTitle => 'Big Three Dragons';

  @override
  String get achvHkBigThreeDragonsDesc => 'Win with Big Three Dragons';

  @override
  String get achvHkBigFourWindsTitle => 'Big Four Winds';

  @override
  String get achvHkBigFourWindsDesc => 'Win with Big Four Winds';

  @override
  String get achvHkThirteenOrphansTitle => 'Thirteen Orphans';

  @override
  String get achvHkThirteenOrphansDesc => 'Win with Thirteen Orphans';

  @override
  String get achvHkNineGatesTitle => 'Nine Gates';

  @override
  String get achvHkNineGatesDesc => 'Win with Nine Gates';

  @override
  String get achvHkConcealedHand10Title => 'Concealed Master';

  @override
  String get achvHkConcealedHand10Desc => 'Win with concealed hand 10 times';

  @override
  String get achvHkLastTileWinTitle => 'Under the Sea';

  @override
  String get achvHkLastTileWinDesc => 'Win by drawing the last tile';

  @override
  String get achvHkRobbingKongTitle => 'Robbing Kong';

  @override
  String get achvHkRobbingKongDesc => 'Win by robbing a Kong';

  @override
  String get achvHkMaxFanTitle => 'Maximum Fan';

  @override
  String get achvHkMaxFanDesc => 'Reach the maximum fan cap';

  @override
  String get achvTwFirstWinTitle => 'TW Debut';

  @override
  String get achvTwFirstWinDesc => 'Win your first round in Taiwan mode';

  @override
  String get achvTwTai10Title => '10 Tai Reached';

  @override
  String get achvTwTai10Desc => 'Win with 10 or more Tai';

  @override
  String get achvTwTai30Title => '30 Tai Luxury';

  @override
  String get achvTwTai30Desc => 'Win with 30 or more Tai';

  @override
  String get achvTwTai80Title => '80 Tai Legend';

  @override
  String get achvTwTai80Desc => 'Win with 80 or more Tai';

  @override
  String get achvTwCommonHand10Title => 'Ping Hu Expert';

  @override
  String get achvTwCommonHand10Desc => 'Win with Ping Hu 10 times';

  @override
  String get achvTwConcealedSelfDrawn5Title => 'Concealed Self-Draw';

  @override
  String get achvTwConcealedSelfDrawn5Desc => 'Win concealed self-draw 5 times';

  @override
  String get achvTwDealerStreak5Title => 'Dealer Tyrant';

  @override
  String get achvTwDealerStreak5Desc => 'Win as dealer 5 times in a row';

  @override
  String get achvTwKongWinTitle => 'Kong Win';

  @override
  String get achvTwKongWinDesc => 'Win on Kong replacement';

  @override
  String get achvTwFlowerWinTitle => 'Flower Win';

  @override
  String get achvTwFlowerWinDesc => 'Win by Flower Win or Two Flower Sets';

  @override
  String get achvTwSevenRobOneTitle => 'Seven Rob One';

  @override
  String get achvTwSevenRobOneDesc => 'Win by Seven Rob One';

  @override
  String get achvTwHeavenlyListenTitle => 'Heavenly Listen';

  @override
  String get achvTwHeavenlyListenDesc => 'Achieve Heavenly Ready';

  @override
  String get achvTwChickenHand10Title => 'Chicken King';

  @override
  String get achvTwChickenHand10Desc => 'Win with Chicken Hand 10 times';

  @override
  String get achvTwLikulikuTitle => 'Likuliku';

  @override
  String get achvTwLikulikuDesc => 'Win with Eight Pairs';

  @override
  String get achvMsWins100Title => '100 Wins';

  @override
  String get achvMsWins100Desc => 'Win 100 rounds total';

  @override
  String get achvMsWins500Title => '500 Wins';

  @override
  String get achvMsWins500Desc => 'Win 500 rounds total';

  @override
  String get achvMsScore10000Title => '10K Score';

  @override
  String get achvMsScore10000Desc => 'Accumulate 10,000 total score';

  @override
  String get achvMsScore100000Title => '100K Score';

  @override
  String get achvMsScore100000Desc => 'Accumulate 100,000 total score';

  @override
  String get achvMsDualModeTitle => 'Dual Player';

  @override
  String get achvMsDualModeDesc => 'Play 10+ rounds in both HK and TW mode';

  @override
  String get continueLastGame => 'Continue Game';

  @override
  String get greetingMorning => 'Good morning! Ready for a round?';

  @override
  String get greetingAfternoon => 'Good afternoon! Time to play?';

  @override
  String get greetingEvening => 'Good evening! Perfect time for mahjong.';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get hkQuickStart => 'Hong Kong\nMahjong';

  @override
  String get twQuickStart => 'Taiwan\nMahjong';

  @override
  String get dailyTipLabel => '💡 Daily Tip:';

  @override
  String get tipDayTitle1 => 'Chicken Hand';

  @override
  String get tipDayContent1 =>
      'In HK mahjong, a Chicken Hand means winning with 0 fan, which is often not allowed under minimum-fan rules.';

  @override
  String get tipDayTitle2 => 'Flowers & Seasons';

  @override
  String get tipDayContent2 =>
      'Taiwan mahjong uses 16 tiles per player. Flowers and seasons are bonus tiles that give extra fan automatically.';

  @override
  String get tipDayTitle3 => 'All Pongs';

  @override
  String get tipDayContent3 =>
      'A hand made entirely of Pong and Kong sets with no Chow is called All Pongs, worth 3 fan in HK rules.';

  @override
  String get tipDayTitle4 => 'Concealed Hand';

  @override
  String get tipDayContent4 =>
      'Winning without any open melds is a Concealed Hand. It is worth 1 fan in HK and higher in TW rules.';

  @override
  String get tipDayTitle5 => 'Dealer Advantage';

  @override
  String get tipDayContent5 =>
      'The dealer receives and pays double in many rule sets. Winning as dealer lets you keep the deal.';

  @override
  String get tipDayTitle6 => 'Half Flush';

  @override
  String get tipDayContent6 =>
      'Half Flush uses one suit plus honor tiles. It is one of the most common high-scoring hands at 3 fan.';

  @override
  String get tipDayTitle7 => 'Full Flush';

  @override
  String get tipDayContent7 =>
      'Full Flush uses only one suit with no honors and is worth 7 fan in HK rules. It is hard to conceal.';

  @override
  String get tipDayTitle8 => 'Self-Draw Bonus';

  @override
  String get tipDayContent8 =>
      'Winning by self-draw adds extra fan in most rule sets and means all other players pay you.';

  @override
  String get tipDayTitle9 => 'Thirteen Orphans';

  @override
  String get tipDayContent9 =>
      'Thirteen Orphans requires one of each terminal and honor tile plus one duplicate, which is a limit hand.';

  @override
  String get tipDayTitle10 => 'La Rule';

  @override
  String get tipDayContent10 =>
      'In Taiwan mahjong, the La rule multiplies carry-over debts by 1.5× when the same player wins consecutively.';

  @override
  String get customFanValues => 'Custom Fan/Tai Values';

  @override
  String get customFanValuesDesc =>
      'Customize scoring values for individual rules';

  @override
  String get customHkFan => 'Hong Kong Fan Values';

  @override
  String get customTwTai => 'Taiwan Tai Values';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetFanConfirm => 'Reset all custom fan/tai values to default?';

  @override
  String get customized => 'Customized';

  @override
  String defaultValue(int value) {
    return 'Default: $value';
  }

  @override
  String get gamePreferences => 'Game Preferences';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get accountSettings => 'Account';

  @override
  String get noCustomizations =>
      'No customizations yet. Tap a rule to change its fan/tai value.';

  @override
  String get editFanValue => 'Edit Fan Value';

  @override
  String get editTaiValue => 'Edit Tai Value';

  @override
  String get enterNewValue => 'Enter new value (0-13)';

  @override
  String get enterNewTaiValue => 'Enter new value (0-100)';

  @override
  String get invalidValue => 'Please enter a valid number';

  @override
  String get customFanSaved => 'Custom value saved';

  @override
  String get allReset => 'All values reset to default';

  @override
  String get hkGameSettings => 'HK Mahjong Settings';

  @override
  String get twGameSettings => 'TW Mahjong Settings';

  @override
  String get hkMinFan => 'Minimum Fan';

  @override
  String get hkMaxFan => 'Maximum Fan';

  @override
  String hkMinFanReselect(int minFan) {
    return 'Winning hand is below the minimum fan ($minFan). Please reselect.';
  }

  @override
  String get twBaseTaiSetting => 'Base Tai';

  @override
  String get twTaiValueSetting => 'Value per Tai';

  @override
  String get addRule => 'Add Rule';

  @override
  String get deleteRule => 'Delete Rule';

  @override
  String get ruleName => 'Rule Name';

  @override
  String get fanValueLabel => 'Fan Value';

  @override
  String get taiValueLabel => 'Tai Value';

  @override
  String get addCustomRule => 'Add Custom Rule';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this rule?';

  @override
  String get ruleDeleted => 'Rule deleted';

  @override
  String get ruleAdded => 'Rule added';

  @override
  String get ruleRestored => 'Rule restored';

  @override
  String get deletedRules => 'Deleted Rules';

  @override
  String get restore => 'Restore';

  @override
  String get customRules => 'Custom Rules';

  @override
  String get builtInRules => 'Built-in Rules';

  @override
  String get twPayments => 'TW Real-time Payments';

  @override
  String get twPaymentsDesc =>
      'Configure real-time payment items for TW Mahjong';

  @override
  String get paymentName => 'Payment Name';

  @override
  String get paymentValue => 'Payment Value';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get editPayment => 'Edit Payment';

  @override
  String get noPayments => 'No payment items configured';

  @override
  String get paymentSaved => 'Payment saved';

  @override
  String get paymentDeleted => 'Payment deleted';

  @override
  String get enterRuleName => 'Enter rule name';

  @override
  String get enterValue => 'Enter value';

  @override
  String get instantPayment => 'Instant Payment';

  @override
  String get selectPayer => 'Who pays?';

  @override
  String get selectReceiver => 'Who receives?';

  @override
  String get selectPaymentItem => 'Select payment item';

  @override
  String get paymentAmount => 'Amount';

  @override
  String get paymentApplied => 'Payment applied';

  @override
  String get allOtherPlayers => 'All other players';

  @override
  String get customAmount => 'Custom amount';

  @override
  String get achvTwInstantPay5Title => 'Quick Pay';

  @override
  String get achvTwInstantPay5Desc => 'Apply 5 instant payments in TW mahjong';

  @override
  String get achvTwInstantPay20Title => 'Payment Master';

  @override
  String get achvTwInstantPay20Desc =>
      'Apply 20 instant payments in TW mahjong';

  @override
  String userSetFan(int f) {
    return 'User Set $f Fan';
  }

  @override
  String userSetTai(int f) {
    return 'User Set $f Tai';
  }

  @override
  String get roundHistory => 'Round History';

  @override
  String get seatOrder => 'Seat Order';

  @override
  String get dragToReorder => 'Hold & drag to reorder seats';

  @override
  String get recentPlayers => 'Recent Players';

  @override
  String get duplicateNameWarning => 'Duplicate name detected';

  @override
  String windSeat(String wind) {
    return '$wind Seat';
  }

  @override
  String get tapToEdit => 'Tap name to edit';

  @override
  String get playerSetupSubtitle => 'Set up your table';

  @override
  String get clearName => 'Clear';

  @override
  String get tileSelectionTitle => 'Select Hand';

  @override
  String get concealedTarget => 'Concealed';

  @override
  String get winTarget => 'Win';

  @override
  String get dingLabel => 'Ding';

  @override
  String get chowButton => '+ Chow';

  @override
  String get pongButton => '+ Pong';

  @override
  String get exposedKongButton => '+ Exp Kong';

  @override
  String get concealedKongButton => '+ Con Kong';

  @override
  String get exposedZoneLabel => 'Exposed';

  @override
  String get concealedZoneLabel => 'Concealed';

  @override
  String get winningTileZoneLabel => 'Winning Tile';

  @override
  String get noExposedMelds => 'No exposed melds';

  @override
  String get noConcealedTiles => 'No concealed tiles';

  @override
  String get tapWinToPickTile => 'Tap Win then pick a tile';

  @override
  String get selectWinningTileMsg => 'Please select a winning tile';

  @override
  String get selectAtLeastTilesMsg => 'Select at least 17 tiles';

  @override
  String needTilesMsg(int expected, int current) {
    return 'Need $expected tiles, have $current';
  }

  @override
  String buildingMeld(String type, int count, int needed) {
    return 'Building $type: $count/$needed tiles';
  }

  @override
  String get invalidMeld => 'Invalid meld — please try again';

  @override
  String get chowName => 'Chow';

  @override
  String get pongName => 'Pong';

  @override
  String get kongName => 'Kong';

  @override
  String get exposedKongName => 'Exposed Kong';

  @override
  String get concealedKongName => 'Concealed Kong';

  @override
  String get twDingBonus => 'Ding Bonus';
}
