import '../logic/hand_patterns.dart';
import '../localization/app_localizations.dart';
import 'rule.dart';

// Predefined Hong Kong Mahjong rules list (Old Style / Qing Zhang)
List<Rule> get hkRules => [
  // 1 Fan
  Rule(
    name: AppLocalizations.ruleAllChows,
    description: AppLocalizations.descAllChows,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explAllChows,
    validator: HandPatterns.isPingHu,
    exampleTiles: [
      ['1p', '2p', '3p'],
      ['4s', '5s', '6s'],
      ['7m', '8m', '9m'],
      ['2p', '3p', '4p'],
      ['5s', '5s'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleNoFlowers,
    description: AppLocalizations.descNoFlowers,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explNoFlowers,
    exampleTiles: [],
    // Validator handled by flower count check in UI or manually
  ),
  Rule(
    name: AppLocalizations.ruleOwnSeason,
    description: AppLocalizations.descOwnSeason,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explOwnSeason,
    exampleTiles: [
      ['1f', '5f'], // Plum (1) and Spring (1) for East
    ],
    // Validator requires seat context
  ),
  Rule(
    name: AppLocalizations.ruleSelfDraw,
    description: AppLocalizations.descSelfDraw,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explSelfDraw,
    exampleTiles: [],
    // Validator handled by UI state
  ),
  Rule(
    name: AppLocalizations.ruleMenQianQing,
    description: AppLocalizations.descMenQianQing,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explMenQianQing,
    exampleTiles: [],
    // Validator requires exposed state
  ),
  Rule(
    name: AppLocalizations.ruleDragonWindPong,
    description: AppLocalizations.descDragonWindPong,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explDragonWindPong,
    exampleTiles: [
      ['5z', '5z', '5z'],
    ],
    // Validator requires context or specific check. 
  ),
  Rule(
    name: AppLocalizations.ruleRobbingKong,
    description: AppLocalizations.descRobbingKong,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explRobbingKong,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.ruleHaidilao,
    description: AppLocalizations.descHaidilao,
    fan: AppLocalizations.fan(1),
    fanValue: 1,
    explanation: AppLocalizations.explHaidilao,
    exampleTiles: [],
  ),

  // 2 Fan
  Rule(
    name: AppLocalizations.ruleKongOnKong,
    description: AppLocalizations.descKongOnKong,
    fan: AppLocalizations.fan(2),
    fanValue: 2,
    explanation: AppLocalizations.explKongOnKong,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.ruleFlowerPlatform,
    description: AppLocalizations.descFlowerPlatform,
    fan: AppLocalizations.fan(2),
    fanValue: 2,
    explanation: AppLocalizations.explFlowerPlatform,
    exampleTiles: [
      ['1f', '2f', '3f', '4f'], // Flowers: Plum, Orchid, Chrysanthemum, Bamboo
      ['5f', '6f', '7f', '8f'], // Seasons: Spring, Summer, Autumn, Winter
    ],
  ),

  // 3 Fan
  Rule(
    name: AppLocalizations.ruleSevenFlowers,
    description: AppLocalizations.descSevenFlowers,
    fan: AppLocalizations.fan(3),
    fanValue: 3,
    explanation: AppLocalizations.explSevenFlowers,
    exampleTiles: [
      ['1f', '2f', '3f', '4f', '5f', '6f', '7f'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleAllPongs,
    description: AppLocalizations.descAllPongs,
    fan: AppLocalizations.fan(3),
    fanValue: 3,
    explanation: AppLocalizations.explAllPongs,
    validator: HandPatterns.isAllPongs,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['2s', '2s', '2s'],
      ['3m', '3m', '3m'],
      ['4p', '4p', '4p'],
      ['5z', '5z'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleMixedOneSuit,
    description: AppLocalizations.descMixedOneSuit,
    fan: AppLocalizations.fan(3),
    fanValue: 3,
    explanation: AppLocalizations.explMixedOneSuit,
    validator: HandPatterns.isMixedOneSuit,
    exampleTiles: [
      ['1p', '2p', '3p'],
      ['4p', '5p', '6p'],
      ['9p', '9p', '9p'],
      ['1z', '1z', '1z'],
      ['2z', '2z'],
    ],
  ),

  // 4 Fan
  Rule(
    name: AppLocalizations.ruleSevenPairs,
    description: AppLocalizations.descSevenPairs,
    fan: AppLocalizations.fan(4),
    fanValue: 4,
    explanation: AppLocalizations.explSevenPairs,
    validator: HandPatterns.isSevenPairs,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.ruleMixedTerminals,
    description: AppLocalizations.descMixedTerminals,
    fan: AppLocalizations.fan(4),
    fanValue: 4,
    explanation: AppLocalizations.explMixedTerminals,
    validator: HandPatterns.isMixedTerminals,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['9s', '9s', '9s'],
      ['1m', '1m', '1m'],
      ['1z', '1z', '1z'],
      ['5z', '5z'],
    ],
  ),

  // 5 Fan
  Rule(
    name: AppLocalizations.ruleSmallThreeDragons,
    description: AppLocalizations.descSmallThreeDragons,
    fan: AppLocalizations.fan(5),
    fanValue: 5,
    explanation: AppLocalizations.explSmallThreeDragons,
    validator: HandPatterns.isSmallThreeDragons,
    exampleTiles: [
      ['5z', '5z', '5z'],
      ['6z', '6z', '6z'],
      ['7z', '7z'],
      ['1p', '2p', '3p'],
      ['4s', '5s', '6s'],
    ],
  ),

  // 6 Fan
  Rule(
    name: AppLocalizations.ruleSmallFourWinds,
    description: AppLocalizations.descSmallFourWinds,
    fan: AppLocalizations.fan(6),
    fanValue: 6,
    explanation: AppLocalizations.explSmallFourWinds,
    validator: HandPatterns.isSmallFourWinds,
    exampleTiles: [
      ['1z', '1z', '1z'],
      ['2z', '2z', '2z'],
      ['3z', '3z', '3z'],
      ['4z', '4z'],
      ['1p', '2p', '3p'],
    ],
  ),

  // 7 Fan
  Rule(
    name: AppLocalizations.rulePureOneSuit,
    description: AppLocalizations.descPureOneSuit,
    fan: AppLocalizations.fan(7),
    fanValue: 7,
    explanation: AppLocalizations.explPureOneSuit,
    validator: HandPatterns.isPureHand,
    exampleTiles: [
      ['1p', '2p', '3p'],
      ['4p', '5p', '6p'],
      ['7p', '8p', '9p'],
      ['1p', '1p', '1p'],
      ['9p', '9p'],
    ],
  ),

  // 8 Fan
  Rule(
    name: AppLocalizations.ruleBigThreeDragons,
    description: AppLocalizations.descBigThreeDragons,
    fan: AppLocalizations.fan(8),
    fanValue: 8,
    explanation: AppLocalizations.explBigThreeDragons,
    validator: HandPatterns.isBigThreeDragons,
    exampleTiles: [
      ['5z', '5z', '5z'],
      ['6z', '6z', '6z'],
      ['7z', '7z', '7z'],
      ['1p', '2p', '3p'],
      ['9s', '9s'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleEightImmortals,
    description: AppLocalizations.descEightImmortals,
    fan: AppLocalizations.fan(8),
    fanValue: 8,
    explanation: AppLocalizations.explEightImmortals,
    exampleTiles: [
      ['1f', '2f', '3f', '4f', '5f', '6f', '7f', '8f'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleHiddenTreasure,
    description: AppLocalizations.descHiddenTreasure,
    fan: AppLocalizations.fan(8),
    fanValue: 8,
    explanation: AppLocalizations.explHiddenTreasure,
    exampleTiles: [],
    // Validator requires concealed state
  ),

  // 9 Fan
  Rule(
    name: AppLocalizations.ruleDoubleKong,
    description: AppLocalizations.descDoubleKong,
    fan: AppLocalizations.fan(9),
    fanValue: 9,
    explanation: AppLocalizations.explDoubleKong,
    exampleTiles: [],
  ),

  // 10 Fan
  Rule(
    name: AppLocalizations.ruleAllHonors,
    description: AppLocalizations.descAllHonors,
    fan: AppLocalizations.fan(10),
    fanValue: 10,
    explanation: AppLocalizations.explAllHonors,
    validator: HandPatterns.isAllHonors,
    exampleTiles: [
      ['1z', '1z', '1z'],
      ['2z', '2z', '2z'],
      ['3z', '3z', '3z'],
      ['4z', '4z', '4z'],
      ['5z', '5z'],
    ],
  ),
  Rule(
    name: AppLocalizations.rulePureTerminals,
    description: AppLocalizations.descPureTerminals,
    fan: AppLocalizations.fan(10),
    fanValue: 10,
    explanation: AppLocalizations.explPureTerminals,
    validator: HandPatterns.isPureTerminals,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['9p', '9p', '9p'],
      ['1s', '1s', '1s'],
      ['9s', '9s', '9s'],
      ['1m', '1m'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleNineGates,
    description: AppLocalizations.descNineGates,
    fan: AppLocalizations.fan(10),
    fanValue: 10,
    explanation: AppLocalizations.explNineGates,
    validator: HandPatterns.isNineGates,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['2p', '3p', '4p', '5p', '6p', '7p', '8p'],
      ['9p', '9p', '9p'],
      ['5p', '5p'], // Example pair
    ],
  ),

  // 13 Fan
  Rule(
    name: AppLocalizations.ruleThirteenOrphans,
    description: AppLocalizations.descThirteenOrphans,
    fan: AppLocalizations.fan(13),
    fanValue: 13,
    explanation: AppLocalizations.explThirteenOrphans,
    validator: HandPatterns.isThirteenOrphans,
    exampleTiles: [
      ['1m', '9m', '1p', '9p', '1s', '9s', '1z', '2z', '3z', '4z', '5z', '6z', '7z', '1m'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleBlessingMan,
    description: AppLocalizations.descBlessingMan,
    fan: AppLocalizations.fan(13),
    fanValue: 13,
    explanation: AppLocalizations.explBlessingMan,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.ruleEarthlyHand,
    description: AppLocalizations.descEarthlyHand,
    fan: AppLocalizations.fan(13),
    fanValue: 13,
    explanation: AppLocalizations.explEarthlyHand,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.ruleHeavenlyHand,
    description: AppLocalizations.descHeavenlyHand,
    fan: AppLocalizations.fan(13),
    fanValue: 13,
    explanation: AppLocalizations.explHeavenlyHand,
    exampleTiles: [],
  ),
  Rule(
    name: AppLocalizations.ruleBigFourWinds,
    description: AppLocalizations.descBigFourWinds,
    fan: AppLocalizations.fan(13),
    fanValue: 13,
    explanation: AppLocalizations.explBigFourWinds,
    validator: HandPatterns.isBigFourWinds,
    exampleTiles: [
      ['1z', '1z', '1z'],
      ['2z', '2z', '2z'],
      ['3z', '3z', '3z'],
      ['4z', '4z', '4z'],
      ['1p', '1p'],
    ],
  ),
  Rule(
    name: AppLocalizations.ruleEighteenArhats,
    description: AppLocalizations.descEighteenArhats,
    fan: AppLocalizations.fan(13),
    fanValue: 13,
    explanation: AppLocalizations.explEighteenArhats,
    validator: HandPatterns.isEighteenArhats,
    exampleTiles: [
      ['1p', '1p', '1p', '1p'],
      ['2s', '2s', '2s', '2s'],
      ['3m', '3m', '3m', '3m'],
      ['4p', '4p', '4p', '4p'],
      ['5z', '5z'],
    ],
  ),
];
