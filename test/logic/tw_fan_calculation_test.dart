import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/tw_rules.dart';
import 'package:flutter_application_1/models/rule.dart';
import 'package:flutter_application_1/logic/hand_patterns.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

void main() {
  AppLocalizations.setLocale('English');

  late List<Rule> rules;

  setUp(() {
    rules = twRules;
  });

  // ═══════════════════════════════════════════════════════════
  // Helper: lookup rule by comment keyword in its name
  // ═══════════════════════════════════════════════════════════
  Rule _findRule(String nameSubstring) {
    return rules.firstWhere(
      (r) => r.name.toLowerCase().contains(nameSubstring.toLowerCase()),
      orElse: () => throw StateError('Rule not found: $nameSubstring'),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1️⃣  Structural sanity checks
  // ═══════════════════════════════════════════════════════════
  group('TW rules: structural sanity', () {
    test('total number of TW scoring rules is 87', () {
      expect(rules.length, equals(87));
    });

    test('every rule has fanValue >= 0', () {
      for (final rule in rules) {
        expect(
          rule.fanValue,
          greaterThanOrEqualTo(0),
          reason: '${rule.name} has invalid fanValue ${rule.fanValue}',
        );
      }
    });

    test('every rule has non-empty name', () {
      for (final rule in rules) {
        expect(rule.name, isNotEmpty, reason: 'Found rule with empty name');
      }
    });

    test('every rule has non-empty description', () {
      for (final rule in rules) {
        expect(
          rule.description,
          isNotEmpty,
          reason: '${rule.name} has empty description',
        );
      }
    });

    test('every rule has non-empty explanation', () {
      for (final rule in rules) {
        expect(
          rule.explanation,
          isNotEmpty,
          reason: '${rule.name} has empty explanation',
        );
      }
    });

    test('every rule has non-empty fan display string', () {
      for (final rule in rules) {
        expect(
          rule.fan,
          isNotEmpty,
          reason: '${rule.name} has empty fan display',
        );
      }
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 2️⃣  花牌與字牌相關 (Flowers & Honors) — fan values
  // ═══════════════════════════════════════════════════════════
  group('Category 1: Flowers & Honors fan values', () {
    test('No Flowers (無花) = 1 Tai', () {
      expect(_findRule('No Flowers').fanValue, equals(1));
    });

    test('Proper Flower (正花) = 2 Tai', () {
      expect(_findRule('Proper Flower').fanValue, equals(2));
    });

    test('Wrong Flower (爛花) = 1 Tai', () {
      expect(_findRule('Wrong Flower').fanValue, equals(1));
    });

    test('Proper Wind (正風牌) = 2 Tai', () {
      expect(_findRule('Wind of the Round').fanValue, equals(2));
    });

    test('Ordinary Wind (非正風) = 1 Tai', () {
      expect(_findRule('Ordinary Wind').fanValue, equals(1));
    });

    test('Dragon Pong (中發白) = 2 Tai', () {
      expect(_findRule('Dragon Pong').fanValue, equals(2));
    });

    test('No Honors (無字) = 1 Tai', () {
      expect(_findRule('No Honors').fanValue, equals(1));
    });

    test('No Honors No Flowers (無字花) = 5 Tai', () {
      expect(_findRule('No Honors No Flowers').fanValue, equals(5));
    });

    test('Grand Ping Hu (大平胡) = 15 Tai', () {
      expect(_findRule('Grand Ping').fanValue, equals(15));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 3️⃣  基礎牌型與胡牌方式 — fan values
  // ═══════════════════════════════════════════════════════════
  group('Category 2: Basic Patterns fan values', () {
    test('Ding bonus (叮) = 5 Tai', () {
      expect(_findRule('Ding').fanValue, equals(5));
    });

    test('Chicken Hand (雞胡) = 10 Tai', () {
      expect(_findRule('Chicken Hand').fanValue, equals(10));
    });

    test('Double Pong Wait (對碰) = 2 Tai', () {
      expect(_findRule('Double Pong').fanValue, equals(2));
    });

    test('Fake Single Wait (假獨) = 1 Tai', () {
      expect(_findRule('Fake Single').fanValue, equals(1));
    });

    test('True Single Wait (獨獨) = 2 Tai', () {
      expect(_findRule('True Single').fanValue, equals(2));
    });

    test('Ping Hu / All Chows (平胡) = 3 Tai', () {
      expect(_findRule('All Chows').fanValue, equals(3));
    });

    test('Eye of 2/5/8 (將眼) = 1 Tai', () {
      expect(_findRule('Eye of').fanValue, equals(1));
    });

    test('Old & Young (老少) = 2 Tai', () {
      expect(_findRule('Old').fanValue, equals(2));
    });

    test('Concealed Hand (門清) = 3 Tai', () {
      expect(_findRule('Men Qian Qing').fanValue, equals(3));
    });

    test('Self-Draw (自摸) = 1 Tai', () {
      expect(_findRule('Self-Draw').fanValue, equals(1));
    });

    test('Concealed Self-Draw (門清自摸) = 5 Tai', () {
      expect(_findRule('Concealed Self-Draw').fanValue, equals(5));
    });

    test('Under the Sea (海底撈月) = 20 Tai', () {
      expect(_findRule('Under the Sea').fanValue, equals(20));
    });

    test('Exposed Kong (明槓) = 1 Tai', () {
      expect(_findRule('Exposed Kong').fanValue, equals(1));
    });

    test('Concealed Kong (暗槓) = 2 Tai', () {
      expect(_findRule('Concealed Kong').fanValue, equals(2));
    });

    test('Win on Flower Replacement (花上食胡) = 1 Tai', () {
      expect(_findRule('Flower Replacement').fanValue, equals(1));
    });

    test('Win on Kong Replacement (槓上食胡) = 1 Tai', () {
      expect(_findRule('Kong Replacement').fanValue, equals(1));
    });

    test('Robbing the Kong (搶槓食胡) = 1 Tai', () {
      expect(_findRule('Robbing the Kong').fanValue, equals(1));
    });

    test('Double Kong Win (槓上槓食胡) = 30 Tai', () {
      expect(_findRule('Double Kong Win').fanValue, equals(30));
    });

    test('Robbing Double Kong (搶槓上槓食胡) = 30 Tai', () {
      expect(_findRule('Robbing Double Kong').fanValue, equals(30));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 4️⃣  刻子與順子組合 — fan values
  // ═══════════════════════════════════════════════════════════
  group('Category 3: Pong & Sequence Combo fan values', () {
    test('Two Concealed Pongs (二暗刻) = 3 Tai', () {
      expect(_findRule('Two Concealed Pongs').fanValue, equals(3));
    });

    test('Three Concealed Pongs (三暗刻) = 10 Tai', () {
      expect(_findRule('Three Concealed Pongs').fanValue, equals(10));
    });

    test('Four Concealed Pongs (四暗刻) = 30 Tai', () {
      expect(_findRule('Four Concealed Pongs').fanValue, equals(30));
    });

    test('Five Concealed Pongs (五暗刻) = 80 Tai', () {
      expect(_findRule('Five Concealed Pungs').fanValue, equals(80));
    });

    test('Two Identical Sequences (一般高) = 3 Tai', () {
      expect(_findRule('Two Identical').fanValue, equals(3));
    });

    test('Second Identical Sequences (二般高) = 15 Tai', () {
      expect(_findRule('Second Identical').fanValue, equals(15));
    });

    test('Third Identical Sequences (三般高) = 30 Tai', () {
      expect(_findRule('Third Identical').fanValue, equals(30));
    });

    test('Mixed Double Sequence (二相逢) = 1 Tai', () {
      expect(_findRule('Two Mixed').fanValue, equals(1));
    });

    test('Mixed Triple Sequence (三相逢) = 15 Tai', () {
      expect(_findRule('Three Mixed').fanValue, equals(15));
    });

    test('Five Identical Sequences (五同順) = 45 Tai', () {
      expect(_findRule('Five Identical').fanValue, equals(45));
    });

    test('Two Brothers (二兄弟) = 3 Tai', () {
      expect(_findRule('Two Brothers').fanValue, equals(3));
    });

    test('Small Three Brothers = 10 Tai', () {
      expect(_findRule('Small Three Brothers').fanValue, equals(10));
    });

    test('Big Three Brothers = 15 Tai', () {
      expect(_findRule('Big Three Brothers').fanValue, equals(15));
    });

    test('Small Three Sisters = 8 Tai', () {
      expect(_findRule('Small Three Sisters').fanValue, equals(8));
    });

    test('Big Three Sisters = 15 Tai', () {
      expect(_findRule('Big Three Sisters').fanValue, equals(15));
    });

    test('Four to One (四歸一) = 3 Tai', () {
      expect(_findRule('Four-to-One').fanValue, equals(3));
    });

    test('Four to Two (四歸二) = 10 Tai', () {
      expect(_findRule('Four-to-Two').fanValue, equals(10));
    });

    test('Four to Four (四歸四) = 20 Tai', () {
      expect(_findRule('Four-to-Four').fanValue, equals(20));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 5️⃣  花式牌型與特殊大牌 — fan values
  // ═══════════════════════════════════════════════════════════
  group('Category 4: Special Patterns fan values', () {
    test('Exposed Dragon (明龍) = 10 Tai', () {
      expect(_findRule('Exposed Dragon').fanValue, equals(10));
    });

    test('Concealed Dragon (暗龍) = 20 Tai', () {
      expect(_findRule('Concealed Dragon').fanValue, equals(20));
    });

    test('Exposed Mixed Dragon (明雜龍) = 5 Tai', () {
      expect(_findRule('Exposed Mixed Dragon').fanValue, equals(5));
    });

    test('Concealed Mixed Dragon (暗雜龍) = 10 Tai', () {
      expect(_findRule('Concealed Mixed Dragon').fanValue, equals(10));
    });

    test('Five Gates (五門齊) = 5 Tai', () {
      expect(_findRule('Five Gates').fanValue, equals(5));
    });

    test('Missing One Suit (缺一門) = 3 Tai', () {
      expect(_findRule('Missing One Suit').fanValue, equals(3));
    });

    test('Mixed One Suit / Half Flush (混一色) = 30 Tai', () {
      expect(_findRule('Mixed One Suit').fanValue, equals(30));
    });

    test('Pure One Suit / Full Flush (清一色) = 80 Tai', () {
      expect(_findRule('Pure One Suit').fanValue, equals(80));
    });

    test('All Pongs (對對胡) = 30 Tai', () {
      final rule = rules.firstWhere(
        (r) => r.name == 'All Pongs' || r.name == '對對胡',
        orElse: () => throw StateError('Rule not found: All Pongs'),
      );
      expect(rule.fanValue, equals(30));
    });

    test('All Revealed (全求人) = 15 Tai', () {
      expect(_findRule('All Revealed').fanValue, equals(15));
    });

    test('Half Revealed (半求人) = 8 Tai', () {
      expect(_findRule('Half Revealed').fanValue, equals(8));
    });

    test('Last 7 Tiles (七只內) = 20 Tai', () {
      expect(_findRule('Last 7 Tiles').fanValue, equals(20));
    });

    test('Last 10 Tiles (十只內) = 10 Tai', () {
      expect(_findRule('Last 10 Tiles').fanValue, equals(10));
    });

    test('Small Three Dragons (小三元) = 20 Tai', () {
      expect(_findRule('Small Three Dragons').fanValue, equals(20));
    });

    test('Big Three Dragons (大三元) = 40 Tai', () {
      expect(_findRule('Big Three Dragons').fanValue, equals(40));
    });

    test('Small Three Winds (小三風) = 15 Tai', () {
      expect(_findRule('Small Three Winds').fanValue, equals(15));
    });

    test('Big Three Winds (大三風) = 30 Tai', () {
      expect(_findRule('Big Three Winds').fanValue, equals(30));
    });

    test('Small Four Winds (小四喜) = 60 Tai', () {
      expect(_findRule('Small Four Winds').fanValue, equals(60));
    });

    test('Big Four Winds (大四喜) = 80 Tai', () {
      expect(_findRule('Big Four Winds').fanValue, equals(80));
    });

    test('Thirteen Orphans (十三么) = 80 Tai', () {
      expect(_findRule('Thirteen Orphans').fanValue, equals(80));
    });

    test('Sixteen Non-Matching (十六不搭) = 50 Tai', () {
      expect(_findRule('Sixteen Non').fanValue, equals(50));
    });

    test('Eight Pairs / 嚦咕嚦咕 = 40 Tai', () {
      expect(_findRule('Eight Pairs').fanValue, equals(40));
    });

    test('One Flower Set (一台花) = 10 Tai', () {
      expect(_findRule('One Flower Set').fanValue, equals(10));
    });

    test('Two Flower Sets (兩台花) = 30 Tai', () {
      expect(_findRule('Two Flower Sets').fanValue, equals(30));
    });

    test('All Simples (斷么) = 5 Tai', () {
      expect(_findRule('All Simples').fanValue, equals(5));
    });

    test('Mixed Terminal Chows (全帶混么) = 10 Tai', () {
      expect(_findRule('Mixed Terminal Chows').fanValue, equals(10));
    });

    test('Pure Terminal Chows (全帶么) = 15 Tai', () {
      expect(_findRule('Pure Terminal Chows').fanValue, equals(15));
    });

    test('Mixed Terminals (混么) = 30 Tai', () {
      expect(_findRule('Mixed Terminals').fanValue, equals(30));
    });

    test('Pure Terminals (清么) = 80 Tai', () {
      expect(_findRule('Pure Terminals').fanValue, equals(80));
    });

    test('All Honors (字一色) = 16 Tai', () {
      expect(_findRule('All Honors').fanValue, equals(16));
    });

    test('Nine Gates (九子連環) = 16 Tai', () {
      expect(_findRule('Nine Gates').fanValue, equals(16));
    });

    test('Eighteen Arhats (十八羅漢) = 16 Tai', () {
      expect(_findRule('Eighteen Arhats').fanValue, equals(16));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 6️⃣  特殊胡牌 (Special Win Conditions) — fan values
  // ═══════════════════════════════════════════════════════════
  group('Category 5: Special Win Conditions fan values', () {
    test('Heavenly Hand (天胡) = 100 Tai', () {
      expect(_findRule('Heavenly Hand').fanValue, equals(100));
    });

    test('Earthly Hand (地胡) = 80 Tai', () {
      expect(_findRule('Earthly Hand').fanValue, equals(80));
    });

    test('Human Win (人胡) = 80 Tai', () {
      expect(_findRule('Human Win').fanValue, equals(80));
    });

    test('Seven Rob One (七搶一) = 15 Tai', () {
      expect(_findRule('Seven Rob').fanValue, equals(15));
    });

    test('Heavenly Ready (天聽) = 50 Tai', () {
      expect(_findRule('Heavenly Ready').fanValue, equals(50));
    });

    test('Earthly Ready (地聽) = 25 Tai', () {
      expect(_findRule('Earthly Ready').fanValue, equals(25));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 7️⃣  Validator pattern detection tests
  // ═══════════════════════════════════════════════════════════
  group('Validator: isPingHu (All Chows)', () {
    test('all-chow hand (14 tiles) → true', () {
      // 1m2m3m 4p5p6p 7s8s9s 1m2m3m + 5m5m pair
      final hand = [
        '1m',
        '2m',
        '3m',
        '4p',
        '5p',
        '6p',
        '7s',
        '8s',
        '9s',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isPingHu(hand), isTrue);
    });

    test('hand with pong → false', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '4p',
        '5p',
        '6p',
        '7s',
        '8s',
        '9s',
        '1s',
        '2s',
        '3s',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isPingHu(hand), isFalse);
    });
  });

  group('Validator: isPureHand (Full Flush)', () {
    test('pure bamboo hand → true', () {
      final hand = [
        '1s',
        '2s',
        '3s',
        '4s',
        '5s',
        '6s',
        '7s',
        '8s',
        '9s',
        '1s',
        '2s',
        '3s',
        '7s',
        '7s',
      ];
      expect(HandPatterns.isPureHand(hand), isTrue);
    });

    test('mixed suit hand → false', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '4p',
        '5p',
        '6p',
        '7s',
        '8s',
        '9s',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isPureHand(hand), isFalse);
    });

    test('honors only → false (isPureHand requires numbered suit)', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '4z',
        '5z',
        '5z',
      ];
      expect(HandPatterns.isPureHand(hand), isFalse);
    });
  });

  group('Validator: isMixedOneSuit (Half Flush)', () {
    test('one suit + honors → true', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '4m',
        '5m',
        '6m',
        '1m',
        '2m',
        '3m',
        '1z',
        '1z',
        '1z',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isMixedOneSuit(hand), isTrue);
    });

    test('pure hand (no honors) → false', () {
      final hand = [
        '1s',
        '2s',
        '3s',
        '4s',
        '5s',
        '6s',
        '7s',
        '8s',
        '9s',
        '1s',
        '2s',
        '3s',
        '7s',
        '7s',
      ];
      expect(HandPatterns.isMixedOneSuit(hand), isFalse);
    });

    test('two suits + honors → false', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '4p',
        '5p',
        '6p',
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '5z',
        '5z',
      ];
      expect(HandPatterns.isMixedOneSuit(hand), isFalse);
    });
  });

  group('Validator: isAllPongs', () {
    test('all-pong hand → true', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '5p',
        '5p',
        '5p',
        '9s',
        '9s',
        '9s',
        '3z',
        '3z',
        '3z',
        '7m',
        '7m',
      ];
      expect(HandPatterns.isAllPongs(hand), isTrue);
    });

    test('hand with chow → false', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '5p',
        '5p',
        '5p',
        '9s',
        '9s',
        '9s',
        '3z',
        '3z',
        '3z',
        '7m',
        '7m',
      ];
      expect(HandPatterns.isAllPongs(hand), isFalse);
    });
  });

  group('Validator: isAllSimples', () {
    test('no terminals, no honors → true', () {
      final hand = [
        '2m',
        '3m',
        '4m',
        '5p',
        '6p',
        '7p',
        '3s',
        '4s',
        '5s',
        '6m',
        '7m',
        '8m',
        '5s',
        '5s',
      ];
      expect(HandPatterns.isAllSimples(hand), isTrue);
    });

    test('has terminal 1m → false', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '5p',
        '6p',
        '7p',
        '3s',
        '4s',
        '5s',
        '6m',
        '7m',
        '8m',
        '5s',
        '5s',
      ];
      expect(HandPatterns.isAllSimples(hand), isFalse);
    });

    test('has honor tile → false', () {
      final hand = [
        '2m',
        '3m',
        '4m',
        '5p',
        '6p',
        '7p',
        '3s',
        '4s',
        '5s',
        '1z',
        '1z',
        '1z',
        '5s',
        '5s',
      ];
      expect(HandPatterns.isAllSimples(hand), isFalse);
    });
  });

  group('Validator: isBigThreeDragons', () {
    test('three dragon pongs → true', () {
      // 5z=green, 6z=red, 7z=white
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '7z',
        '1m',
        '2m',
        '3m',
        '5s',
        '5s',
      ];
      expect(HandPatterns.isBigThreeDragons(hand), isTrue);
    });

    test('two dragon pongs + one dragon pair → false (that is Small)', () {
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '1m',
        '1m',
        '1m',
        '2m',
        '3m',
        '4m',
      ];
      expect(HandPatterns.isBigThreeDragons(hand), isFalse);
    });
  });

  group('Validator: isSmallThreeDragons', () {
    test('two dragon pongs + one dragon pair → true', () {
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '1m',
        '1m',
        '1m',
        '2m',
        '3m',
        '4m',
      ];
      expect(HandPatterns.isSmallThreeDragons(hand), isTrue);
    });

    test('three dragon pongs → false (that is Big)', () {
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '7z',
        '1m',
        '2m',
        '3m',
        '5s',
        '5s',
      ];
      expect(HandPatterns.isSmallThreeDragons(hand), isFalse);
    });
  });

  group('Validator: isBigFourWinds', () {
    test('four wind pongs → true', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '4z',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isBigFourWinds(hand), isTrue);
    });

    test('three wind pongs + one wind pair → false', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '1m',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isBigFourWinds(hand), isFalse);
    });
  });

  group('Validator: isSmallFourWinds', () {
    test('three wind pongs + one wind pair → true', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '1m',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isSmallFourWinds(hand), isTrue);
    });

    test('four wind pongs → also true (controller handles exclusion)', () {
      // isSmallFourWinds returns true even for Big Four Winds;
      // the controller is responsible for excluding the lower pattern.
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '4z',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isSmallFourWinds(hand), isTrue);
    });
  });

  group('Validator: isThirteenOrphans', () {
    test('valid thirteen orphans → true', () {
      final hand = [
        '1m',
        '9m',
        '1p',
        '9p',
        '1s',
        '9s',
        '1z',
        '2z',
        '3z',
        '4z',
        '5z',
        '6z',
        '7z',
        '1m',
      ];
      expect(HandPatterns.isThirteenOrphans(hand), isTrue);
    });

    test('missing one orphan → false', () {
      final hand = [
        '1m',
        '9m',
        '1p',
        '9p',
        '1s',
        '9s',
        '1z',
        '2z',
        '3z',
        '4z',
        '5z',
        '6z',
        '2m',
        '2m',
      ];
      expect(HandPatterns.isThirteenOrphans(hand), isFalse);
    });

    test('wrong tile count → false', () {
      final hand = [
        '1m',
        '9m',
        '1p',
        '9p',
        '1s',
        '9s',
        '1z',
        '2z',
        '3z',
        '4z',
        '5z',
        '6z',
        '7z',
      ];
      expect(HandPatterns.isThirteenOrphans(hand), isFalse);
    });
  });

  group('Validator: isPureTerminals', () {
    test('all 1s and 9s → true', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '9m',
        '9m',
        '9m',
        '1p',
        '1p',
        '1p',
        '9s',
        '9s',
        '9s',
        '1s',
        '1s',
      ];
      expect(HandPatterns.isPureTerminals(hand), isTrue);
    });

    test('has honor → false', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '9m',
        '9m',
        '9m',
        '1p',
        '1p',
        '1p',
        '1z',
        '1z',
        '1z',
        '1s',
        '1s',
      ];
      expect(HandPatterns.isPureTerminals(hand), isFalse);
    });

    test('has middle tile → false', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '5m',
        '5m',
        '5m',
        '1p',
        '1p',
        '1p',
        '9s',
        '9s',
        '9s',
        '1s',
        '1s',
      ];
      expect(HandPatterns.isPureTerminals(hand), isFalse);
    });
  });

  group('Validator: isMixedTerminals', () {
    test('terminals + honors, all pongs → true', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '9p',
        '9p',
        '9p',
        '5z',
        '5z',
        '5z',
        '1z',
        '1z',
        '1z',
        '9s',
        '9s',
      ];
      expect(HandPatterns.isMixedTerminals(hand), isTrue);
    });

    test('has middle tile → false', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '5m',
        '5m',
        '5m',
        '5z',
        '5z',
        '5z',
        '1z',
        '1z',
        '1z',
        '9s',
        '9s',
      ];
      expect(HandPatterns.isMixedTerminals(hand), isFalse);
    });

    test('only terminals no honors → false', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '9m',
        '9m',
        '9m',
        '1p',
        '1p',
        '1p',
        '9s',
        '9s',
        '9s',
        '1s',
        '1s',
      ];
      expect(HandPatterns.isMixedTerminals(hand), isFalse);
    });
  });

  group('Validator: isAllHonors', () {
    test('all honor tiles → true', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '5z',
        '5z',
        '5z',
        '7z',
        '7z',
      ];
      expect(HandPatterns.isAllHonors(hand), isTrue);
    });

    test('has numbered tile → false', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '5z',
        '5z',
        '5z',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isAllHonors(hand), isFalse);
    });
  });

  group('Validator: isEightPairs (嚦咕嚦咕)', () {
    test('17 tiles with 8 pairs → true', () {
      final hand = [
        '1m',
        '1m',
        '3m',
        '3m',
        '5p',
        '5p',
        '9p',
        '9p',
        '2s',
        '2s',
        '7s',
        '7s',
        '1z',
        '1z',
        '3z',
        '3z',
        '5z',
      ];
      expect(HandPatterns.isEightPairs(hand), isTrue);
    });

    test('14 tiles → false', () {
      final hand = [
        '1m',
        '1m',
        '3m',
        '3m',
        '5p',
        '5p',
        '9p',
        '9p',
        '2s',
        '2s',
        '7s',
        '7s',
        '1z',
        '1z',
      ];
      expect(HandPatterns.isEightPairs(hand), isFalse);
    });
  });

  group('Validator: isConcealedDragon (暗龍)', () {
    test('has 1-9 of bamboo → true', () {
      final hand = [
        '1s',
        '2s',
        '3s',
        '4s',
        '5s',
        '6s',
        '7s',
        '8s',
        '9s',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isConcealedDragon(hand), isTrue);
    });

    test('missing 5s → false', () {
      final hand = [
        '1s',
        '2s',
        '3s',
        '4s',
        '6s',
        '7s',
        '8s',
        '9s',
        '1s',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isConcealedDragon(hand), isFalse);
    });
  });

  group('Validator: hasEyeOf258', () {
    test('pair of 5m in chow hand → true', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '4p',
        '5p',
        '6p',
        '7s',
        '8s',
        '9s',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.hasEyeOf258(hand), isTrue);
    });

    test('pair of 1m (not 2/5/8) → false', () {
      final hand = [
        '1m',
        '2m',
        '3m',
        '4p',
        '5p',
        '6p',
        '7s',
        '8s',
        '9s',
        '4m',
        '5m',
        '6m',
        '1m',
        '1m',
      ];
      expect(HandPatterns.hasEyeOf258(hand), isFalse);
    });
  });
}
