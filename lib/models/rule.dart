import '../utils/mahjong_logic.dart';

class Rule {
  final String name;
  final String description;
  final String fan;
  final String imagePath;
  final String explanation;
  final List<List<String>> exampleTiles; // Each sublist represents a set of tiles
  final bool Function(List<String>)? validator;

  Rule({
    required this.name,
    required this.description,
    required this.fan,
    this.imagePath = '',
    required this.explanation,
    required this.exampleTiles,
    this.validator,
  });
}

// Predefined Hong Kong Mahjong rules list (Old Style / Qing Zhang)
final List<Rule> rules = [
  // 1 Fan
  Rule(
    name: 'Ping Hu (平胡 - Ping4 Wu4)',
    description: 'Hand with only Chows, no Pongs.',
    fan: '1 fan',
    explanation: 'Hand composed entirely of Chows (sequences) and a pair. No Pongs or Kongs.',
    validator: MahjongLogic.isPingHu,
    exampleTiles: [
      ['1p', '2p', '3p'],
      ['4s', '5s', '6s'],
      ['7m', '8m', '9m'],
      ['2p', '3p', '4p'],
      ['5s', '5s'],
    ],
  ),
  Rule(
    name: 'No Flowers (無花 - Mou4 Faa1)',
    description: 'No Flower tiles.',
    fan: '1 fan',
    explanation: 'Winning without any Flower tiles.',
    exampleTiles: [],
    // Validator handled by flower count check in UI or manually
  ),
  Rule(
    name: 'Own Flower (正花 - Zing3 Faa1)',
    description: 'Flower tile matches your seat wind.',
    fan: '1 fan',
    explanation: 'The Flower tile number corresponds to your seat wind (1=East, 2=South, 3=West, 4=North).',
    exampleTiles: [
      ['1f', '5f'], // Plum (1) and Spring (1) for East
    ],
    // Validator requires seat context
  ),
  Rule(
    name: 'Self-Draw (自摸 - Zi6 Mo1)',
    description: 'Winning by self-drawn tile.',
    fan: '1 fan',
    explanation: 'Drawing the winning tile yourself adds 1 fan.',
    exampleTiles: [],
    // Validator handled by UI state
  ),
  Rule(
    name: 'Men Qian Qing (門前清 - Mun4 Cin4 Cing1)',
    description: 'Winning without melding (Chow, Pong, Kong) any exposed tiles.',
    fan: '1 fan',
    explanation: 'Concealed hand. No exposed melds before winning.',
    exampleTiles: [],
    // Validator requires exposed state
  ),
  Rule(
    name: 'Dragon/Wind Pong (番子 - Faan1 Zi2)',
    description: 'Pong of Dragons or Seat/Round Wind.',
    fan: '1 fan',
    explanation: 'A Pong/Kong of Red, Green, or White Dragons, or a Pong/Kong of the Seat or Round Wind.',
    exampleTiles: [
      ['5z', '5z', '5z'],
    ],
    // Validator requires context or specific check. 
  ),
  Rule(
    name: 'Robbing the Kong (搶槓 - Coeng2 Gong3)',
    description: 'Winning off a Kong.',
    fan: '1 fan',
    explanation: 'Winning when another player declares a Kong with a tile you need.',
    exampleTiles: [],
  ),
  Rule(
    name: 'Haidilao (海底撈月 - Hoi2 Dai2 Laau4 Jyut6)',
    description: 'Winning on the last tile.',
    fan: '1 fan',
    explanation: 'Winning by drawing the very last tile of the wall.',
    exampleTiles: [],
  ),

  // 2 Fan
  Rule(
    name: 'Kong on Kong/Flower (槓上槓/花上自摸 - Gong3 Soeng6 Gong3)',
    description: 'Winning after a Kong or Flower replacement.',
    fan: '2 fan',
    explanation: 'Drawing the winning tile from the dead wall after declaring a Kong or getting a Flower.',
    exampleTiles: [],
  ),
  Rule(
    name: 'Flower Platform (一台花 - Jat1 Toi4 Faa1)',
    description: 'Complete set of Flowers.',
    fan: '2 fan',
    explanation: 'Collecting a full set of numbered Flowers (1-4) or Seasons (1-4).',
    exampleTiles: [
      ['1f', '2f', '3f', '4f'], // Flowers: Plum, Orchid, Chrysanthemum, Bamboo
      ['5f', '6f', '7f', '8f'], // Seasons: Spring, Summer, Autumn, Winter
    ],
  ),

  // 3 Fan
  Rule(
    name: 'Flower Hand (七隻花 - Cat1 Zek3 Faa1)',
    description: 'Seven Flowers.',
    fan: '3 fan',
    explanation: 'Collecting 7 Flower tiles allows for an immediate win.',
    exampleTiles: [
      ['1f', '2f', '3f', '4f', '5f', '6f', '7f'],
    ],
  ),
  Rule(
    name: 'All Pongs (對對胡 - Deoi3 Deoi3 Wu4)',
    description: 'All Pongs.',
    fan: '3 fan',
    explanation: 'Hand composed entirely of Pongs (triplets) or Kongs and a pair.',
    validator: MahjongLogic.isAllPongs,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['2s', '2s', '2s'],
      ['3m', '3m', '3m'],
      ['4p', '4p', '4p'],
      ['5z', '5z'],
    ],
  ),
  Rule(
    name: 'Mixed One Suit (混一色 - Wan6 Jat1 Sik1)',
    description: 'Mixed One Suit.',
    fan: '3 fan',
    explanation: 'Hand composed of one suit and Honor tiles.',
    validator: MahjongLogic.isMixedOneSuit,
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
    name: 'Mixed Terminals (混么九 - Wan6 Jiu1 Gau2)',
    description: 'Mixed Terminals.',
    fan: '4 fan',
    explanation: 'All Pongs/Kongs composed of Terminals (1/9) and Honor tiles.',
    validator: MahjongLogic.isMixedTerminals,
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
    name: 'Small Three Dragons (小三元 - Siu2 Saam1 Jyun4)',
    description: 'Small Three Dragons.',
    fan: '5 fan',
    explanation: 'Two Pongs/Kongs of Dragons and a pair of the third Dragon.',
    validator: MahjongLogic.isSmallThreeDragons,
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
    name: 'Small Four Winds (小四喜 - Siu2 Sei3 Hei2)',
    description: 'Small Four Winds.',
    fan: '6 fan',
    explanation: 'Three Pongs/Kongs of Winds and a pair of the fourth Wind.',
    validator: MahjongLogic.isSmallFourWinds,
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
    name: 'Pure One Suit (清一色 - Cing1 Jat1 Sik1)',
    description: 'Pure One Suit.',
    fan: '7 fan',
    explanation: 'Hand composed entirely of tiles from a single suit.',
    validator: MahjongLogic.isPureHand,
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
    name: 'Big Three Dragons (大三元 - Daai6 Saam1 Jyun4)',
    description: 'Big Three Dragons.',
    fan: '8 fan',
    explanation: 'Three Pongs/Kongs of Red, Green, and White Dragons.',
    validator: MahjongLogic.isBigThreeDragons,
    exampleTiles: [
      ['5z', '5z', '5z'],
      ['6z', '6z', '6z'],
      ['7z', '7z', '7z'],
      ['1p', '2p', '3p'],
      ['9s', '9s'],
    ],
  ),
  Rule(
    name: 'Eight Immortals (八仙過海 - Baat3 Sin1 Gwo3 Hoi2)',
    description: 'Eight Flowers.',
    fan: '8 fan',
    explanation: 'Collecting all 8 Flower tiles allows for an immediate win.',
    exampleTiles: [
      ['1f', '2f', '3f', '4f', '5f', '6f', '7f', '8f'],
    ],
  ),
  Rule(
    name: 'Hidden Treasure (坎坎胡 - Ham2 Ham2 Wu4)',
    description: 'Four Concealed Pongs.',
    fan: '8 fan',
    explanation: 'Four Pongs/Kongs that were all self-drawn (concealed).',
    exampleTiles: [],
    // Validator requires concealed state
  ),

  // 9 Fan
  Rule(
    name: 'Double Kong Replacement (槓上槓 - Gong3 Soeng6 Gong3)',
    description: 'Double Kong Replacement.',
    fan: '9 fan',
    explanation: 'If you call a kong, call a second kong using the replacement tile, then win on the second replacement.',
    exampleTiles: [],
  ),

  // 10 Fan
  Rule(
    name: 'All Honors (字一色 - Zi6 Jat1 Sik1)',
    description: 'All Honors.',
    fan: '10 fan',
    explanation: 'Hand composed entirely of Honor tiles.',
    validator: MahjongLogic.isAllHonors,
    exampleTiles: [
      ['1z', '1z', '1z'],
      ['2z', '2z', '2z'],
      ['3z', '3z', '3z'],
      ['4z', '4z', '4z'],
      ['5z', '5z'],
    ],
  ),
  Rule(
    name: 'Pure Terminals (清么九 - Cing1 Jiu1 Gau2)',
    description: 'Pure Terminals.',
    fan: '10 fan',
    explanation: 'All Pongs/Kongs composed entirely of Terminal tiles (1 and 9).',
    validator: MahjongLogic.isPureTerminals,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['9p', '9p', '9p'],
      ['1s', '1s', '1s'],
      ['9s', '9s', '9s'],
      ['1m', '1m'],
    ],
  ),
  Rule(
    name: 'Nine Gates (九子連環 - Gau2 Zi2 Lin4 Waan4)',
    description: 'Nine Gates.',
    fan: '10 fan',
    explanation: 'Concealed hand of one suit: 1112345678999 + any tile of the same suit.',
    validator: MahjongLogic.isNineGates,
    exampleTiles: [
      ['1p', '1p', '1p'],
      ['2p', '3p', '4p', '5p', '6p', '7p', '8p'],
      ['9p', '9p', '9p'],
      ['5p', '5p'], // Example pair
    ],
  ),

  // 13 Fan
  Rule(
    name: 'Thirteen Orphans (十三么 - Sap6 Saam1 Jiu1)',
    description: 'Thirteen Orphans.',
    fan: '13 fan',
    explanation: 'One of each Terminal and Honor tile + one pair.',
    validator: MahjongLogic.isThirteenOrphans,
    exampleTiles: [
      ['1m', '9m', '1p', '9p', '1s', '9s', '1z', '2z', '3z', '4z', '5z', '6z', '7z', '1m'],
    ],
  ),
  Rule(
    name: 'Blessing of Man (人胡 - Jan4 Wu4)',
    description: 'Blessing of Man.',
    fan: '13 fan',
    explanation: 'As non-dealer, you win on your first turn with a self-pick.',
    exampleTiles: [],
  ),
  Rule(
    name: 'Earthly Hand (地胡 - Dei6 Wu4)',
    description: 'Blessing of Earth.',
    fan: '13 fan',
    explanation: 'As non-dealer, you win using the dealer\'s first discard.',
    exampleTiles: [],
  ),
  Rule(
    name: 'Heavenly Hand (天胡 - Tin1 Wu4)',
    description: 'Blessing of Heaven.',
    fan: '13 fan',
    explanation: 'As dealer, your beginning hand wins.',
    exampleTiles: [],
  ),
  Rule(
    name: 'Big Four Winds (大四喜 - Daai6 Sei3 Hei2)',
    description: 'Big Four Winds.',
    fan: '13 fan',
    explanation: 'Four Pongs/Kongs of East, South, West, and North Winds.',
    validator: MahjongLogic.isBigFourWinds,
    exampleTiles: [
      ['1z', '1z', '1z'],
      ['2z', '2z', '2z'],
      ['3z', '3z', '3z'],
      ['4z', '4z', '4z'],
      ['1p', '1p'],
    ],
  ),
  Rule(
    name: 'Eighteen Arhats (十八羅漢 - Sap6 Baat3 Lo4 Hon3)',
    description: 'Eighteen Arhats.',
    fan: '13 fan',
    explanation: 'Winning with four Kongs (18 tiles total).',
    validator: MahjongLogic.isEighteenArhats,
    exampleTiles: [
      ['1p', '1p', '1p', '1p'],
      ['2s', '2s', '2s', '2s'],
      ['3m', '3m', '3m', '3m'],
      ['4p', '4p', '4p', '4p'],
      ['5z', '5z'],
    ],
  ),
];