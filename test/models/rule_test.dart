import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/rule.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

void main() {
  // Ensure English locale
  AppLocalizations.setLocale('English');

  group('Rule model', () {
    test('constructor stores all required fields', () {
      final r = Rule(
        name: 'Test Rule',
        description: 'A test rule',
        fan: '3 Fan',
        fanValue: 3,
        explanation: 'Explanation text',
        exampleTiles: [
          ['1m', '2m', '3m'],
        ],
      );
      expect(r.name, equals('Test Rule'));
      expect(r.description, equals('A test rule'));
      expect(r.fan, equals('3 Fan'));
      expect(r.fanValue, equals(3));
      expect(r.explanation, equals('Explanation text'));
      expect(r.exampleTiles.length, equals(1));
      expect(r.validator, isNull);
      expect(r.imagePath, equals(''));
    });

    test('Rule with validator', () {
      final r = Rule(
        name: 'With Validator',
        description: '-',
        fan: '1',
        fanValue: 1,
        explanation: '-',
        exampleTiles: [],
        validator: (tiles) => tiles.length == 14,
      );
      expect(r.validator, isNotNull);
      expect(r.validator!(['1m', '2m', '3m', '4m', '5m', '6m', '7m',
                            '8m', '9m', '1p', '1p', '1p', '5z', '5z']), isTrue);
      expect(r.validator!(['1m']), isFalse);
    });
  });

  group('getRules', () {
    test('returns HK rules for hongKong mode', () {
      final rules = getRules(GameMode.hongKong);
      expect(rules, isNotEmpty);
      // HK rules should have All Chows
      expect(rules.any((r) => r.name == AppLocalizations.ruleAllChows), isTrue);
    });

    test('returns TW rules for taiwan mode', () {
      final rules = getRules(GameMode.taiwan);
      expect(rules, isNotEmpty);
    });

    test('returns HK rules for null mode', () {
      final rules = getRules(null);
      expect(rules, isNotEmpty);
      // Default is HK
      expect(rules.any((r) => r.name == AppLocalizations.ruleAllChows), isTrue);
    });

    test('legacy rules getter returns HK rules', () {
      expect(rules, isNotEmpty);
      expect(rules.any((r) => r.name == AppLocalizations.ruleAllChows), isTrue);
    });

    test('all HK rules have non-negative fanValue', () {
      final hkRulesList = getRules(GameMode.hongKong);
      for (final r in hkRulesList) {
        expect(r.fanValue, greaterThanOrEqualTo(0),
            reason: '${r.name} has negative fanValue');
      }
    });

    test('all TW rules have non-negative fanValue', () {
      final twRulesList = getRules(GameMode.taiwan);
      for (final r in twRulesList) {
        expect(r.fanValue, greaterThanOrEqualTo(0),
            reason: '${r.name} has negative fanValue');
      }
    });

    test('all rules have non-empty name and description', () {
      final allRules = [...getRules(GameMode.hongKong), ...getRules(GameMode.taiwan)];
      for (final r in allRules) {
        expect(r.name, isNotEmpty, reason: 'Rule has empty name');
        expect(r.description, isNotEmpty, reason: '${r.name} has empty description');
      }
    });
  });
}
