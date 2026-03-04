import 'game_mode.dart';
import 'hk_rules.dart';
import 'tw_rules.dart';

export 'hk_rules.dart';
export 'tw_rules.dart';

class Rule {
  final String name;
  final String description;
  final String fan;

  /// Raw numeric fan/tai value for scoring calculations.
  /// Avoids regex-parsing the display [fan] string at runtime.
  final int fanValue;
  final String imagePath;
  final String explanation;
  final List<List<String>>
  exampleTiles; // Each sublist represents a set of tiles
  final bool Function(List<String>)? validator;

  Rule({
    required this.name,
    required this.description,
    required this.fan,
    required this.fanValue,
    this.imagePath = '',
    required this.explanation,
    required this.exampleTiles,
    this.validator,
  });
}

List<Rule> getRules(GameMode? mode) {
  if (mode == GameMode.taiwan) {
    return twRules;
  }
  return hkRules;
}

// Kept for backward compatibility
List<Rule> get rules => hkRules;
