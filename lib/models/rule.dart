class Rule {
  final String name;
  final String description;
  final String fan;
  final String imagePath;
  final String explanation;
  final List<List<String>> exampleTiles; // 每個子列表代表一組牌

  Rule({
    required this.name,
    required this.description,
    required this.fan,
    this.imagePath = '',
    required this.explanation,
    required this.exampleTiles,
  });
}

// 預定義的香港麻將規則列表
final List<Rule> rules = [
  Rule(
    name: '小四喜',
    description: '有三種風牌的刻子或槓，並有一對第四種風牌',
    fan: '6番',
    imagePath: 'assets/images/small_winds.png',
    explanation: '這裡有東、南、西三組風刻，加上一對北風作將牌，形成小四喜。',
    exampleTiles: [
      ['east', 'east', 'east'], // 東風刻子
      ['south', 'south', 'south'], // 南風刻子
      ['west', 'west', 'west'], // 西風刻子
      ['north', 'north'], // 北風對子
      ['5t', '6t', '7t'], // 5-7筒順子
    ],
  ),
  Rule(
    name: '清一色',
    description: '所有牌皆為同一花色',
    fan: '7番',
    imagePath: 'assets/images/all_one_suit.png',
    explanation: '所有牌都是筒子牌，沒有其他花色或字牌。',
    exampleTiles: [
      ['1t', '2t', '3t'],
      ['3t', '4t', '5t'],
      ['6t', '7t', '8t'],
      ['8t', '8t'],
      ['9t', '9t', '9t'],
    ],
  ),
  Rule(
    name: '七對子',
    description: '由七對相同牌組成',
    fan: '4番',
    imagePath: 'assets/images/seven_pairs.png',
    explanation: '手牌由七個對子組成，沒有刻子或順子。',
    exampleTiles: [
      ['1w', '1w'],
      ['2w', '2w'],
      ['5s', '5s'],
      ['7s', '7s'],
      ['east', 'east'],
      ['fa', 'fa'],
      ['zhong', 'zhong'],
    ],
  ),
  Rule(
    name: '大三元',
    description: '有中、發、白三種箭牌的刻子或槓',
    fan: '8番',
    imagePath: 'assets/images/great_dragons.png',
    explanation: '包含中、發、白三種箭牌的刻子，再加上一組順子和一對將牌。',
    exampleTiles: [
      ['zhong', 'zhong', 'zhong'],
      ['fa', 'fa', 'fa'],
      ['bai', 'bai', 'bai'],
      ['1w', '2w', '3w'],
      ['9t', '9t'],
    ],
  ),
  Rule(
    name: '十三么',
    description: '一、九、風、箭各一張，並有一張相同的牌',
    fan: '13番',
    imagePath: 'assets/images/thirteen_orphans.png',
    explanation: '包含所有邊張和字牌各一張，再加上其中一張相同的牌（這裡是白）作對子。',
    exampleTiles: [
      ['1w', '9w', '1t', '9t', '1s', '9s', 'east', 'south', 'west', 'north', 'zhong', 'fa', 'bai', 'bai'],
    ],
  ),
  Rule(
    name: '碰碰和',
    description: '由四組刻子或槓和一對將牌組成',
    fan: '4番',
    explanation: '全部是刻子（三張相同的牌），沒有順子。',
    exampleTiles: [
      ['2w', '2w', '2w'],
      ['5w', '5w', '5w'],
      ['8t', '8t', '8t'],
      ['fa', 'fa', 'fa'],
      ['south', 'south'],
    ],
  ),
  Rule(
    name: '混一色',
    description: '由一種花色的牌和字牌組成',
    fan: '3番',
    explanation: '除了字牌（東風和紅中）外，其餘都是萬子牌。',
    exampleTiles: [
      ['1w', '2w', '3w'],
      ['4w', '5w', '6w'],
      ['7w', '8w', '9w'],
      ['east', 'east', 'east'],
      ['zhong', 'zhong'],
    ],
  ),
  Rule(
    name: '全求人',
    description: '所有牌組都是靠吃、碰、槓別人的牌而成',
    fan: '2番',
    explanation: '最後一張牌自摸，其他所有牌組都是靠吃碰別人的牌。',
    exampleTiles: [
      ['1w', '2w', '3w'], // 吃
      ['5s', '5s', '5t'], // 碰
      ['7s', '7s', '7t'], // 碰
      ['east', 'east', 'east'], // 碰
      ['south', 'south'], // 自摸
    ],
  ),
  Rule(
    name: '平和',
    description: '四組順子加上雙將作將牌',
    fan: '1番',
    explanation: '全部是順子，將牌不是風或箭牌，且最後一張牌必須是順子的中間牌或將牌。',
    exampleTiles: [
      ['1w', '2w', '3w'],
      ['4w', '5w', '6w'],
      ['2t', '3t', '4t'],
      ['6t', '7t', '8t'],
      ['5s', '5s'],
    ],
  ),
  Rule(
    name: '四暗刻',
    description: '有四組自己摸進的刻子（不能碰）',
    fan: '8番',
    explanation: '所有刻子都是暗刻（自己摸到的，沒有碰牌），最後一張牌是自摸或碰聽。',
    exampleTiles: [
      ['2w', '2w', '2w'],
      ['5w', '5w', '5w'],
      ['8t', '8t', '8t'],
      ['fa', 'fa', 'fa'],
      ['south', 'south'],
    ],
  ),
];