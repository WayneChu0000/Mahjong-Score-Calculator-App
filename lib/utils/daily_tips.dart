import '../localization/app_localizations.dart';

/// A single mahjong tip / trivia item.
class MahjongTip {
  final String Function() title;
  final String Function() content;

  const MahjongTip({required this.title, required this.content});
}

/// Returns a different tip each day (cycles through the list).
MahjongTip getTodayTip() {
  final tips = _allTips();
  final dayIndex = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;
  return tips[dayIndex % tips.length];
}

List<MahjongTip> _allTips() => [
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle1,
    content: () => AppLocalizations.tipDayContent1,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle2,
    content: () => AppLocalizations.tipDayContent2,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle3,
    content: () => AppLocalizations.tipDayContent3,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle4,
    content: () => AppLocalizations.tipDayContent4,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle5,
    content: () => AppLocalizations.tipDayContent5,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle6,
    content: () => AppLocalizations.tipDayContent6,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle7,
    content: () => AppLocalizations.tipDayContent7,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle8,
    content: () => AppLocalizations.tipDayContent8,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle9,
    content: () => AppLocalizations.tipDayContent9,
  ),
  MahjongTip(
    title: () => AppLocalizations.tipDayTitle10,
    content: () => AppLocalizations.tipDayContent10,
  ),
];
