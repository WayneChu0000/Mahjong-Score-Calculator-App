class Rule {
  final String name;
  final String description;
  final String fan;
  final String imagePath;
  final String explanation;
  final List<List<String>> exampleTiles; // Each sublist represents a set of tiles

  Rule({
    required this.name,
    required this.description,
    required this.fan,
    this.imagePath = '',
    required this.explanation,
    required this.exampleTiles,
  });
}

// Predefined Hong Kong Mahjong rules list
final List<Rule> rules = [
  Rule(
    name: 'Small Four Winds',
    description: 'Three pongs/kongs of wind tiles plus a pair of the fourth wind',
    fan: '6 fan',
    imagePath: 'assets/images/small_winds.png',
    explanation: 'Here we have East, South, and West wind pongs, plus a pair of North wind as eyes, forming Small Four Winds.',
    exampleTiles: [
      ['1z', '1z', '1z'], // East wind pong
      ['2z', '2z', '2z'], // South wind pong
      ['3z', '3z', '3z'], // West wind pong
      ['4z', '4z'], // North wind pair
      ['5p', '6p', '7p'], // 5-7 circle chow
    ],
  ),
  Rule(
    name: 'Pure Hand',
    description: 'All tiles are of the same suit',
    fan: '7 fan',
    imagePath: 'assets/images/all_one_suit.png',
    explanation: 'All tiles are circle tiles, with no other suits or honor tiles.',
    exampleTiles: [
      ['1p', '2p', '3p'],
      ['3p', '4p', '5p'],
      ['6p', '7p', '8p'],
      ['8p', '8p'],
      ['9p', '9p', '9p'],
    ],
  ),
  Rule(
    name: 'Seven Pairs',
    description: 'Composed of seven pairs of identical tiles',
    fan: '4 fan',
    imagePath: 'assets/images/seven_pairs.png',
    explanation: 'Hand is made up of seven pairs, with no pongs or chows.',
    exampleTiles: [
      ['1m', '1m'],
      ['2m', '2m'],
      ['5s', '5s'],
      ['7s', '7s'],
      ['1z', '1z'], // East wind
      ['6z', '6z'], // Green dragon
      ['7z', '7z'], // Red dragon
    ],
  ),
  Rule(
    name: 'Big Three Dragons',
    description: 'Three pongs/kongs of dragon tiles (Red, Green, White)',
    fan: '8 fan',
    imagePath: 'assets/images/great_dragons.png',
    explanation: 'Contains pongs of Red, Green, and White dragons, plus a chow and a pair of eyes.',
    exampleTiles: [
      ['7z', '7z', '7z'], // Red dragon
      ['6z', '6z', '6z'], // Green dragon
      ['5z', '5z', '5z'], // White dragon
      ['1m', '2m', '3m'],
      ['9p', '9p'],
    ],
  ),
  Rule(
    name: 'Thirteen Orphans',
    description: 'One of each terminal and honor tile, plus one duplicate',
    fan: '13 fan',
    imagePath: 'assets/images/thirteen_orphans.png',
    explanation: 'Contains one of each terminal and honor tile, plus one duplicate (here White dragon) as a pair.',
    exampleTiles: [
      ['1m', '9m', '1p', '9p', '1s', '9s', '1z', '2z', '3z', '4z', '5z', '6z', '7z', '5z'], // White dragon pair
    ],
  ),
  Rule(
    name: 'All Pongs',
    description: 'Four pongs/kongs plus a pair of eyes',
    fan: '4 fan',
    explanation: 'All sets are pongs (three identical tiles), with no chows.',
    exampleTiles: [
      ['2m', '2m', '2m'],
      ['5m', '5m', '5m'],
      ['8p', '8p', '8p'],
      ['6z', '6z', '6z'], // Green dragon
      ['2z', '2z'], // South wind
    ],
  ),
  Rule(
    name: 'Half Flush',
    description: 'Composed of tiles from one suit plus honor tiles',
    fan: '3 fan',
    explanation: 'Except for honor tiles (East wind and Red dragon), all other tiles are character tiles.',
    exampleTiles: [
      ['1m', '2m', '3m'],
      ['4m', '5m', '6m'],
      ['7m', '8m', '9m'],
      ['1z', '1z', '1z'], // East wind
      ['7z', '7z'], // Red dragon
    ],
  ),
  Rule(
    name: 'Fully Concealed Hand',
    description: 'All sets are formed by chow, pong, or kong from others\' discards',
    fan: '2 fan',
    explanation: 'Last tile is self-drawn, all other sets are formed by chow/pong from others.',
    exampleTiles: [
      ['1m', '2m', '3m'], // Chow
      ['5s', '5s', '5s'], // Pong
      ['7s', '7s', '7s'], // Pong
      ['1z', '1z', '1z'], // East wind pong
      ['2z', '2z'], // South wind self-draw
    ],
  ),
  Rule(
    name: 'All Chows',
    description: 'Four chows plus a pair of eyes',
    fan: '1 fan',
    explanation: 'All sets are chows, eyes are not wind or dragon tiles, and the last tile must be the middle tile of a chow or the eyes.',
    exampleTiles: [
      ['1m', '2m', '3m'],
      ['4m', '5m', '6m'],
      ['2p', '3p', '4p'],
      ['6p', '7p', '8p'],
      ['5s', '5s'],
    ],
  ),
  Rule(
    name: 'Four Concealed Pongs',
    description: 'Four pongs that are self-drawn (cannot be from others\' discards)',
    fan: '8 fan',
    explanation: 'All pongs are concealed (self-drawn, not from others\' discards), last tile is self-drawn or waiting for a pong.',
    exampleTiles: [
      ['2m', '2m', '2m'],
      ['5m', '5m', '5m'],
      ['8p', '8p', '8p'],
      ['6z', '6z', '6z'], // Green dragon
      ['2z', '2z'], // South wind
    ],
  ),
];