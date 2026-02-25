import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_gen_en.dart';
import 'app_localizations_gen_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations_gen.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahjong Score Calculator'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahjong Calculator'**
  String get homeTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'History feature coming soon...'**
  String get historyComingSoon;

  /// No description provided for @testFirebase.
  ///
  /// In en, this message translates to:
  /// **'Test Firebase'**
  String get testFirebase;

  /// No description provided for @firebaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Firebase connected: '**
  String get firebaseSuccess;

  /// No description provided for @firebaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Firebase failed: '**
  String get firebaseFailed;

  /// No description provided for @savedGroups.
  ///
  /// In en, this message translates to:
  /// **'Saved Player Groups'**
  String get savedGroups;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noSavedGroups.
  ///
  /// In en, this message translates to:
  /// **'No saved player groups'**
  String get noSavedGroups;

  /// No description provided for @createFirstGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first group to get started'**
  String get createFirstGroupHint;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Player Group'**
  String get createGroup;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'players'**
  String get players;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created: '**
  String get createdAt;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All Player Groups'**
  String get allGroups;

  /// No description provided for @editGroupComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit group feature coming soon...'**
  String get editGroupComingSoon;

  /// No description provided for @scoreUpdated.
  ///
  /// In en, this message translates to:
  /// **'Score updated for group: '**
  String get scoreUpdated;

  /// No description provided for @playerSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Player Setup'**
  String get playerSetupTitle;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get groupNameHint;

  /// No description provided for @groupNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get groupNameError;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player Name'**
  String get playerName;

  /// No description provided for @playerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter player name'**
  String get playerNameHint;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayer;

  /// No description provided for @minimumPlayers.
  ///
  /// In en, this message translates to:
  /// **'At least 2 players required'**
  String get minimumPlayers;

  /// No description provided for @duplicatePlayer.
  ///
  /// In en, this message translates to:
  /// **'Player already exists'**
  String get duplicatePlayer;

  /// No description provided for @saveGroup.
  ///
  /// In en, this message translates to:
  /// **'Save Group'**
  String get saveGroup;

  /// No description provided for @saveAndPlay.
  ///
  /// In en, this message translates to:
  /// **'Save & Play'**
  String get saveAndPlay;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @playerList.
  ///
  /// In en, this message translates to:
  /// **'Player List'**
  String get playerList;

  /// No description provided for @groupSaved.
  ///
  /// In en, this message translates to:
  /// **'Group saved successfully!'**
  String get groupSaved;

  /// No description provided for @groupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save group'**
  String get groupSaveFailed;

  /// No description provided for @minFan.
  ///
  /// In en, this message translates to:
  /// **'Min Fan'**
  String get minFan;

  /// No description provided for @maxFan.
  ///
  /// In en, this message translates to:
  /// **'Max Fan'**
  String get maxFan;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No Limit'**
  String get noLimit;

  /// No description provided for @fanLimitSettings.
  ///
  /// In en, this message translates to:
  /// **'Fan Range Settings'**
  String get fanLimitSettings;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @hongKongMahjong.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Style (13 Tiles)'**
  String get hongKongMahjong;

  /// No description provided for @taiwaneseMahjong.
  ///
  /// In en, this message translates to:
  /// **'Taiwan Style (16 Tiles)'**
  String get taiwaneseMahjong;

  /// No description provided for @baseTai.
  ///
  /// In en, this message translates to:
  /// **'Base Tai'**
  String get baseTai;

  /// No description provided for @taiValue.
  ///
  /// In en, this message translates to:
  /// **'Score per Tai'**
  String get taiValue;

  /// No description provided for @tai.
  ///
  /// In en, this message translates to:
  /// **'Tai'**
  String get tai;

  /// No description provided for @scoreRecording.
  ///
  /// In en, this message translates to:
  /// **'Score Recording'**
  String get scoreRecording;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @ofSeparator.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofSeparator;

  /// No description provided for @dealer.
  ///
  /// In en, this message translates to:
  /// **'Dealer'**
  String get dealer;

  /// No description provided for @calculateScore.
  ///
  /// In en, this message translates to:
  /// **'Calculate Score'**
  String get calculateScore;

  /// No description provided for @endGame.
  ///
  /// In en, this message translates to:
  /// **'End Game'**
  String get endGame;

  /// No description provided for @gameResults.
  ///
  /// In en, this message translates to:
  /// **'Game Results'**
  String get gameResults;

  /// No description provided for @finalScores.
  ///
  /// In en, this message translates to:
  /// **'Final Scores'**
  String get finalScores;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next Round'**
  String get nextRound;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @roundsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Rounds Played'**
  String get roundsPlayed;

  /// No description provided for @selfDrawn.
  ///
  /// In en, this message translates to:
  /// **'Self-Drawn'**
  String get selfDrawn;

  /// No description provided for @winningRate.
  ///
  /// In en, this message translates to:
  /// **'Winning Rate'**
  String get winningRate;

  /// No description provided for @fan.
  ///
  /// In en, this message translates to:
  /// **'{f} Fan'**
  String fan(int f);

  /// No description provided for @taiCount.
  ///
  /// In en, this message translates to:
  /// **'{t} Tai'**
  String taiCount(int t);

  /// No description provided for @totalFan.
  ///
  /// In en, this message translates to:
  /// **'Total Fan'**
  String get totalFan;

  /// No description provided for @totalTai.
  ///
  /// In en, this message translates to:
  /// **'Total Tai'**
  String get totalTai;

  /// No description provided for @scoreCalculation.
  ///
  /// In en, this message translates to:
  /// **'Score Calculation'**
  String get scoreCalculation;

  /// No description provided for @enterScores.
  ///
  /// In en, this message translates to:
  /// **'Enter Scores'**
  String get enterScores;

  /// No description provided for @specialWinningCondition.
  ///
  /// In en, this message translates to:
  /// **'Special Winning Condition'**
  String get specialWinningCondition;

  /// No description provided for @currentScore.
  ///
  /// In en, this message translates to:
  /// **'(Current: {score} pts)'**
  String currentScore(int score);

  /// No description provided for @totalWin.
  ///
  /// In en, this message translates to:
  /// **'(Total: {score})'**
  String totalWin(int score);

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @totalMustBeZero.
  ///
  /// In en, this message translates to:
  /// **'Total must be zero'**
  String get totalMustBeZero;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm non-zero total?'**
  String get confirmSubmit;

  /// No description provided for @totalIs.
  ///
  /// In en, this message translates to:
  /// **'Total is '**
  String get totalIs;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get continueAnyway;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get win;

  /// No description provided for @selfDraw.
  ///
  /// In en, this message translates to:
  /// **'Self-Draw'**
  String get selfDraw;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @winningPlayer.
  ///
  /// In en, this message translates to:
  /// **'Winning Player'**
  String get winningPlayer;

  /// No description provided for @discardPlayer.
  ///
  /// In en, this message translates to:
  /// **'Discard Player'**
  String get discardPlayer;

  /// No description provided for @roundWind.
  ///
  /// In en, this message translates to:
  /// **'Round Wind'**
  String get roundWind;

  /// No description provided for @seatWind.
  ///
  /// In en, this message translates to:
  /// **'Seat Wind'**
  String get seatWind;

  /// No description provided for @flowers.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get flowers;

  /// No description provided for @selectFlowers.
  ///
  /// In en, this message translates to:
  /// **'Select Flowers'**
  String get selectFlowers;

  /// No description provided for @handPreviewArea.
  ///
  /// In en, this message translates to:
  /// **'Hand Preview Area'**
  String get handPreviewArea;

  /// No description provided for @scanTiles.
  ///
  /// In en, this message translates to:
  /// **'Scan Tiles'**
  String get scanTiles;

  /// No description provided for @selectHand.
  ///
  /// In en, this message translates to:
  /// **'Select Hand'**
  String get selectHand;

  /// No description provided for @analyzingTiles.
  ///
  /// In en, this message translates to:
  /// **'Analyzing tiles...'**
  String get analyzingTiles;

  /// No description provided for @takePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Take photo or click to select hand pattern'**
  String get takePhotoHint;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @fanTitle.
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get fanTitle;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @perPerson.
  ///
  /// In en, this message translates to:
  /// **' / person'**
  String get perPerson;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @twConcealedSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Concealed Self-Drawn'**
  String get twConcealedSelfDraw;

  /// No description provided for @descConcealedSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Self-drawn win with a concealed hand.'**
  String get descConcealedSelfDraw;

  /// No description provided for @explConcealedSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Winning by self-draw with no exposed melds (concealed Kongs allowed).'**
  String get explConcealedSelfDraw;

  /// No description provided for @twProperWind.
  ///
  /// In en, this message translates to:
  /// **'Wind of the Round/Seat'**
  String get twProperWind;

  /// No description provided for @descProperWind.
  ///
  /// In en, this message translates to:
  /// **'Pong of Wind matching Round or Seat.'**
  String get descProperWind;

  /// No description provided for @explProperWind.
  ///
  /// In en, this message translates to:
  /// **'Pong/Kong of a Wind tile matching either the Round Wind or your Seat Wind. 2 Tai each.'**
  String get explProperWind;

  /// No description provided for @twOrdinaryWind.
  ///
  /// In en, this message translates to:
  /// **'Ordinary Wind'**
  String get twOrdinaryWind;

  /// No description provided for @descOrdinaryWind.
  ///
  /// In en, this message translates to:
  /// **'Pong of non-matching Wind.'**
  String get descOrdinaryWind;

  /// No description provided for @explOrdinaryWind.
  ///
  /// In en, this message translates to:
  /// **'Pong/Kong of a Wind tile not matching either the Round Wind or Seat Wind. 1 Tai each.'**
  String get explOrdinaryWind;

  /// No description provided for @twDragonPong.
  ///
  /// In en, this message translates to:
  /// **'Dragon Pong'**
  String get twDragonPong;

  /// No description provided for @descTwDragonPong.
  ///
  /// In en, this message translates to:
  /// **'Pong of Red, Green, or White Dragon.'**
  String get descTwDragonPong;

  /// No description provided for @explTwDragonPong.
  ///
  /// In en, this message translates to:
  /// **'Pong/Kong of a Dragon tile (Red, Green, or White). 2 Tai each.'**
  String get explTwDragonPong;

  /// No description provided for @twEyeOf258.
  ///
  /// In en, this message translates to:
  /// **'Eye of 2, 5, 8'**
  String get twEyeOf258;

  /// No description provided for @descEyeOf258.
  ///
  /// In en, this message translates to:
  /// **'Pair of 2, 5, or 8 as the eyes.'**
  String get descEyeOf258;

  /// No description provided for @explEyeOf258.
  ///
  /// In en, this message translates to:
  /// **'Using a tile numbered 2, 5, or 8 as the pair (eyes). +1 Tai.'**
  String get explEyeOf258;

  /// No description provided for @twAllSimples.
  ///
  /// In en, this message translates to:
  /// **'All Simples'**
  String get twAllSimples;

  /// No description provided for @descAllSimples.
  ///
  /// In en, this message translates to:
  /// **'No terminals (1, 9) or honor tiles.'**
  String get descAllSimples;

  /// No description provided for @explAllSimples.
  ///
  /// In en, this message translates to:
  /// **'Hand with no terminals (1, 9) or honor tiles. Full: 5 Tai, Half: 3 Tai.'**
  String get explAllSimples;

  /// No description provided for @twConcealedDragon.
  ///
  /// In en, this message translates to:
  /// **'Concealed Dragon'**
  String get twConcealedDragon;

  /// No description provided for @descConcealedDragon.
  ///
  /// In en, this message translates to:
  /// **'All 1-9 of one suit concealed in hand.'**
  String get descConcealedDragon;

  /// No description provided for @explConcealedDragon.
  ///
  /// In en, this message translates to:
  /// **'Having all tiles numbered 1-9 of the same suit concealed in hand. 20 Tai.'**
  String get explConcealedDragon;

  /// No description provided for @twFiveConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Five Concealed Pungs'**
  String get twFiveConcealedPongs;

  /// No description provided for @descFiveConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Five concealed Pungs in hand.'**
  String get descFiveConcealedPongs;

  /// No description provided for @explFiveConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Having five concealed Pungs in hand (no exposed melds). 80 Tai.'**
  String get explFiveConcealedPongs;

  /// No description provided for @twDeclaredReady.
  ///
  /// In en, this message translates to:
  /// **'Declared Ready'**
  String get twDeclaredReady;

  /// No description provided for @descDeclaredReady.
  ///
  /// In en, this message translates to:
  /// **'Declared ready to win, cannot change hand after.'**
  String get descDeclaredReady;

  /// No description provided for @explDeclaredReady.
  ///
  /// In en, this message translates to:
  /// **'After declaring ready, you cannot change your hand or declare concealed kongs. 5 Tai.'**
  String get explDeclaredReady;

  /// No description provided for @twUnderTheSea.
  ///
  /// In en, this message translates to:
  /// **'Under the Sea'**
  String get twUnderTheSea;

  /// No description provided for @descUnderTheSea.
  ///
  /// In en, this message translates to:
  /// **'Self-drawn win on the very last tile of the wall.'**
  String get descUnderTheSea;

  /// No description provided for @explUnderTheSea.
  ///
  /// In en, this message translates to:
  /// **'Winning by self-drawing the very last tile of the wall. 20 Tai.'**
  String get explUnderTheSea;

  /// No description provided for @twWrongFlower.
  ///
  /// In en, this message translates to:
  /// **'Wrong Flower'**
  String get twWrongFlower;

  /// No description provided for @descWrongFlower.
  ///
  /// In en, this message translates to:
  /// **'Flower not matching your seat.'**
  String get descWrongFlower;

  /// No description provided for @explWrongFlower.
  ///
  /// In en, this message translates to:
  /// **'Each flower tile whose number does not match your seat position. 1 Tai each.'**
  String get explWrongFlower;

  /// No description provided for @twProperFlower.
  ///
  /// In en, this message translates to:
  /// **'Proper Flower'**
  String get twProperFlower;

  /// No description provided for @descProperFlower.
  ///
  /// In en, this message translates to:
  /// **'Flower matching your seat.'**
  String get descProperFlower;

  /// No description provided for @explProperFlower.
  ///
  /// In en, this message translates to:
  /// **'Each flower tile whose number matches your seat position. 2 Tai each.'**
  String get explProperFlower;

  /// No description provided for @twDealerBonus.
  ///
  /// In en, this message translates to:
  /// **'Dealer Bonus'**
  String get twDealerBonus;

  /// No description provided for @twConsecutiveDealer.
  ///
  /// In en, this message translates to:
  /// **'Consecutive Dealer Bonus'**
  String get twConsecutiveDealer;

  /// No description provided for @consecutiveDealerCount.
  ///
  /// In en, this message translates to:
  /// **'Consecutive {count}'**
  String consecutiveDealerCount(int count);

  /// No description provided for @twDeclaredReadyCondition.
  ///
  /// In en, this message translates to:
  /// **'Declared Ready'**
  String get twDeclaredReadyCondition;

  /// No description provided for @ruleSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Self-Draw'**
  String get ruleSelfDraw;

  /// No description provided for @ruleNoFlowers.
  ///
  /// In en, this message translates to:
  /// **'No Flowers'**
  String get ruleNoFlowers;

  /// No description provided for @ruleFlowerPlatform14.
  ///
  /// In en, this message translates to:
  /// **'Flower Platform (1-4)'**
  String get ruleFlowerPlatform14;

  /// No description provided for @ruleFlowerPlatform58.
  ///
  /// In en, this message translates to:
  /// **'Flower Platform (5-8)'**
  String get ruleFlowerPlatform58;

  /// No description provided for @ruleOwnFlower.
  ///
  /// In en, this message translates to:
  /// **'Own Flower'**
  String get ruleOwnFlower;

  /// No description provided for @ruleOwnSeason.
  ///
  /// In en, this message translates to:
  /// **'Own Season'**
  String get ruleOwnSeason;

  /// No description provided for @rulePongOfWhite.
  ///
  /// In en, this message translates to:
  /// **'Pong of White Dragon'**
  String get rulePongOfWhite;

  /// No description provided for @rulePongOfGreen.
  ///
  /// In en, this message translates to:
  /// **'Pong of Green Dragon'**
  String get rulePongOfGreen;

  /// No description provided for @rulePongOfRed.
  ///
  /// In en, this message translates to:
  /// **'Pong of Red Dragon'**
  String get rulePongOfRed;

  /// No description provided for @ruleRoundWind.
  ///
  /// In en, this message translates to:
  /// **'Round Wind'**
  String get ruleRoundWind;

  /// No description provided for @ruleSeatWind.
  ///
  /// In en, this message translates to:
  /// **'Seat Wind'**
  String get ruleSeatWind;

  /// No description provided for @ruleAllChows.
  ///
  /// In en, this message translates to:
  /// **'All Chows'**
  String get ruleAllChows;

  /// No description provided for @ruleAllPongs.
  ///
  /// In en, this message translates to:
  /// **'All Pongs'**
  String get ruleAllPongs;

  /// No description provided for @ruleMixedOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Mixed One Suit'**
  String get ruleMixedOneSuit;

  /// No description provided for @rulePureOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Pure One Suit'**
  String get rulePureOneSuit;

  /// No description provided for @ruleSmallThreeDragons.
  ///
  /// In en, this message translates to:
  /// **'Small Three Dragons'**
  String get ruleSmallThreeDragons;

  /// No description provided for @ruleBigThreeDragons.
  ///
  /// In en, this message translates to:
  /// **'Big Three Dragons'**
  String get ruleBigThreeDragons;

  /// No description provided for @ruleSmallFourWinds.
  ///
  /// In en, this message translates to:
  /// **'Small Four Winds'**
  String get ruleSmallFourWinds;

  /// No description provided for @ruleBigFourWinds.
  ///
  /// In en, this message translates to:
  /// **'Big Four Winds'**
  String get ruleBigFourWinds;

  /// No description provided for @ruleThirteenOrphans.
  ///
  /// In en, this message translates to:
  /// **'Thirteen Orphans'**
  String get ruleThirteenOrphans;

  /// No description provided for @ruleEightImmortals.
  ///
  /// In en, this message translates to:
  /// **'Eight Immortals'**
  String get ruleEightImmortals;

  /// No description provided for @ruleFlowerHand.
  ///
  /// In en, this message translates to:
  /// **'Flower Hand'**
  String get ruleFlowerHand;

  /// No description provided for @ruleHiddenTreasure.
  ///
  /// In en, this message translates to:
  /// **'Hidden Treasure'**
  String get ruleHiddenTreasure;

  /// No description provided for @ruleAllHonors.
  ///
  /// In en, this message translates to:
  /// **'All Honors'**
  String get ruleAllHonors;

  /// No description provided for @ruleNineGates.
  ///
  /// In en, this message translates to:
  /// **'Nine Gates'**
  String get ruleNineGates;

  /// No description provided for @ruleEighteenArhats.
  ///
  /// In en, this message translates to:
  /// **'Eighteen Arhats'**
  String get ruleEighteenArhats;

  /// No description provided for @ruleSevenPairs.
  ///
  /// In en, this message translates to:
  /// **'Seven Pairs'**
  String get ruleSevenPairs;

  /// No description provided for @ruleMigui.
  ///
  /// In en, this message translates to:
  /// **'Migui (Eight Pairs)'**
  String get ruleMigui;

  /// No description provided for @descSevenPairs.
  ///
  /// In en, this message translates to:
  /// **'Hand consisting of 7 pairs'**
  String get descSevenPairs;

  /// No description provided for @descMigui.
  ///
  /// In en, this message translates to:
  /// **'Hand consisting of 8 pairs (16 tiles + 1)'**
  String get descMigui;

  /// No description provided for @explSevenPairs.
  ///
  /// In en, this message translates to:
  /// **'Seven Pairs'**
  String get explSevenPairs;

  /// No description provided for @explMigui.
  ///
  /// In en, this message translates to:
  /// **'Eight Pairs'**
  String get explMigui;

  /// No description provided for @ruleHeavenlyHand.
  ///
  /// In en, this message translates to:
  /// **'Heavenly Hand'**
  String get ruleHeavenlyHand;

  /// No description provided for @ruleEarthlyHand.
  ///
  /// In en, this message translates to:
  /// **'Earthly Hand'**
  String get ruleEarthlyHand;

  /// No description provided for @ruleKong.
  ///
  /// In en, this message translates to:
  /// **'Kong'**
  String get ruleKong;

  /// No description provided for @ruleNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get ruleNone;

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get east;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get south;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get west;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get north;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get gameRules;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get langTraditionalChinese;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'A simple and easy-to-use Mahjong score calculator.'**
  String get aboutDesc;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Mahjong Calculator Team'**
  String get copyright;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackContent.
  ///
  /// In en, this message translates to:
  /// **'Please send your feedback to support@example.com'**
  String get feedbackContent;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy. This app stores your game data locally and on Firebase for synchronization purposes. We do not share your personal data with third parties.'**
  String get privacyPolicyContent;

  /// No description provided for @confirmDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this group?'**
  String get confirmDeleteGroup;

  /// No description provided for @gameInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Game?'**
  String get gameInProgressTitle;

  /// No description provided for @gameInProgressContent.
  ///
  /// In en, this message translates to:
  /// **'There is a game in progress. Starting a new game will assume the previous one is finished and stats will be saved.'**
  String get gameInProgressContent;

  /// No description provided for @startNewGame.
  ///
  /// In en, this message translates to:
  /// **'Start New Game'**
  String get startNewGame;

  /// No description provided for @resumeGame.
  ///
  /// In en, this message translates to:
  /// **'Resume Game'**
  String get resumeGame;

  /// No description provided for @backToGame.
  ///
  /// In en, this message translates to:
  /// **'Back to Game'**
  String get backToGame;

  /// No description provided for @playerStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Player Statistics'**
  String get playerStatsTitle;

  /// No description provided for @recentGroups.
  ///
  /// In en, this message translates to:
  /// **'Recent Groups'**
  String get recentGroups;

  /// No description provided for @editPlayers.
  ///
  /// In en, this message translates to:
  /// **'Edit Players'**
  String get editPlayers;

  /// No description provided for @setupPlayers.
  ///
  /// In en, this message translates to:
  /// **'Setup Players'**
  String get setupPlayers;

  /// No description provided for @enterGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Weekend Mahjong Group'**
  String get enterGroupNameHint;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteGroupWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this player group? This action cannot be undone.'**
  String get deleteGroupWarning;

  /// No description provided for @editPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Player {index}'**
  String editPlayerTitle(int index);

  /// No description provided for @totalGamesMatches.
  ///
  /// In en, this message translates to:
  /// **'Total Games (Matches):'**
  String get totalGamesMatches;

  /// No description provided for @descAllChows.
  ///
  /// In en, this message translates to:
  /// **'Hand with only Chows, no Pongs.'**
  String get descAllChows;

  /// No description provided for @explAllChows.
  ///
  /// In en, this message translates to:
  /// **'Hand composed entirely of Chows (sequences) and a pair. No Pongs or Kongs.'**
  String get explAllChows;

  /// No description provided for @descNoFlowers.
  ///
  /// In en, this message translates to:
  /// **'No Flower tiles.'**
  String get descNoFlowers;

  /// No description provided for @explNoFlowers.
  ///
  /// In en, this message translates to:
  /// **'Winning without any Flower tiles.'**
  String get explNoFlowers;

  /// No description provided for @descOwnSeason.
  ///
  /// In en, this message translates to:
  /// **'Flower tile matches your seat wind.'**
  String get descOwnSeason;

  /// No description provided for @explOwnSeason.
  ///
  /// In en, this message translates to:
  /// **'The Flower tile number corresponds to your seat wind (1=East, 2=South, 3=West, 4=North).'**
  String get explOwnSeason;

  /// No description provided for @descSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Winning by self-drawn tile.'**
  String get descSelfDraw;

  /// No description provided for @explSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Drawing the winning tile yourself adds 1 fan.'**
  String get explSelfDraw;

  /// No description provided for @ruleMenQianQing.
  ///
  /// In en, this message translates to:
  /// **'Men Qian Qing'**
  String get ruleMenQianQing;

  /// No description provided for @descMenQianQing.
  ///
  /// In en, this message translates to:
  /// **'Winning without melding exposed tiles.'**
  String get descMenQianQing;

  /// No description provided for @explMenQianQing.
  ///
  /// In en, this message translates to:
  /// **'Concealed hand. No exposed melds before winning.'**
  String get explMenQianQing;

  /// No description provided for @ruleDragonWindPong.
  ///
  /// In en, this message translates to:
  /// **'Dragon/Wind Pong'**
  String get ruleDragonWindPong;

  /// No description provided for @descDragonWindPong.
  ///
  /// In en, this message translates to:
  /// **'Pong of Dragons or Seat/Round Wind.'**
  String get descDragonWindPong;

  /// No description provided for @explDragonWindPong.
  ///
  /// In en, this message translates to:
  /// **'A Pong/Kong of Dragons or Seat/Round Wind.'**
  String get explDragonWindPong;

  /// No description provided for @ruleRobbingKong.
  ///
  /// In en, this message translates to:
  /// **'Robbing the Kong'**
  String get ruleRobbingKong;

  /// No description provided for @descRobbingKong.
  ///
  /// In en, this message translates to:
  /// **'Winning off a Kong.'**
  String get descRobbingKong;

  /// No description provided for @explRobbingKong.
  ///
  /// In en, this message translates to:
  /// **'Winning when another player declares a Kong with a tile you need.'**
  String get explRobbingKong;

  /// No description provided for @ruleHaidilao.
  ///
  /// In en, this message translates to:
  /// **'Haidilao'**
  String get ruleHaidilao;

  /// No description provided for @descHaidilao.
  ///
  /// In en, this message translates to:
  /// **'Winning on the last tile.'**
  String get descHaidilao;

  /// No description provided for @explHaidilao.
  ///
  /// In en, this message translates to:
  /// **'Winning by drawing the very last tile of the wall.'**
  String get explHaidilao;

  /// No description provided for @ruleKongOnKong.
  ///
  /// In en, this message translates to:
  /// **'Kong on Kong/Flower'**
  String get ruleKongOnKong;

  /// No description provided for @descKongOnKong.
  ///
  /// In en, this message translates to:
  /// **'Winning after a Kong or Flower replacement.'**
  String get descKongOnKong;

  /// No description provided for @explKongOnKong.
  ///
  /// In en, this message translates to:
  /// **'Drawing the winning tile from the dead wall after declaring a Kong or getting a Flower.'**
  String get explKongOnKong;

  /// No description provided for @ruleFlowerPlatform.
  ///
  /// In en, this message translates to:
  /// **'Flower Platform'**
  String get ruleFlowerPlatform;

  /// No description provided for @descFlowerPlatform.
  ///
  /// In en, this message translates to:
  /// **'Complete set of Flowers.'**
  String get descFlowerPlatform;

  /// No description provided for @explFlowerPlatform.
  ///
  /// In en, this message translates to:
  /// **'Collecting a full set of numbered Flowers (1-4) or Seasons (1-4).'**
  String get explFlowerPlatform;

  /// No description provided for @ruleSevenFlowers.
  ///
  /// In en, this message translates to:
  /// **'Flower Hand (7 Flowers)'**
  String get ruleSevenFlowers;

  /// No description provided for @descSevenFlowers.
  ///
  /// In en, this message translates to:
  /// **'Seven Flowers.'**
  String get descSevenFlowers;

  /// No description provided for @explSevenFlowers.
  ///
  /// In en, this message translates to:
  /// **'Collecting 7 Flower tiles allows for an immediate win.'**
  String get explSevenFlowers;

  /// No description provided for @descAllPongs.
  ///
  /// In en, this message translates to:
  /// **'4 Pongs/Kongs & Pair.'**
  String get descAllPongs;

  /// No description provided for @explAllPongs.
  ///
  /// In en, this message translates to:
  /// **'Hand composed entirely of Pongs (triplets) or Kongs and a pair.'**
  String get explAllPongs;

  /// No description provided for @descMixedOneSuit.
  ///
  /// In en, this message translates to:
  /// **'One suit & Honors.'**
  String get descMixedOneSuit;

  /// No description provided for @explMixedOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Hand composed of one suit and Honor tiles.'**
  String get explMixedOneSuit;

  /// No description provided for @ruleMixedTerminals.
  ///
  /// In en, this message translates to:
  /// **'Mixed Terminals'**
  String get ruleMixedTerminals;

  /// No description provided for @descMixedTerminals.
  ///
  /// In en, this message translates to:
  /// **'Terminals & Honors.'**
  String get descMixedTerminals;

  /// No description provided for @explMixedTerminals.
  ///
  /// In en, this message translates to:
  /// **'All Pongs/Kongs composed of Terminals (1/9) and Honor tiles.'**
  String get explMixedTerminals;

  /// No description provided for @descSmallThreeDragons.
  ///
  /// In en, this message translates to:
  /// **'2 Dragon Pongs + Pair.'**
  String get descSmallThreeDragons;

  /// No description provided for @explSmallThreeDragons.
  ///
  /// In en, this message translates to:
  /// **'Two Pongs/Kongs of Dragons and a pair of the third Dragon.'**
  String get explSmallThreeDragons;

  /// No description provided for @descSmallFourWinds.
  ///
  /// In en, this message translates to:
  /// **'3 Wind Pongs + Pair.'**
  String get descSmallFourWinds;

  /// No description provided for @explSmallFourWinds.
  ///
  /// In en, this message translates to:
  /// **'Three Pongs/Kongs of Winds and a pair of the fourth Wind.'**
  String get explSmallFourWinds;

  /// No description provided for @descThirteenOrphans.
  ///
  /// In en, this message translates to:
  /// **'13 Unique Terminals.'**
  String get descThirteenOrphans;

  /// No description provided for @explThirteenOrphans.
  ///
  /// In en, this message translates to:
  /// **'One of each Terminal and Honor tile + one pair.'**
  String get explThirteenOrphans;

  /// No description provided for @ruleBlessingMan.
  ///
  /// In en, this message translates to:
  /// **'Blessing of Man'**
  String get ruleBlessingMan;

  /// No description provided for @ruleBlessingOfMan.
  ///
  /// In en, this message translates to:
  /// **'Blessing of Man'**
  String get ruleBlessingOfMan;

  /// No description provided for @descBlessingMan.
  ///
  /// In en, this message translates to:
  /// **'Non-Dealer 1st Turn Win.'**
  String get descBlessingMan;

  /// No description provided for @explBlessingMan.
  ///
  /// In en, this message translates to:
  /// **'As non-dealer, you win on your first turn with a self-pick.'**
  String get explBlessingMan;

  /// No description provided for @descEarthlyHand.
  ///
  /// In en, this message translates to:
  /// **'Win on Dealer\'s Discard.'**
  String get descEarthlyHand;

  /// No description provided for @explEarthlyHand.
  ///
  /// In en, this message translates to:
  /// **'As non-dealer, you win using the dealer\'s first discard.'**
  String get explEarthlyHand;

  /// No description provided for @descHeavenlyHand.
  ///
  /// In en, this message translates to:
  /// **'Dealer Initial Win.'**
  String get descHeavenlyHand;

  /// No description provided for @explHeavenlyHand.
  ///
  /// In en, this message translates to:
  /// **'As dealer, your beginning hand wins.'**
  String get explHeavenlyHand;

  /// No description provided for @descEighteenArhats.
  ///
  /// In en, this message translates to:
  /// **'4 Kongs + Pair.'**
  String get descEighteenArhats;

  /// No description provided for @explEighteenArhats.
  ///
  /// In en, this message translates to:
  /// **'Winning with four Kongs (18 tiles total).'**
  String get explEighteenArhats;

  /// No description provided for @descBigFourWinds.
  ///
  /// In en, this message translates to:
  /// **'4 Wind Pongs.'**
  String get descBigFourWinds;

  /// No description provided for @explBigFourWinds.
  ///
  /// In en, this message translates to:
  /// **'Four Pongs/Kongs of East, South, West, and North Winds.'**
  String get explBigFourWinds;

  /// No description provided for @descEightImmortals.
  ///
  /// In en, this message translates to:
  /// **'All 8 Flowers.'**
  String get descEightImmortals;

  /// No description provided for @explEightImmortals.
  ///
  /// In en, this message translates to:
  /// **'Collecting all 8 Flower tiles allows for an immediate win.'**
  String get explEightImmortals;

  /// No description provided for @descHiddenTreasure.
  ///
  /// In en, this message translates to:
  /// **'4 Concealed Pongs.'**
  String get descHiddenTreasure;

  /// No description provided for @explHiddenTreasure.
  ///
  /// In en, this message translates to:
  /// **'Four Pongs/Kongs that were all self-drawn (concealed).'**
  String get explHiddenTreasure;

  /// No description provided for @ruleDoubleKong.
  ///
  /// In en, this message translates to:
  /// **'Double Kong Replacement'**
  String get ruleDoubleKong;

  /// No description provided for @descDoubleKong.
  ///
  /// In en, this message translates to:
  /// **'Win on 2nd Kong.'**
  String get descDoubleKong;

  /// No description provided for @explDoubleKong.
  ///
  /// In en, this message translates to:
  /// **'If you call a kong, call a second kong using the replacement tile, then win on the second replacement.'**
  String get explDoubleKong;

  /// No description provided for @descAllHonors.
  ///
  /// In en, this message translates to:
  /// **'All Honors.'**
  String get descAllHonors;

  /// No description provided for @explAllHonors.
  ///
  /// In en, this message translates to:
  /// **'Hand composed entirely of Honor tiles.'**
  String get explAllHonors;

  /// No description provided for @rulePureTerminals.
  ///
  /// In en, this message translates to:
  /// **'Pure Terminals'**
  String get rulePureTerminals;

  /// No description provided for @descPureTerminals.
  ///
  /// In en, this message translates to:
  /// **'All 1s and 9s.'**
  String get descPureTerminals;

  /// No description provided for @explPureTerminals.
  ///
  /// In en, this message translates to:
  /// **'All Pongs/Kongs composed entirely of Terminal tiles (1 and 9).'**
  String get explPureTerminals;

  /// No description provided for @descNineGates.
  ///
  /// In en, this message translates to:
  /// **'1-9 of one suit hand.'**
  String get descNineGates;

  /// No description provided for @explNineGates.
  ///
  /// In en, this message translates to:
  /// **'Concealed hand of one suit: 1112345678999 + any tile of the same suit.'**
  String get explNineGates;

  /// No description provided for @descPureOneSuit.
  ///
  /// In en, this message translates to:
  /// **'All one suit.'**
  String get descPureOneSuit;

  /// No description provided for @explPureOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Hand composed entirely of tiles from a single suit.'**
  String get explPureOneSuit;

  /// No description provided for @descBigThreeDragons.
  ///
  /// In en, this message translates to:
  /// **'3 Dragon Pongs.'**
  String get descBigThreeDragons;

  /// No description provided for @explBigThreeDragons.
  ///
  /// In en, this message translates to:
  /// **'Three Pongs/Kongs of Red, Green, and White Dragons.'**
  String get explBigThreeDragons;

  /// No description provided for @totalHandsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Total Hands Played:'**
  String get totalHandsPlayed;

  /// No description provided for @noResultRate.
  ///
  /// In en, this message translates to:
  /// **'No Result Rate:'**
  String get noResultRate;

  /// No description provided for @statsWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get statsWinRate;

  /// No description provided for @statsSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'Self-Draw'**
  String get statsSelfDraw;

  /// No description provided for @statsRon.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get statsRon;

  /// No description provided for @statsDealIn.
  ///
  /// In en, this message translates to:
  /// **'Deal-in'**
  String get statsDealIn;

  /// No description provided for @selectDealer.
  ///
  /// In en, this message translates to:
  /// **'Select Dealer'**
  String get selectDealer;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @totalWindRounds.
  ///
  /// In en, this message translates to:
  /// **'Total Wind Rounds:'**
  String get totalWindRounds;

  /// No description provided for @totalRoundsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Total Games Played:'**
  String get totalRoundsPlayed;

  /// No description provided for @totalGames.
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// No description provided for @finishGame.
  ///
  /// In en, this message translates to:
  /// **'Finish Game'**
  String get finishGame;

  /// No description provided for @changePosition.
  ///
  /// In en, this message translates to:
  /// **'Change Position'**
  String get changePosition;

  /// No description provided for @swapPositionsContent.
  ///
  /// In en, this message translates to:
  /// **'Swap positions of {p1} and {p2}?'**
  String swapPositionsContent(String p1, String p2);

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @resetGameState.
  ///
  /// In en, this message translates to:
  /// **'Reset Game State?'**
  String get resetGameState;

  /// No description provided for @resetDealer.
  ///
  /// In en, this message translates to:
  /// **'Reset Dealer Position'**
  String get resetDealer;

  /// No description provided for @resetDealerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new dealer'**
  String get resetDealerSubtitle;

  /// No description provided for @resetWind.
  ///
  /// In en, this message translates to:
  /// **'Reset Wind Round'**
  String get resetWind;

  /// No description provided for @resetWindSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to East 1'**
  String get resetWindSubtitle;

  /// No description provided for @cancelReset.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reset'**
  String get cancelReset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @currentGameStats.
  ///
  /// In en, this message translates to:
  /// **'Current Game Stats'**
  String get currentGameStats;

  /// No description provided for @noRoundsPlayed.
  ///
  /// In en, this message translates to:
  /// **'No rounds played yet.'**
  String get noRoundsPlayed;

  /// No description provided for @mahjongScoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahjong Scoring'**
  String get mahjongScoringTitle;

  /// No description provided for @windEast.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get windEast;

  /// No description provided for @windSouth.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get windSouth;

  /// No description provided for @windWest.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get windWest;

  /// No description provided for @windNorth.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get windNorth;

  /// No description provided for @roundInfo.
  ///
  /// In en, this message translates to:
  /// **'{wind} Round - Game {game}'**
  String roundInfo(String wind, int game);

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @noResult.
  ///
  /// In en, this message translates to:
  /// **'No Result'**
  String get noResult;

  /// No description provided for @gameCount.
  ///
  /// In en, this message translates to:
  /// **'Game {count}'**
  String gameCount(int count);

  /// No description provided for @mahjong.
  ///
  /// In en, this message translates to:
  /// **'Mahjong'**
  String get mahjong;

  /// No description provided for @windCircleSuffix.
  ///
  /// In en, this message translates to:
  /// **' Round'**
  String get windCircleSuffix;

  /// No description provided for @tooltipStats.
  ///
  /// In en, this message translates to:
  /// **'Game Statistics'**
  String get tooltipStats;

  /// No description provided for @tooltipRules.
  ///
  /// In en, this message translates to:
  /// **'Rules Reference'**
  String get tooltipRules;

  /// No description provided for @tooltipHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get tooltipHome;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load player groups: '**
  String get loadFailed;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: '**
  String get saveFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: '**
  String get deleteFailed;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get tryAgain;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @moreLanguagesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More languages coming soon...'**
  String get moreLanguagesComingSoon;

  /// No description provided for @rulesAndTutorial.
  ///
  /// In en, this message translates to:
  /// **'Rules & Tutorial'**
  String get rulesAndTutorial;

  /// No description provided for @rulesReference.
  ///
  /// In en, this message translates to:
  /// **'Rules Reference'**
  String get rulesReference;

  /// No description provided for @mahjongTutorial.
  ///
  /// In en, this message translates to:
  /// **'Mahjong Tutorial'**
  String get mahjongTutorial;

  /// No description provided for @allFan.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFan;

  /// No description provided for @searchRules.
  ///
  /// In en, this message translates to:
  /// **'Search Rules'**
  String get searchRules;

  /// No description provided for @tutorialWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get tutorialWelcome;

  /// No description provided for @tutorialTiles.
  ///
  /// In en, this message translates to:
  /// **'Tiles'**
  String get tutorialTiles;

  /// No description provided for @tutorialRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get tutorialRules;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rulesTitle;

  /// No description provided for @tutorialScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get tutorialScore;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @viewExample.
  ///
  /// In en, this message translates to:
  /// **'View Example'**
  String get viewExample;

  /// No description provided for @hideExample.
  ///
  /// In en, this message translates to:
  /// **'Hide Example'**
  String get hideExample;

  /// No description provided for @exampleExplanation.
  ///
  /// In en, this message translates to:
  /// **'Example Explanation:'**
  String get exampleExplanation;

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String playerCount(int count);

  /// No description provided for @roundOf.
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String roundOf(int current, int total);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mahjong Score Calculator'**
  String get welcomeTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your all-in-one companion for Hong Kong Mahjong!'**
  String get appDescription;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features:'**
  String get keyFeatures;

  /// No description provided for @smartCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Calculator'**
  String get smartCalculatorTitle;

  /// No description provided for @smartCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Instantly calculate Fan and Score. Supports special hands like Thirteen Orphans and Nine Gates.'**
  String get smartCalculatorDesc;

  /// No description provided for @gameRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Recording'**
  String get gameRecordingTitle;

  /// No description provided for @gameRecordingDesc.
  ///
  /// In en, this message translates to:
  /// **'Track scores round-by-round. Auto-manages Dealer rotation and Round Winds.'**
  String get gameRecordingDesc;

  /// No description provided for @rulesReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules Reference'**
  String get rulesReferenceTitle;

  /// No description provided for @rulesReferenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete guide to HK Mahjong scoring patterns with examples.'**
  String get rulesReferenceDesc;

  /// No description provided for @playerManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Player Management'**
  String get playerManagementTitle;

  /// No description provided for @playerManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Save player groups and keep track of total games played.'**
  String get playerManagementDesc;

  /// No description provided for @swipeToLearn.
  ///
  /// In en, this message translates to:
  /// **'Swipe to learn the basics ->'**
  String get swipeToLearn;

  /// No description provided for @tileTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Types of Mahjong Tiles'**
  String get tileTypesTitle;

  /// No description provided for @characterTiles.
  ///
  /// In en, this message translates to:
  /// **'Character Tiles'**
  String get characterTiles;

  /// No description provided for @characterTilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Numbered 1 to 9 in characters'**
  String get characterTilesDesc;

  /// No description provided for @dotsTiles.
  ///
  /// In en, this message translates to:
  /// **'Dots Tiles'**
  String get dotsTiles;

  /// No description provided for @dotsTilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Numbered 1 to 9 in dots'**
  String get dotsTilesDesc;

  /// No description provided for @bambooTiles.
  ///
  /// In en, this message translates to:
  /// **'Bamboo Tiles'**
  String get bambooTiles;

  /// No description provided for @bambooTilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Numbered 1 to 9 in bamboo'**
  String get bambooTilesDesc;

  /// No description provided for @honorTiles.
  ///
  /// In en, this message translates to:
  /// **'Honor Tiles'**
  String get honorTiles;

  /// No description provided for @honorTilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Include Wind tiles (East/South/West/North) and Dragon tiles (Red/Green/White)'**
  String get honorTilesDesc;

  /// No description provided for @flowerTiles.
  ///
  /// In en, this message translates to:
  /// **'Flower Tiles'**
  String get flowerTiles;

  /// No description provided for @flowerTilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Flowers (Plum, Orchid, Chrysanthemum, Bamboo) and Seasons (Spring, Summer, Autumn, Winter)'**
  String get flowerTilesDesc;

  /// No description provided for @basicRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Rules'**
  String get basicRulesTitle;

  /// No description provided for @gameObjectiveTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Game Objective'**
  String get gameObjectiveTitle;

  /// No description provided for @gameObjectiveDesc1.
  ///
  /// In en, this message translates to:
  /// **'The goal of mahjong is to form a complete hand, usually consisting of:'**
  String get gameObjectiveDesc1;

  /// No description provided for @gameObjectiveDesc2.
  ///
  /// In en, this message translates to:
  /// **'• 4 sets (chow/pong) + 1 pair (eyes)'**
  String get gameObjectiveDesc2;

  /// No description provided for @gameObjectiveDesc3.
  ///
  /// In en, this message translates to:
  /// **'• Special hands (e.g., Thirteen Orphans)'**
  String get gameObjectiveDesc3;

  /// No description provided for @basicTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Basic Terms'**
  String get basicTermsTitle;

  /// No description provided for @basicTermsChow.
  ///
  /// In en, this message translates to:
  /// **'• Chow: Three consecutive tiles (e.g., 1m-2m-3m)'**
  String get basicTermsChow;

  /// No description provided for @basicTermsPong.
  ///
  /// In en, this message translates to:
  /// **'• Pong: Three identical tiles (e.g., 5p-5p-5p)'**
  String get basicTermsPong;

  /// No description provided for @basicTermsEyes.
  ///
  /// In en, this message translates to:
  /// **'• Eyes: A pair of identical tiles'**
  String get basicTermsEyes;

  /// No description provided for @basicTermsSelfDraw.
  ///
  /// In en, this message translates to:
  /// **'• Self-Draw: Draw your own winning tile'**
  String get basicTermsSelfDraw;

  /// No description provided for @basicTermsDiscard.
  ///
  /// In en, this message translates to:
  /// **'• Discard: Discard a tile that lets others win'**
  String get basicTermsDiscard;

  /// No description provided for @startingGameTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Starting the Game'**
  String get startingGameTitle;

  /// No description provided for @startingGameDesc.
  ///
  /// In en, this message translates to:
  /// **'The Dealer (East) rolls 2 or 3 dice to determine which wall to break.'**
  String get startingGameDesc;

  /// No description provided for @diceRollTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Dice Roll & Wall Selection:'**
  String get diceRollTableTitle;

  /// No description provided for @counterClockwiseCount.
  ///
  /// In en, this message translates to:
  /// **'Count counter-clockwise starting from Dealer as 1.'**
  String get counterClockwiseCount;

  /// No description provided for @exampleRoll8.
  ///
  /// In en, this message translates to:
  /// **'Example: Roll 8 → Count to North (Left). Break North wall.'**
  String get exampleRoll8;

  /// No description provided for @drawClockwise.
  ///
  /// In en, this message translates to:
  /// **'From the chosen wall, count stacks clockwise (skipping the rolled number) to start drawing.'**
  String get drawClockwise;

  /// No description provided for @rememberDirection.
  ///
  /// In en, this message translates to:
  /// **'Remember: Play Counter-Clockwise, Draw Clockwise!'**
  String get rememberDirection;

  /// No description provided for @dealingProcedureTitle.
  ///
  /// In en, this message translates to:
  /// **'Dealing Procedure:'**
  String get dealingProcedureTitle;

  /// No description provided for @dealStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Each player takes 4 tiles (2 stacks) in order.'**
  String get dealStep1;

  /// No description provided for @dealStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Repeat until everyone has 12 tiles.'**
  String get dealStep2;

  /// No description provided for @dealStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Dealer takes 1st and 3rd tile from end (14 total).'**
  String get dealStep3;

  /// No description provided for @dealStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Others take 1 tile (13 total).'**
  String get dealStep4;

  /// No description provided for @dealStep5.
  ///
  /// In en, this message translates to:
  /// **'5. Replace Flower tiles from the back of the wall.'**
  String get dealStep5;

  /// No description provided for @gameplayProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Gameplay Process'**
  String get gameplayProcessTitle;

  /// No description provided for @gameplayProcessDesc.
  ///
  /// In en, this message translates to:
  /// **'After dealing and flower replacement, the game proceeds counter-clockwise starting from the Dealer.'**
  String get gameplayProcessDesc;

  /// No description provided for @standardTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'Standard Turn:'**
  String get standardTurnTitle;

  /// No description provided for @drawAction.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get drawAction;

  /// No description provided for @actionAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get actionAction;

  /// No description provided for @discardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardAction;

  /// No description provided for @turnStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Draw a tile from the wall (Dealer skips this on first turn).'**
  String get turnStep1;

  /// No description provided for @turnStep2.
  ///
  /// In en, this message translates to:
  /// **'2. If it\'s a Flower, reveal it and draw a replacement from the back.'**
  String get turnStep2;

  /// No description provided for @turnStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Choose to Kong (Concealed/Added) or Win (Self-Draw).'**
  String get turnStep3;

  /// No description provided for @turnStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Discard one tile to end your turn.'**
  String get turnStep4;

  /// No description provided for @interactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactions (Stealing):'**
  String get interactionsTitle;

  /// No description provided for @interactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Other players can interrupt the turn by claiming a discard.'**
  String get interactionsDesc;

  /// No description provided for @priorityRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Priority Rule:'**
  String get priorityRuleTitle;

  /// No description provided for @priorityRuleDesc.
  ///
  /// In en, this message translates to:
  /// **'Win > Kong/Pong > Chow'**
  String get priorityRuleDesc;

  /// No description provided for @priorityPongWins.
  ///
  /// In en, this message translates to:
  /// **'If one player wants to Chow and another wants to Pong the same tile, Pong wins.'**
  String get priorityPongWins;

  /// No description provided for @missedWinTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed Win Rule :'**
  String get missedWinTitle;

  /// No description provided for @missedWinDesc.
  ///
  /// In en, this message translates to:
  /// **'If you can win on a discard but choose not to (e.g., to try for a higher score), you cannot win on that same tile from another player until you complete your next turn (draw/action).'**
  String get missedWinDesc;

  /// No description provided for @missedWinException.
  ///
  /// In en, this message translates to:
  /// **'Exception: If the new tile gives you a higher Fan count (e.g., completing a specific pattern), you may be allowed to win depending on house rules.'**
  String get missedWinException;

  /// No description provided for @actionChow.
  ///
  /// In en, this message translates to:
  /// **'Chow '**
  String get actionChow;

  /// No description provided for @targetLeftPlayer.
  ///
  /// In en, this message translates to:
  /// **'Left Player Only'**
  String get targetLeftPlayer;

  /// No description provided for @descChowInteract.
  ///
  /// In en, this message translates to:
  /// **'Form a sequence (e.g., 1-2-3).'**
  String get descChowInteract;

  /// No description provided for @actionPong.
  ///
  /// In en, this message translates to:
  /// **'Pong '**
  String get actionPong;

  /// No description provided for @targetAnyPlayer.
  ///
  /// In en, this message translates to:
  /// **'Any Player'**
  String get targetAnyPlayer;

  /// No description provided for @descPongInteract.
  ///
  /// In en, this message translates to:
  /// **'Form a triplet (e.g., 3-3-3). Interrupts turn order.'**
  String get descPongInteract;

  /// No description provided for @actionKong.
  ///
  /// In en, this message translates to:
  /// **'Kong '**
  String get actionKong;

  /// No description provided for @descKongInteract.
  ///
  /// In en, this message translates to:
  /// **'Form a quad. Draw replacement. Interrupts turn order.'**
  String get descKongInteract;

  /// No description provided for @actionWinInteract.
  ///
  /// In en, this message translates to:
  /// **'Win '**
  String get actionWinInteract;

  /// No description provided for @descWinInteract.
  ///
  /// In en, this message translates to:
  /// **'Complete the hand. Ends the game.'**
  String get descWinInteract;

  /// No description provided for @scoringSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring System'**
  String get scoringSystemTitle;

  /// No description provided for @scoringRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Mahjong Scoring Rules'**
  String get scoringRulesTitle;

  /// No description provided for @scoringRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Mahjong scoring is determined by fan count. The table below shows the points for each fan count:'**
  String get scoringRulesDesc;

  /// No description provided for @fanPointsHeader.
  ///
  /// In en, this message translates to:
  /// **'Fan Points'**
  String get fanPointsHeader;

  /// No description provided for @byDiscardHeader.
  ///
  /// In en, this message translates to:
  /// **'By Discard'**
  String get byDiscardHeader;

  /// No description provided for @bySelfDrawHeader.
  ///
  /// In en, this message translates to:
  /// **'By Self-Draw'**
  String get bySelfDrawHeader;

  /// No description provided for @flowerTilesScoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Flower Tiles Scoring'**
  String get flowerTilesScoringTitle;

  /// No description provided for @noFlowersFan.
  ///
  /// In en, this message translates to:
  /// **'• No Flowers: 1 Fan'**
  String get noFlowersFan;

  /// No description provided for @ownFlowerFan.
  ///
  /// In en, this message translates to:
  /// **'• Own Flower: 1 Fan (Flower matches seat wind)'**
  String get ownFlowerFan;

  /// No description provided for @flowerMapping.
  ///
  /// In en, this message translates to:
  /// **'Flower Mapping:'**
  String get flowerMapping;

  /// No description provided for @seat1Flower.
  ///
  /// In en, this message translates to:
  /// **'• Seat 1 (East): Spring, Plum'**
  String get seat1Flower;

  /// No description provided for @seat2Flower.
  ///
  /// In en, this message translates to:
  /// **'• Seat 2 (South): Summer, Orchid'**
  String get seat2Flower;

  /// No description provided for @seat3Flower.
  ///
  /// In en, this message translates to:
  /// **'• Seat 3 (West): Autumn, Chrysanthemum'**
  String get seat3Flower;

  /// No description provided for @seat4Flower.
  ///
  /// In en, this message translates to:
  /// **'• Seat 4 (North): Winter, Bamboo'**
  String get seat4Flower;

  /// No description provided for @honorTilesScoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Honor Tiles Scoring'**
  String get honorTilesScoringTitle;

  /// No description provided for @dragonPongFan.
  ///
  /// In en, this message translates to:
  /// **'• Dragon Pong/Kong: 1 Fan (Red, Green, or White Dragon)'**
  String get dragonPongFan;

  /// No description provided for @roundWindPongFan.
  ///
  /// In en, this message translates to:
  /// **'• Round Wind Pong/Kong: 1 Fan (Matches the current round wind)'**
  String get roundWindPongFan;

  /// No description provided for @seatWindPongFan.
  ///
  /// In en, this message translates to:
  /// **'• Seat Wind Pong/Kong: 1 Fan (Matches your seat wind)'**
  String get seatWindPongFan;

  /// No description provided for @winningPatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Winning Patterns (Fan List)'**
  String get winningPatternsTitle;

  /// No description provided for @winningPatternsDesc.
  ///
  /// In en, this message translates to:
  /// **'Click on a pattern name to see details and examples.'**
  String get winningPatternsDesc;

  /// No description provided for @chickenHand.
  ///
  /// In en, this message translates to:
  /// **'0 (Chicken)'**
  String get chickenHand;

  /// No description provided for @naMinOne.
  ///
  /// In en, this message translates to:
  /// **'N/A (min 1)'**
  String get naMinOne;

  /// No description provided for @limitHand.
  ///
  /// In en, this message translates to:
  /// **'13 (Limit)'**
  String get limitHand;

  /// No description provided for @selectWinningHand.
  ///
  /// In en, this message translates to:
  /// **'Select Winning Hand'**
  String get selectWinningHand;

  /// No description provided for @maxTilesAlert.
  ///
  /// In en, this message translates to:
  /// **'Cannot select more than 4 of the same tile'**
  String get maxTilesAlert;

  /// No description provided for @maxTotalTilesAlert.
  ///
  /// In en, this message translates to:
  /// **'Maximum 18 tiles allowed'**
  String get maxTotalTilesAlert;

  /// No description provided for @minTilesAlert.
  ///
  /// In en, this message translates to:
  /// **'Select at least 14 tiles'**
  String get minTilesAlert;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected:'**
  String get selectedCount;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @charactersTab.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get charactersTab;

  /// No description provided for @dotsTab.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get dotsTab;

  /// No description provided for @bambooTab.
  ///
  /// In en, this message translates to:
  /// **'Bamboo'**
  String get bambooTab;

  /// No description provided for @honorsTab.
  ///
  /// In en, this message translates to:
  /// **'Honors'**
  String get honorsTab;

  /// No description provided for @invalidTileCount.
  ///
  /// In en, this message translates to:
  /// **'Invalid number of tiles. Must be 14, 15, 16, 17, or 18.'**
  String get invalidTileCount;

  /// No description provided for @winningHandThirteenOrphans.
  ///
  /// In en, this message translates to:
  /// **'Winning Hand (Thirteen Orphans)!'**
  String get winningHandThirteenOrphans;

  /// No description provided for @winningHand.
  ///
  /// In en, this message translates to:
  /// **'Winning Hand!'**
  String get winningHand;

  /// No description provided for @winningHandInvalid.
  ///
  /// In en, this message translates to:
  /// **'Cannot form a winning hand (4 sets + 1 pair).'**
  String get winningHandInvalid;

  /// No description provided for @gameHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Game History'**
  String get gameHistoryTitle;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history records'**
  String get noHistory;

  /// No description provided for @gameIndex.
  ///
  /// In en, this message translates to:
  /// **'Game #{index}'**
  String gameIndex(int index);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @roundsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get roundsLabel;

  /// No description provided for @tipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip:'**
  String get tipTitle;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahjong Calculator'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Making Scoring Easier'**
  String get splashSubtitle;

  /// No description provided for @tipDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this app\'s scoring feature to automatically calculate fan and score!'**
  String get tipDesc;

  /// No description provided for @importantNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Note:'**
  String get importantNoteTitle;

  /// No description provided for @flowerNote.
  ///
  /// In en, this message translates to:
  /// **'If you have flowers but none match your seat (e.g., East seat holding Summer), you get 0 Fan for flowers and lose the \"No Flower\" bonus.'**
  String get flowerNote;

  /// No description provided for @dragonNote.
  ///
  /// In en, this message translates to:
  /// **'Note: If your seat wind matches the round wind (e.g., East Seat in East Round), a Pong of East Wind gives 2 Fan!'**
  String get dragonNote;

  /// No description provided for @diceDealerEast.
  ///
  /// In en, this message translates to:
  /// **'Dealer (East)'**
  String get diceDealerEast;

  /// No description provided for @diceSouthRight.
  ///
  /// In en, this message translates to:
  /// **'South (Right)'**
  String get diceSouthRight;

  /// No description provided for @diceWestOpposite.
  ///
  /// In en, this message translates to:
  /// **'West (Opposite)'**
  String get diceWestOpposite;

  /// No description provided for @diceNorthLeft.
  ///
  /// In en, this message translates to:
  /// **'North (Left)'**
  String get diceNorthLeft;

  /// No description provided for @defaultPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Player {index}'**
  String defaultPlayerName(int index);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get noAccountText;

  /// No description provided for @hasAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get hasAccountText;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get genericError;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete group \"{name}\"?'**
  String confirmDeleteContent(String name);

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group \"{name}\" deleted'**
  String groupDeleted(String name);

  /// No description provided for @savedGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Player Groups'**
  String get savedGroupsTitle;

  /// No description provided for @noAnySavedGroups.
  ///
  /// In en, this message translates to:
  /// **'No saved player groups yet'**
  String get noAnySavedGroups;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @createdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Created: '**
  String get createdPrefix;

  /// No description provided for @playersListPrefix.
  ///
  /// In en, this message translates to:
  /// **'Players: '**
  String get playersListPrefix;

  /// No description provided for @defaultGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group {timestamp}'**
  String defaultGroupName(String timestamp);

  /// No description provided for @twRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiwan Mahjong Rules'**
  String get twRulesTitle;

  /// No description provided for @hkRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Mahjong Rules'**
  String get hkRulesTitle;

  /// No description provided for @hkMode.
  ///
  /// In en, this message translates to:
  /// **'HK'**
  String get hkMode;

  /// No description provided for @twMode.
  ///
  /// In en, this message translates to:
  /// **'TW'**
  String get twMode;

  /// No description provided for @twScoringRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiwan Mahjong Scoring Rules'**
  String get twScoringRulesTitle;

  /// No description provided for @twScoringRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Taiwan Mahjong uses a Tai (台) system. The total score = Base Tai + (Total Tai × Score per Tai). The ratio is usually 1 base : 1/5 per Tai (e.g., \$10 base, \$2 per Tai).'**
  String get twScoringRulesDesc;

  /// No description provided for @twTaiHeader.
  ///
  /// In en, this message translates to:
  /// **'Tai Count'**
  String get twTaiHeader;

  /// No description provided for @twScoreHeader.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get twScoreHeader;

  /// No description provided for @twInstantPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Instant Payment Rules'**
  String get twInstantPayTitle;

  /// No description provided for @twInstantPayDesc.
  ///
  /// In en, this message translates to:
  /// **'Some events require immediate payment during gameplay, not just at settlement.'**
  String get twInstantPayDesc;

  /// No description provided for @twChaseRule.
  ///
  /// In en, this message translates to:
  /// **'Chase (追)'**
  String get twChaseRule;

  /// No description provided for @twChaseDesc.
  ///
  /// In en, this message translates to:
  /// **'When four players consecutively discard the same tile, the first player must pay each of the other three players one base amount.'**
  String get twChaseDesc;

  /// No description provided for @twConcealedKongPay.
  ///
  /// In en, this message translates to:
  /// **'Concealed Kong (暗槓) Payment'**
  String get twConcealedKongPay;

  /// No description provided for @twConcealedKongPayDesc.
  ///
  /// In en, this message translates to:
  /// **'When a player declares a concealed Kong, each of the other three players must pay one base amount. The Kong must be revealed at settlement; failure to do so incurs a 2× base penalty.'**
  String get twConcealedKongPayDesc;

  /// No description provided for @twFlowerSetPay.
  ///
  /// In en, this message translates to:
  /// **'Flower Set Bonus'**
  String get twFlowerSetPay;

  /// No description provided for @twFlowerSetPayDesc.
  ///
  /// In en, this message translates to:
  /// **'One complete flower set (一台草): each opponent pays half a base. One complete flower group (一台花): each opponent pays one base. Note: claiming flowers forfeits grass bonus.'**
  String get twFlowerSetPayDesc;

  /// No description provided for @twFalseWinPay.
  ///
  /// In en, this message translates to:
  /// **'False Win (詐胡)'**
  String get twFalseWinPay;

  /// No description provided for @twFalseWinPayDesc.
  ///
  /// In en, this message translates to:
  /// **'A false win declaration usually costs \$100 per player. If the dealer makes a false win, they must continue as dealer (連莊).'**
  String get twFalseWinPayDesc;

  /// No description provided for @twCalledPongPenalty.
  ///
  /// In en, this message translates to:
  /// **'Called Pong Penalty (叫碰不碰)'**
  String get twCalledPongPenalty;

  /// No description provided for @twCalledPongPenaltyDesc.
  ///
  /// In en, this message translates to:
  /// **'If a player calls Pong but fails to execute, they must pay one base as a penalty placed in the center. The round winner collects it.'**
  String get twCalledPongPenaltyDesc;

  /// No description provided for @twPenaltiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Special Penalty Rules'**
  String get twPenaltiesTitle;

  /// No description provided for @twPenaltiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Rules regarding win eligibility and scoring penalties.'**
  String get twPenaltiesDesc;

  /// No description provided for @twWinPlacementRule.
  ///
  /// In en, this message translates to:
  /// **'Win Tile Placement'**
  String get twWinPlacementRule;

  /// No description provided for @twWinPlacementDesc.
  ///
  /// In en, this message translates to:
  /// **'The winning tile must be placed separately, not mixed into your hand. Failure to do so invalidates the win.'**
  String get twWinPlacementDesc;

  /// No description provided for @twMissedWinRule.
  ///
  /// In en, this message translates to:
  /// **'Missed Win (過水) Restriction'**
  String get twMissedWinRule;

  /// No description provided for @twMissedWinDesc.
  ///
  /// In en, this message translates to:
  /// **'If you pass on a winning tile in a turn cycle, you cannot win on the same tile from another player until you complete your next draw.'**
  String get twMissedWinDesc;

  /// No description provided for @twKongRevealRule.
  ///
  /// In en, this message translates to:
  /// **'Concealed Kong Reveal'**
  String get twKongRevealRule;

  /// No description provided for @twKongRevealDesc.
  ///
  /// In en, this message translates to:
  /// **'If you forget to reveal concealed Kongs at settlement, the penalty is doubled.'**
  String get twKongRevealDesc;

  /// No description provided for @twDealerMarkerRule.
  ///
  /// In en, this message translates to:
  /// **'Dealer Marker (Dice)'**
  String get twDealerMarkerRule;

  /// No description provided for @twDealerMarkerDesc.
  ///
  /// In en, this message translates to:
  /// **'If the dealer forgets to place dice markers for consecutive deals, the consecutive dealer bonus cannot be counted when winning. However, if the dealer discards the winning tile, they still must pay the bonus.'**
  String get twDealerMarkerDesc;

  /// No description provided for @twFlowerOrderRule.
  ///
  /// In en, this message translates to:
  /// **'Flower Replacement Order'**
  String get twFlowerOrderRule;

  /// No description provided for @twFlowerOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Opening flower replacement follows strict order. The dealer replaces first and says \'please\', then each player proceeds in turn. The dealer can only start playing after the last player finishes.'**
  String get twFlowerOrderDesc;

  /// No description provided for @twLaSettlementTitle.
  ///
  /// In en, this message translates to:
  /// **'\'La\' Settlement Rules (拉)'**
  String get twLaSettlementTitle;

  /// No description provided for @twLaSettlementDesc.
  ///
  /// In en, this message translates to:
  /// **'A carry-over settlement system that multiplies debt across consecutive rounds.'**
  String get twLaSettlementDesc;

  /// No description provided for @twLaMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier Effect'**
  String get twLaMultiplier;

  /// No description provided for @twLaMultiplierDesc.
  ///
  /// In en, this message translates to:
  /// **'If the previous round\'s winner wins again, the losers\' previous debts are multiplied by 1.5× before adding the new round\'s losses.'**
  String get twLaMultiplierDesc;

  /// No description provided for @twLaReduction.
  ///
  /// In en, this message translates to:
  /// **'Debt Reduction'**
  String get twLaReduction;

  /// No description provided for @twLaReductionDesc.
  ///
  /// In en, this message translates to:
  /// **'If the previous round\'s loser self-draws, or the previous winner discards the winning tile, accumulated debts are halved.'**
  String get twLaReductionDesc;

  /// No description provided for @twLaApplied.
  ///
  /// In en, this message translates to:
  /// **'La Carry-over (拉)'**
  String get twLaApplied;

  /// No description provided for @twLaMultiplierApplied.
  ///
  /// In en, this message translates to:
  /// **'La ×1.5 carry-over'**
  String get twLaMultiplierApplied;

  /// No description provided for @twLaReductionApplied.
  ///
  /// In en, this message translates to:
  /// **'La debt halved'**
  String get twLaReductionApplied;

  /// No description provided for @twLaCarryDebt.
  ///
  /// In en, this message translates to:
  /// **'Carry-over debt from previous round'**
  String get twLaCarryDebt;

  /// No description provided for @twDealerBonusTitle.
  ///
  /// In en, this message translates to:
  /// **'Dealer Bonus Rules'**
  String get twDealerBonusTitle;

  /// No description provided for @twDealerBonusDesc.
  ///
  /// In en, this message translates to:
  /// **'The dealer (莊家) gets extra Tai based on consecutive wins.'**
  String get twDealerBonusDesc;

  /// No description provided for @twDealerBonusBase.
  ///
  /// In en, this message translates to:
  /// **'Being Dealer: +1 Tai'**
  String get twDealerBonusBase;

  /// No description provided for @twDealerBonusFormula.
  ///
  /// In en, this message translates to:
  /// **'Consecutive Dealer Formula: (Consecutive Count × 2) + 1'**
  String get twDealerBonusFormula;

  /// No description provided for @twDealerBonusExample1.
  ///
  /// In en, this message translates to:
  /// **'Consecutive 1 (連一拉一): 3 Tai'**
  String get twDealerBonusExample1;

  /// No description provided for @twDealerBonusExample2.
  ///
  /// In en, this message translates to:
  /// **'Consecutive 2 (連二拉二): 5 Tai'**
  String get twDealerBonusExample2;

  /// No description provided for @twDealerBonusExample3.
  ///
  /// In en, this message translates to:
  /// **'Consecutive 5 (連五拉五): 11 Tai'**
  String get twDealerBonusExample3;

  /// No description provided for @twDealerBonusResponsibility.
  ///
  /// In en, this message translates to:
  /// **'If another player self-draws or the dealer discards the winning tile, the dealer must pay the consecutive bonus Tai to the winner.'**
  String get twDealerBonusResponsibility;

  /// No description provided for @twNoStackRule.
  ///
  /// In en, this message translates to:
  /// **'Note: Similar Tai cannot be stacked. For example, if you count \'Missing One Suit\' you cannot also count \'No Honors\'.'**
  String get twNoStackRule;

  /// No description provided for @twScoringFormulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring Formula'**
  String get twScoringFormulaTitle;

  /// No description provided for @twScoringFormulaDesc.
  ///
  /// In en, this message translates to:
  /// **'Total Payment = (Total Tai × Score per Tai) + Base Amount'**
  String get twScoringFormulaDesc;

  /// No description provided for @twScoringExample.
  ///
  /// In en, this message translates to:
  /// **'Example: With \$10 base and \$2 per Tai, winning with 13 Tai = (13 × \$2) + \$10 = \$36'**
  String get twScoringExample;

  /// No description provided for @twScoringDefault.
  ///
  /// In en, this message translates to:
  /// **'Default if not agreed: \$10 base, \$10 per Tai'**
  String get twScoringDefault;

  /// No description provided for @twConcealedKongRule.
  ///
  /// In en, this message translates to:
  /// **'Concealed Kong'**
  String get twConcealedKongRule;

  /// No description provided for @twConcealedKongDesc.
  ///
  /// In en, this message translates to:
  /// **'Declare a concealed Kong with 4 identical tiles in hand.'**
  String get twConcealedKongDesc;

  /// No description provided for @twConcealedKongExpl.
  ///
  /// In en, this message translates to:
  /// **'Each opponent pays one base. Must be revealed at end of round; failure to reveal incurs double penalty.'**
  String get twConcealedKongExpl;

  /// No description provided for @twNoHonors.
  ///
  /// In en, this message translates to:
  /// **'No Honors'**
  String get twNoHonors;

  /// No description provided for @twDescNoHonors.
  ///
  /// In en, this message translates to:
  /// **'Hand contains no honor tiles (winds or dragons).'**
  String get twDescNoHonors;

  /// No description provided for @twExplNoHonors.
  ///
  /// In en, this message translates to:
  /// **'The entire hand has no wind or dragon tiles. 1 Tai.'**
  String get twExplNoHonors;

  /// No description provided for @twNoHonorsNoFlowers.
  ///
  /// In en, this message translates to:
  /// **'No Honors No Flowers'**
  String get twNoHonorsNoFlowers;

  /// No description provided for @twDescNoHonorsNoFlowers.
  ///
  /// In en, this message translates to:
  /// **'Hand contains no honor tiles and no flower tiles.'**
  String get twDescNoHonorsNoFlowers;

  /// No description provided for @twExplNoHonorsNoFlowers.
  ///
  /// In en, this message translates to:
  /// **'No wind, dragon, or flower tiles in the hand. 5 Tai.'**
  String get twExplNoHonorsNoFlowers;

  /// No description provided for @twNoHonorsNoFlowersPingHu.
  ///
  /// In en, this message translates to:
  /// **'Grand Ping Hu'**
  String get twNoHonorsNoFlowersPingHu;

  /// No description provided for @twDescNoHonorsNoFlowersPingHu.
  ///
  /// In en, this message translates to:
  /// **'No honors, no flowers, and qualifies as Ping Hu.'**
  String get twDescNoHonorsNoFlowersPingHu;

  /// No description provided for @twExplNoHonorsNoFlowersPingHu.
  ///
  /// In en, this message translates to:
  /// **'No honor tiles, no flowers, and the hand is all chows with a pair. 15 Tai.'**
  String get twExplNoHonorsNoFlowersPingHu;

  /// No description provided for @twChickenHand.
  ///
  /// In en, this message translates to:
  /// **'Chicken Hand'**
  String get twChickenHand;

  /// No description provided for @twDescChickenHand.
  ///
  /// In en, this message translates to:
  /// **'A winning hand worth only 1 Tai (before dealer bonus).'**
  String get twDescChickenHand;

  /// No description provided for @twExplChickenHand.
  ///
  /// In en, this message translates to:
  /// **'The base minimum win. Gets a fixed 10 Tai payout.'**
  String get twExplChickenHand;

  /// No description provided for @twDoublePong.
  ///
  /// In en, this message translates to:
  /// **'Double Pong Wait'**
  String get twDoublePong;

  /// No description provided for @twDescDoublePong.
  ///
  /// In en, this message translates to:
  /// **'Waiting on either of two pairs to become a pong for the win.'**
  String get twDescDoublePong;

  /// No description provided for @twExplDoublePong.
  ///
  /// In en, this message translates to:
  /// **'Also known as a double-sided pong wait. 1 Tai.'**
  String get twExplDoublePong;

  /// No description provided for @twFakeSingle.
  ///
  /// In en, this message translates to:
  /// **'Fake Single Wait'**
  String get twFakeSingle;

  /// No description provided for @twDescFakeSingle.
  ///
  /// In en, this message translates to:
  /// **'Could win on two sides but chose single/edge wait.'**
  String get twDescFakeSingle;

  /// No description provided for @twExplFakeSingle.
  ///
  /// In en, this message translates to:
  /// **'Waiting on a single tile when a two-sided wait was available. 1 Tai.'**
  String get twExplFakeSingle;

  /// No description provided for @twTrueSingle.
  ///
  /// In en, this message translates to:
  /// **'True Single Wait'**
  String get twTrueSingle;

  /// No description provided for @twDescTrueSingle.
  ///
  /// In en, this message translates to:
  /// **'Single tile wait, middle wait, or edge wait.'**
  String get twDescTrueSingle;

  /// No description provided for @twExplTrueSingle.
  ///
  /// In en, this message translates to:
  /// **'Winning on a single tile, closed wait, or edge wait. 2 Tai.'**
  String get twExplTrueSingle;

  /// No description provided for @twOldYoung.
  ///
  /// In en, this message translates to:
  /// **'Old & Young'**
  String get twOldYoung;

  /// No description provided for @twDescOldYoung.
  ///
  /// In en, this message translates to:
  /// **'Having both 1-2-3 and 7-8-9 sequences of the same suit.'**
  String get twDescOldYoung;

  /// No description provided for @twExplOldYoung.
  ///
  /// In en, this message translates to:
  /// **'Both ends of the same suit (1-2-3 and 7-8-9). 2 Tai.'**
  String get twExplOldYoung;

  /// No description provided for @twExposedKong.
  ///
  /// In en, this message translates to:
  /// **'Exposed Kong'**
  String get twExposedKong;

  /// No description provided for @twDescExposedKong.
  ///
  /// In en, this message translates to:
  /// **'Four identical tiles with one claimed from another player.'**
  String get twDescExposedKong;

  /// No description provided for @twExplExposedKong.
  ///
  /// In en, this message translates to:
  /// **'Declare a kong using a tile discarded by another player. 1 Tai.'**
  String get twExplExposedKong;

  /// No description provided for @twConcealedKongTai.
  ///
  /// In en, this message translates to:
  /// **'Concealed Kong'**
  String get twConcealedKongTai;

  /// No description provided for @twDescConcealedKongTai.
  ///
  /// In en, this message translates to:
  /// **'Four identical tiles all drawn by yourself.'**
  String get twDescConcealedKongTai;

  /// No description provided for @twExplConcealedKongTai.
  ///
  /// In en, this message translates to:
  /// **'All four tiles drawn from the wall. 2 Tai.'**
  String get twExplConcealedKongTai;

  /// No description provided for @twFlowerWin.
  ///
  /// In en, this message translates to:
  /// **'Win on Flower Replacement'**
  String get twFlowerWin;

  /// No description provided for @twDescFlowerWin.
  ///
  /// In en, this message translates to:
  /// **'Self-draw win on the tile drawn to replace a flower.'**
  String get twDescFlowerWin;

  /// No description provided for @twExplFlowerWin.
  ///
  /// In en, this message translates to:
  /// **'Drawing a replacement tile for a flower and winning. 1 Tai.'**
  String get twExplFlowerWin;

  /// No description provided for @twKongWin.
  ///
  /// In en, this message translates to:
  /// **'Win on Kong Replacement'**
  String get twKongWin;

  /// No description provided for @twDescKongWin.
  ///
  /// In en, this message translates to:
  /// **'Self-draw win on the tile drawn after declaring a kong.'**
  String get twDescKongWin;

  /// No description provided for @twExplKongWin.
  ///
  /// In en, this message translates to:
  /// **'Drawing a replacement tile after a kong and winning. 1 Tai.'**
  String get twExplKongWin;

  /// No description provided for @twRobbingKong.
  ///
  /// In en, this message translates to:
  /// **'Robbing the Kong'**
  String get twRobbingKong;

  /// No description provided for @twDescRobbingKong.
  ///
  /// In en, this message translates to:
  /// **'Win on a tile another player uses to upgrade a pong to kong.'**
  String get twDescRobbingKong;

  /// No description provided for @twExplRobbingKong.
  ///
  /// In en, this message translates to:
  /// **'The player upgrading their pong is considered the discarder. Not counted as self-draw. 1 Tai.'**
  String get twExplRobbingKong;

  /// No description provided for @twDoubleKongWin.
  ///
  /// In en, this message translates to:
  /// **'Double Kong Win'**
  String get twDoubleKongWin;

  /// No description provided for @twDescDoubleKongWin.
  ///
  /// In en, this message translates to:
  /// **'Win after declaring two consecutive kongs.'**
  String get twDescDoubleKongWin;

  /// No description provided for @twExplDoubleKongWin.
  ///
  /// In en, this message translates to:
  /// **'Winning on the replacement tile after two consecutive kong declarations. 30 Tai.'**
  String get twExplDoubleKongWin;

  /// No description provided for @twRobbingDoubleKong.
  ///
  /// In en, this message translates to:
  /// **'Robbing Double Kong'**
  String get twRobbingDoubleKong;

  /// No description provided for @twDescRobbingDoubleKong.
  ///
  /// In en, this message translates to:
  /// **'Robbing a kong during a consecutive kong sequence.'**
  String get twDescRobbingDoubleKong;

  /// No description provided for @twExplRobbingDoubleKong.
  ///
  /// In en, this message translates to:
  /// **'Winning by robbing during consecutive kongs. 30 Tai.'**
  String get twExplRobbingDoubleKong;

  /// No description provided for @twTwoConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Two Concealed Pongs'**
  String get twTwoConcealedPongs;

  /// No description provided for @twDescTwoConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Two pongs formed entirely from self-drawn tiles.'**
  String get twDescTwoConcealedPongs;

  /// No description provided for @twExplTwoConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Two concealed (self-drawn) pongs. 3 Tai.'**
  String get twExplTwoConcealedPongs;

  /// No description provided for @twThreeConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Three Concealed Pongs'**
  String get twThreeConcealedPongs;

  /// No description provided for @twDescThreeConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Three pongs formed entirely from self-drawn tiles.'**
  String get twDescThreeConcealedPongs;

  /// No description provided for @twExplThreeConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Three concealed pongs. 10 Tai.'**
  String get twExplThreeConcealedPongs;

  /// No description provided for @twFourConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Four Concealed Pongs'**
  String get twFourConcealedPongs;

  /// No description provided for @twDescFourConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Four pongs formed entirely from self-drawn tiles.'**
  String get twDescFourConcealedPongs;

  /// No description provided for @twExplFourConcealedPongs.
  ///
  /// In en, this message translates to:
  /// **'Four concealed pongs. 30 Tai.'**
  String get twExplFourConcealedPongs;

  /// No description provided for @twIdenticalSequenceTwo.
  ///
  /// In en, this message translates to:
  /// **'Two Identical Sequences'**
  String get twIdenticalSequenceTwo;

  /// No description provided for @twDescIdenticalSequenceTwo.
  ///
  /// In en, this message translates to:
  /// **'Two exactly identical chow sequences.'**
  String get twDescIdenticalSequenceTwo;

  /// No description provided for @twExplIdenticalSequenceTwo.
  ///
  /// In en, this message translates to:
  /// **'Two identical chows (same suit, same numbers). 3 Tai.'**
  String get twExplIdenticalSequenceTwo;

  /// No description provided for @twIdenticalSequenceThree.
  ///
  /// In en, this message translates to:
  /// **'Three Identical Sequences'**
  String get twIdenticalSequenceThree;

  /// No description provided for @twDescIdenticalSequenceThree.
  ///
  /// In en, this message translates to:
  /// **'Three exactly identical chow sequences.'**
  String get twDescIdenticalSequenceThree;

  /// No description provided for @twExplIdenticalSequenceThree.
  ///
  /// In en, this message translates to:
  /// **'Three identical chows. Open: 15 Tai, Concealed: 20 Tai.'**
  String get twExplIdenticalSequenceThree;

  /// No description provided for @twIdenticalSequenceFour.
  ///
  /// In en, this message translates to:
  /// **'Four Identical Sequences'**
  String get twIdenticalSequenceFour;

  /// No description provided for @twDescIdenticalSequenceFour.
  ///
  /// In en, this message translates to:
  /// **'Four exactly identical chow sequences.'**
  String get twDescIdenticalSequenceFour;

  /// No description provided for @twExplIdenticalSequenceFour.
  ///
  /// In en, this message translates to:
  /// **'Four identical chows. 30 Tai.'**
  String get twExplIdenticalSequenceFour;

  /// No description provided for @twMixedDoubleSeq.
  ///
  /// In en, this message translates to:
  /// **'Two Mixed Sequences'**
  String get twMixedDoubleSeq;

  /// No description provided for @twDescMixedDoubleSeq.
  ///
  /// In en, this message translates to:
  /// **'Same number sequences from two different suits.'**
  String get twDescMixedDoubleSeq;

  /// No description provided for @twExplMixedDoubleSeq.
  ///
  /// In en, this message translates to:
  /// **'Two chows with same numbers in different suits. 2 Tai.'**
  String get twExplMixedDoubleSeq;

  /// No description provided for @twMixedTripleSeq.
  ///
  /// In en, this message translates to:
  /// **'Three Mixed Sequences'**
  String get twMixedTripleSeq;

  /// No description provided for @twDescMixedTripleSeq.
  ///
  /// In en, this message translates to:
  /// **'Same number sequences from three different suits.'**
  String get twDescMixedTripleSeq;

  /// No description provided for @twExplMixedTripleSeq.
  ///
  /// In en, this message translates to:
  /// **'Three chows with same numbers in three suits. Open: 15 Tai, Concealed: 20 Tai.'**
  String get twExplMixedTripleSeq;

  /// No description provided for @twFiveIdenticalSeq.
  ///
  /// In en, this message translates to:
  /// **'Five Identical Sequences'**
  String get twFiveIdenticalSeq;

  /// No description provided for @twDescFiveIdenticalSeq.
  ///
  /// In en, this message translates to:
  /// **'Five sequences with the same numbers across suits.'**
  String get twDescFiveIdenticalSeq;

  /// No description provided for @twExplFiveIdenticalSeq.
  ///
  /// In en, this message translates to:
  /// **'Five same-number sequences (includes 3-suit combo). 45 Tai.'**
  String get twExplFiveIdenticalSeq;

  /// No description provided for @twTwoBrothers.
  ///
  /// In en, this message translates to:
  /// **'Two Brothers'**
  String get twTwoBrothers;

  /// No description provided for @twDescTwoBrothers.
  ///
  /// In en, this message translates to:
  /// **'Two pongs of the same number in different suits.'**
  String get twDescTwoBrothers;

  /// No description provided for @twExplTwoBrothers.
  ///
  /// In en, this message translates to:
  /// **'Same-number pongs in two suits. 3 Tai.'**
  String get twExplTwoBrothers;

  /// No description provided for @twSmallThreeBrothers.
  ///
  /// In en, this message translates to:
  /// **'Small Three Brothers'**
  String get twSmallThreeBrothers;

  /// No description provided for @twDescSmallThreeBrothers.
  ///
  /// In en, this message translates to:
  /// **'Two same-number pongs plus a pair of the third suit.'**
  String get twDescSmallThreeBrothers;

  /// No description provided for @twExplSmallThreeBrothers.
  ///
  /// In en, this message translates to:
  /// **'Two pongs and one pair, all same number in three suits. 10 Tai.'**
  String get twExplSmallThreeBrothers;

  /// No description provided for @twBigThreeBrothers.
  ///
  /// In en, this message translates to:
  /// **'Big Three Brothers'**
  String get twBigThreeBrothers;

  /// No description provided for @twDescBigThreeBrothers.
  ///
  /// In en, this message translates to:
  /// **'Three pongs of the same number in all three suits.'**
  String get twDescBigThreeBrothers;

  /// No description provided for @twExplBigThreeBrothers.
  ///
  /// In en, this message translates to:
  /// **'Same-number pongs in all three suits. 15 Tai.'**
  String get twExplBigThreeBrothers;

  /// No description provided for @twSmallThreeSisters.
  ///
  /// In en, this message translates to:
  /// **'Small Three Sisters'**
  String get twSmallThreeSisters;

  /// No description provided for @twDescSmallThreeSisters.
  ///
  /// In en, this message translates to:
  /// **'Two consecutive pongs of same suit plus a consecutive pair.'**
  String get twDescSmallThreeSisters;

  /// No description provided for @twExplSmallThreeSisters.
  ///
  /// In en, this message translates to:
  /// **'Two same-suit consecutive pongs and a consecutive pair. 8 Tai.'**
  String get twExplSmallThreeSisters;

  /// No description provided for @twBigThreeSisters.
  ///
  /// In en, this message translates to:
  /// **'Big Three Sisters'**
  String get twBigThreeSisters;

  /// No description provided for @twDescBigThreeSisters.
  ///
  /// In en, this message translates to:
  /// **'Three consecutive pongs of the same suit.'**
  String get twDescBigThreeSisters;

  /// No description provided for @twExplBigThreeSisters.
  ///
  /// In en, this message translates to:
  /// **'Three same-suit consecutive pongs (e.g., 333-444-555). 15 Tai.'**
  String get twExplBigThreeSisters;

  /// No description provided for @twFourToOne.
  ///
  /// In en, this message translates to:
  /// **'Four-to-One'**
  String get twFourToOne;

  /// No description provided for @twDescFourToOne.
  ///
  /// In en, this message translates to:
  /// **'Four identical tiles split across chow and pong sets.'**
  String get twDescFourToOne;

  /// No description provided for @twExplFourToOne.
  ///
  /// In en, this message translates to:
  /// **'Open: 3 Tai, Concealed: 5 Tai.'**
  String get twExplFourToOne;

  /// No description provided for @twFourToTwo.
  ///
  /// In en, this message translates to:
  /// **'Four-to-Two'**
  String get twFourToTwo;

  /// No description provided for @twDescFourToTwo.
  ///
  /// In en, this message translates to:
  /// **'Four identical tiles: two as the pair, two in chows.'**
  String get twDescFourToTwo;

  /// No description provided for @twExplFourToTwo.
  ///
  /// In en, this message translates to:
  /// **'Two of the same tile as pair, two in sequences. 10 Tai.'**
  String get twExplFourToTwo;

  /// No description provided for @twFourToFour.
  ///
  /// In en, this message translates to:
  /// **'Four-to-Four'**
  String get twFourToFour;

  /// No description provided for @twDescFourToFour.
  ///
  /// In en, this message translates to:
  /// **'Four identical tiles all in separate chow sequences.'**
  String get twDescFourToFour;

  /// No description provided for @twExplFourToFour.
  ///
  /// In en, this message translates to:
  /// **'All four of a tile distributed in sequences. 20 Tai.'**
  String get twExplFourToFour;

  /// No description provided for @twExposedDragon.
  ///
  /// In en, this message translates to:
  /// **'Exposed Dragon'**
  String get twExposedDragon;

  /// No description provided for @twDescExposedDragon.
  ///
  /// In en, this message translates to:
  /// **'A 1-9 straight of one suit, partially claimed from others.'**
  String get twDescExposedDragon;

  /// No description provided for @twExplExposedDragon.
  ///
  /// In en, this message translates to:
  /// **'Complete 1-9 run of one suit with some tiles from others. 10 Tai.'**
  String get twExplExposedDragon;

  /// No description provided for @twExposedMixedDragon.
  ///
  /// In en, this message translates to:
  /// **'Exposed Mixed Dragon'**
  String get twExposedMixedDragon;

  /// No description provided for @twDescExposedMixedDragon.
  ///
  /// In en, this message translates to:
  /// **'A 1-9 straight across different suits, partially claimed.'**
  String get twDescExposedMixedDragon;

  /// No description provided for @twExplExposedMixedDragon.
  ///
  /// In en, this message translates to:
  /// **'1-9 run across suits with some tiles from others. 8 Tai.'**
  String get twExplExposedMixedDragon;

  /// No description provided for @twConcealedMixedDragon.
  ///
  /// In en, this message translates to:
  /// **'Concealed Mixed Dragon'**
  String get twConcealedMixedDragon;

  /// No description provided for @twDescConcealedMixedDragon.
  ///
  /// In en, this message translates to:
  /// **'A 1-9 straight across different suits, all self-drawn.'**
  String get twDescConcealedMixedDragon;

  /// No description provided for @twExplConcealedMixedDragon.
  ///
  /// In en, this message translates to:
  /// **'1-9 run across suits, entirely concealed. 15 Tai.'**
  String get twExplConcealedMixedDragon;

  /// No description provided for @twFiveGates.
  ///
  /// In en, this message translates to:
  /// **'Five Gates'**
  String get twFiveGates;

  /// No description provided for @twDescFiveGates.
  ///
  /// In en, this message translates to:
  /// **'Hand contains all five tile types: man, pin, sou, wind, dragon.'**
  String get twDescFiveGates;

  /// No description provided for @twExplFiveGates.
  ///
  /// In en, this message translates to:
  /// **'Having tiles from all five categories. 5 Tai.'**
  String get twExplFiveGates;

  /// No description provided for @twMissingOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Missing One Suit'**
  String get twMissingOneSuit;

  /// No description provided for @twDescMissingOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Hand is missing one of the three number suits.'**
  String get twDescMissingOneSuit;

  /// No description provided for @twExplMissingOneSuit.
  ///
  /// In en, this message translates to:
  /// **'Lacking bamboo, dots, or characters entirely. 3 Tai.'**
  String get twExplMissingOneSuit;

  /// No description provided for @twAllRevealed.
  ///
  /// In en, this message translates to:
  /// **'All Revealed (Full Exposed)'**
  String get twAllRevealed;

  /// No description provided for @twDescAllRevealed.
  ///
  /// In en, this message translates to:
  /// **'All sets are exposed (chow/pong/kong), win by discard only.'**
  String get twDescAllRevealed;

  /// No description provided for @twExplAllRevealed.
  ///
  /// In en, this message translates to:
  /// **'Single tile wait with all groups exposed, win by discard. 15 Tai.'**
  String get twExplAllRevealed;

  /// No description provided for @twHalfRevealed.
  ///
  /// In en, this message translates to:
  /// **'Half Revealed'**
  String get twHalfRevealed;

  /// No description provided for @twDescHalfRevealed.
  ///
  /// In en, this message translates to:
  /// **'All sets are exposed, win by self-draw on single wait.'**
  String get twDescHalfRevealed;

  /// No description provided for @twExplHalfRevealed.
  ///
  /// In en, this message translates to:
  /// **'All groups exposed but winning by self-draw. 8 Tai.'**
  String get twExplHalfRevealed;

  /// No description provided for @twLastSevenTiles.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Tiles'**
  String get twLastSevenTiles;

  /// No description provided for @twDescLastSevenTiles.
  ///
  /// In en, this message translates to:
  /// **'Win when only 7 tiles remain in the wall.'**
  String get twDescLastSevenTiles;

  /// No description provided for @twExplLastSevenTiles.
  ///
  /// In en, this message translates to:
  /// **'Winning within the last 7 remaining tiles. 20 Tai.'**
  String get twExplLastSevenTiles;

  /// No description provided for @twLastTenTiles.
  ///
  /// In en, this message translates to:
  /// **'Last 10 Tiles'**
  String get twLastTenTiles;

  /// No description provided for @twDescLastTenTiles.
  ///
  /// In en, this message translates to:
  /// **'Win when only 10 tiles remain in the wall.'**
  String get twDescLastTenTiles;

  /// No description provided for @twExplLastTenTiles.
  ///
  /// In en, this message translates to:
  /// **'Winning within the last 10 remaining tiles. 10 Tai.'**
  String get twExplLastTenTiles;

  /// No description provided for @twSmallThreeWinds.
  ///
  /// In en, this message translates to:
  /// **'Small Three Winds'**
  String get twSmallThreeWinds;

  /// No description provided for @twDescSmallThreeWinds.
  ///
  /// In en, this message translates to:
  /// **'Two wind pongs and one wind pair.'**
  String get twDescSmallThreeWinds;

  /// No description provided for @twExplSmallThreeWinds.
  ///
  /// In en, this message translates to:
  /// **'Two pongs and one pair of wind tiles. 15 Tai.'**
  String get twExplSmallThreeWinds;

  /// No description provided for @twBigThreeWinds.
  ///
  /// In en, this message translates to:
  /// **'Big Three Winds'**
  String get twBigThreeWinds;

  /// No description provided for @twDescBigThreeWinds.
  ///
  /// In en, this message translates to:
  /// **'Three wind pongs.'**
  String get twDescBigThreeWinds;

  /// No description provided for @twExplBigThreeWinds.
  ///
  /// In en, this message translates to:
  /// **'Three pongs of wind tiles. 30 Tai.'**
  String get twExplBigThreeWinds;

  /// No description provided for @twSixteenNonMatching.
  ///
  /// In en, this message translates to:
  /// **'Sixteen Non-Matching'**
  String get twSixteenNonMatching;

  /// No description provided for @twDescSixteenNonMatching.
  ///
  /// In en, this message translates to:
  /// **'16 tiles with specific spacing that cannot form any set.'**
  String get twDescSixteenNonMatching;

  /// No description provided for @twExplSixteenNonMatching.
  ///
  /// In en, this message translates to:
  /// **'A special hand of 16 tiles that form no valid sets. 50 Tai.'**
  String get twExplSixteenNonMatching;

  /// No description provided for @twOneFlowerSet.
  ///
  /// In en, this message translates to:
  /// **'One Flower Set'**
  String get twOneFlowerSet;

  /// No description provided for @twDescOneFlowerSet.
  ///
  /// In en, this message translates to:
  /// **'Collected all 4 tiles of one flower series.'**
  String get twDescOneFlowerSet;

  /// No description provided for @twExplOneFlowerSet.
  ///
  /// In en, this message translates to:
  /// **'A complete season (Spring/Summer/Fall/Winter) or plant (Plum/Orchid/Bamboo/Chrysanthemum) set. 10 Tai.'**
  String get twExplOneFlowerSet;

  /// No description provided for @twTwoFlowerSets.
  ///
  /// In en, this message translates to:
  /// **'Two Flower Sets (Flower Win)'**
  String get twTwoFlowerSets;

  /// No description provided for @twDescTwoFlowerSets.
  ///
  /// In en, this message translates to:
  /// **'Collected all 8 flower tiles. Instant win.'**
  String get twDescTwoFlowerSets;

  /// No description provided for @twExplTwoFlowerSets.
  ///
  /// In en, this message translates to:
  /// **'Having all 8 flowers is an instant win. 30 Tai. Hand tiles do not count.'**
  String get twExplTwoFlowerSets;

  /// No description provided for @twMixedTerminalsPongs.
  ///
  /// In en, this message translates to:
  /// **'Mixed Terminals'**
  String get twMixedTerminalsPongs;

  /// No description provided for @twDescMixedTerminalsPongs.
  ///
  /// In en, this message translates to:
  /// **'All sets contain 1/9 or honor tiles.'**
  String get twDescMixedTerminalsPongs;

  /// No description provided for @twExplMixedTerminalsPongs.
  ///
  /// In en, this message translates to:
  /// **'Every set includes a terminal (1,9) or honor tile. 30 Tai.'**
  String get twExplMixedTerminalsPongs;

  /// No description provided for @twPureTerminalsTw.
  ///
  /// In en, this message translates to:
  /// **'Pure Terminals'**
  String get twPureTerminalsTw;

  /// No description provided for @twDescPureTerminalsTw.
  ///
  /// In en, this message translates to:
  /// **'All tiles are 1s and 9s only.'**
  String get twDescPureTerminalsTw;

  /// No description provided for @twExplPureTerminalsTw.
  ///
  /// In en, this message translates to:
  /// **'Entire hand made of 1 and 9 tiles only. 80 Tai.'**
  String get twExplPureTerminalsTw;

  /// No description provided for @twMixedTerminalChows.
  ///
  /// In en, this message translates to:
  /// **'Mixed Terminal Chows'**
  String get twMixedTerminalChows;

  /// No description provided for @twDescMixedTerminalChows.
  ///
  /// In en, this message translates to:
  /// **'Every set contains a 1 or 9, plus honor tiles.'**
  String get twDescMixedTerminalChows;

  /// No description provided for @twExplMixedTerminalChows.
  ///
  /// In en, this message translates to:
  /// **'All sets include a terminal, with honors allowed. 10 Tai.'**
  String get twExplMixedTerminalChows;

  /// No description provided for @twPureTerminalChows.
  ///
  /// In en, this message translates to:
  /// **'Pure Terminal Chows'**
  String get twPureTerminalChows;

  /// No description provided for @twDescPureTerminalChows.
  ///
  /// In en, this message translates to:
  /// **'Every set contains a 1 or 9, no honor tiles.'**
  String get twDescPureTerminalChows;

  /// No description provided for @twExplPureTerminalChows.
  ///
  /// In en, this message translates to:
  /// **'All sets include a terminal tile, no honors. 15 Tai.'**
  String get twExplPureTerminalChows;

  /// No description provided for @twHumanWin.
  ///
  /// In en, this message translates to:
  /// **'Human Win'**
  String get twHumanWin;

  /// No description provided for @twDescHumanWin.
  ///
  /// In en, this message translates to:
  /// **'Non-dealer wins by discard in the first turn cycle.'**
  String get twDescHumanWin;

  /// No description provided for @twExplHumanWin.
  ///
  /// In en, this message translates to:
  /// **'A non-dealer wins on a discard during the very first go-around. 80 Tai.'**
  String get twExplHumanWin;

  /// No description provided for @twSevenRobOne.
  ///
  /// In en, this message translates to:
  /// **'Seven Rob One'**
  String get twSevenRobOne;

  /// No description provided for @twDescSevenRobOne.
  ///
  /// In en, this message translates to:
  /// **'With 7 flower tiles, win the 8th from another player.'**
  String get twDescSevenRobOne;

  /// No description provided for @twExplSevenRobOne.
  ///
  /// In en, this message translates to:
  /// **'Having 7 flowers and claiming the last one from another player. 15 Tai.'**
  String get twExplSevenRobOne;

  /// No description provided for @twHeavenlyReady.
  ///
  /// In en, this message translates to:
  /// **'Heavenly Ready'**
  String get twHeavenlyReady;

  /// No description provided for @twDescHeavenlyReady.
  ///
  /// In en, this message translates to:
  /// **'Dealer declares ready on opening hand (includes Ding bonus).'**
  String get twDescHeavenlyReady;

  /// No description provided for @twExplHeavenlyReady.
  ///
  /// In en, this message translates to:
  /// **'Dealer declares Tenpai immediately. Includes the 5 Tai for Ding. 50 Tai.'**
  String get twExplHeavenlyReady;

  /// No description provided for @twEarthlyReady.
  ///
  /// In en, this message translates to:
  /// **'Earthly Ready'**
  String get twEarthlyReady;

  /// No description provided for @twDescEarthlyReady.
  ///
  /// In en, this message translates to:
  /// **'Non-dealer declares ready on first draw (includes Ding bonus).'**
  String get twDescEarthlyReady;

  /// No description provided for @twExplEarthlyReady.
  ///
  /// In en, this message translates to:
  /// **'Non-dealer declares Tenpai on first turn. Includes 5 Tai for Ding. 25 Tai.'**
  String get twExplEarthlyReady;

  /// No description provided for @twMiguiTw.
  ///
  /// In en, this message translates to:
  /// **'Eight Pairs (嚦咕嚦咕)'**
  String get twMiguiTw;

  /// No description provided for @twDescMiguiTw.
  ///
  /// In en, this message translates to:
  /// **'Eight pairs in hand (no triplets allowed).'**
  String get twDescMiguiTw;

  /// No description provided for @twExplMiguiTw.
  ///
  /// In en, this message translates to:
  /// **'Eight distinct pairs. Cannot have three of the same tile melded. 40 Tai.'**
  String get twExplMiguiTw;

  /// No description provided for @twStackRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stacking Rules'**
  String get twStackRulesTitle;

  /// No description provided for @twStackRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Some Tai combinations cannot be counted together. Higher-level patterns override lower ones.'**
  String get twStackRulesDesc;

  /// No description provided for @twStackRule1.
  ///
  /// In en, this message translates to:
  /// **'Five Identical Seq. already includes Three Mixed Seq., Two/Three/Four Identical Seq.'**
  String get twStackRule1;

  /// No description provided for @twStackRule2.
  ///
  /// In en, this message translates to:
  /// **'Missing One Suit cannot be stacked with No Honors.'**
  String get twStackRule2;

  /// No description provided for @twStackRule3.
  ///
  /// In en, this message translates to:
  /// **'Heavenly Ready (50) and Earthly Ready (25) already include Ding (5).'**
  String get twStackRule3;

  /// No description provided for @twStackRule4.
  ///
  /// In en, this message translates to:
  /// **'Two Flower Sets (Flower Win, 30) means hand tiles do not count.'**
  String get twStackRule4;

  /// No description provided for @twStackRule5.
  ///
  /// In en, this message translates to:
  /// **'Pure One Suit (80) already overrides Mixed One Suit and No Honors.'**
  String get twStackRule5;

  /// No description provided for @twStackRule6.
  ///
  /// In en, this message translates to:
  /// **'Robbing Kong is not counted as self-draw; the kong player pays.'**
  String get twStackRule6;

  /// No description provided for @twStackRule7.
  ///
  /// In en, this message translates to:
  /// **'Chicken Hand (10) only applies when hand is worth exactly 1 Tai before dealer bonus.'**
  String get twStackRule7;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
