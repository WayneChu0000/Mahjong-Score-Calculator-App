import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../models/rule.dart';
import '../models/game_mode.dart';
import '../models/tw_rules.dart';
import '../widgets/tile_group.dart';
import '../localization/app_localizations.dart';
import 'tutorial_content.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFan = 'All';
  String _searchQuery = '';
  List<Rule> _filteredRules = [];
  late TabController _tabController;
  late TextEditingController _searchController;
  GameMode _selectedMode = GameMode.hongKong;

  @override
  void initState() {
    super.initState();
    // filteredRules will be updated in didChangeDependencies
    _filteredRules = [];
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we need to update selection due to language change
    String currentFanStr = _selectedFan.split(' ')[0];
    int currentFan = int.tryParse(currentFanStr) ?? 0;

    String newCorrectSelection;
    if (currentFan == 0) {
      newCorrectSelection = AppLocalizations.allFan;
    } else {
      newCorrectSelection = AppLocalizations.fan(currentFan);
    }

    // Update if changed (e.g. language switch) or if it's the initial load
    if (_selectedFan != newCorrectSelection || _filteredRules.isEmpty) {
      _selectedFan = newCorrectSelection;
      _filterRules();
    } else {
      // Even if selection didn't change string (unlikely across langs),
      // rules content might need refresh for translation
      _filterRules();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterRules() {
    setState(() {
      List<Rule> tempRules = getRules(_selectedMode);

      // Filter by fan
      if (_selectedFan != AppLocalizations.allFan) {
        // Extract number from "X fan" string in rule.fan
        // rule.fan format is "X fan" or "X 番"
        // _selectedFan format is "X Fan" or "X Fans" or "X 番"
        String targetFanStr = _selectedFan.split(' ')[0];
        int targetFan = int.tryParse(targetFanStr) ?? 0;

        tempRules = tempRules.where((rule) {
          String ruleFanStr = rule.fan.split(' ')[0];
          int ruleFan = int.tryParse(ruleFanStr) ?? 0;
          return ruleFan == targetFan;
        }).toList();
      }

      // Filter by search query
      if (_searchQuery.isEmpty) {
        _filteredRules = tempRules;
      } else {
        _filteredRules = tempRules
            .where(
              (rule) =>
                  rule.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  rule.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    final body = Column(
      children: [
        // Top tabs
        Material(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.green.shade50,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.green.shade300
                : Colors.green.shade800,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(
                icon: const Icon(Icons.menu_book),
                text: AppLocalizations.rulesReference,
              ),
              Tab(
                icon: const Icon(Icons.school),
                text: AppLocalizations.mahjongTutorial,
              ),
            ],
          ),
        ),

        // HK / TW mode toggle
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.center,
          child: SegmentedButton<GameMode>(
            segments: [
              ButtonSegment(
                value: GameMode.hongKong,
                label: Text(AppLocalizations.hkMode),
                icon: const Icon(Icons.casino),
              ),
              ButtonSegment(
                value: GameMode.taiwan,
                label: Text(AppLocalizations.twMode),
                icon: const Icon(Icons.grid_view),
              ),
            ],
            selected: {_selectedMode},
            onSelectionChanged: (Set<GameMode> selection) {
              setState(() {
                _selectedMode = selection.first;
                _filterRules();
              });
            },
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Rules reference page
              _buildRulesReferenceTab(),

              // Mahjong tutorial page
              TutorialTab(onRuleTap: _navigateToRule, gameMode: _selectedMode),
            ],
          ),
        ),
      ],
    );

    // When pushed from another screen (e.g. score recording),
    // show AppBar with back button instead of bottom navigation bar.
    if (canPop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.rulesAndTutorial),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
        ),
        body: body,
      );
    }

    return BaseScreen(
      title: AppLocalizations.rulesAndTutorial,
      currentIndex: 1,
      body: body,
    );
  }

  // Rules reference tab content
  Widget _buildRulesReferenceTab() {
    // Generate fan/tai filter options from actual rule set
    final currentRules = getRules(_selectedMode);
    final fanValues = currentRules.map((r) => r.fanValue).toSet().toList()
      ..sort();
    final List<String> fanOptions = [AppLocalizations.allFan];
    for (final v in fanValues) {
      if (_selectedMode == GameMode.taiwan) {
        fanOptions.add(AppLocalizations.taiCount(v));
      } else {
        fanOptions.add(AppLocalizations.fan(v));
      }
    }

    // Ensure selected fan is valid
    if (!fanOptions.contains(_selectedFan)) {
      _selectedFan = fanOptions[0];
      // We should ideally re-filter, but for now let's just sync the dropdown
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        // Search area
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedFan,
                      items: fanOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFan = value;
                            _filterRules();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.searchRules,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _filterRules();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Rule cards list
        ..._filteredRules.map(
          (rule) => RuleCard(rule: rule, mode: _selectedMode),
        ),

        // TW-specific informational sections
        if (_selectedMode == GameMode.taiwan) ..._buildTwInfoSections(isDark),

        // Bottom space for good scrolling experience
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildTwInfoSections(bool isDark) {
    return [
      const SizedBox(height: 24),
      _buildInfoSection(
        title: AppLocalizations.twInstantPayTitle,
        subtitle: AppLocalizations.twInstantPayDesc,
        rules: twInstantPayRules,
        icon: Icons.payments,
        isDark: isDark,
      ),
      _buildInfoSection(
        title: AppLocalizations.twPenaltiesTitle,
        subtitle: AppLocalizations.twPenaltiesDesc,
        rules: twPenaltyRules,
        icon: Icons.gavel,
        isDark: isDark,
      ),
      _buildInfoSection(
        title: AppLocalizations.twDealerBonusTitle,
        subtitle: AppLocalizations.twDealerBonusDesc,
        rules: twDealerBonusRules,
        icon: Icons.star,
        isDark: isDark,
      ),
      _buildInfoSection(
        title: AppLocalizations.twLaSettlementTitle,
        subtitle: AppLocalizations.twLaSettlementDesc,
        rules: twLaSettlementRules,
        icon: Icons.sync,
        isDark: isDark,
      ),
      const SizedBox(height: 8),
      Card(
        color: isDark
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.twNoStackRule,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.orange.shade200
                        : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildInfoSection({
    required String title,
    required String subtitle,
    required List<Rule> rules,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(icon, color: Colors.green, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        ...rules.map((rule) => _buildInfoCard(rule, isDark)),
      ],
    );
  }

  Widget _buildInfoCard(Rule rule, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          Icons.info_outline,
          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
        ),
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          rule.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(rule.explanation, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _navigateToRule(String ruleName) {
    setState(() {
      _searchQuery = ruleName;
      _searchController.text = ruleName;
      _selectedFan =
          AppLocalizations.allFan; // Reset fan filter to ensure rule is found
      _filterRules();
    });
    _tabController.animateTo(0); // Switch to Rules Reference tab
  }

  // Tutorial tab content
  // Removed _buildTutorialTab as we now use TutorialTab widget
}

class TutorialTab extends StatefulWidget {
  final Function(String) onRuleTap;
  final GameMode gameMode;

  const TutorialTab({
    super.key,
    required this.onRuleTap,
    required this.gameMode,
  });

  @override
  State<TutorialTab> createState() => _TutorialTabState();
}

class _TutorialTabState extends State<TutorialTab>
    with AutomaticKeepAliveClientMixin {
  late PageController _tutorialPageController;
  int _currentTutorialPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tutorialPageController = PageController();
  }

  @override
  void dispose() {
    _tutorialPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tutorialTitles = [
      AppLocalizations.tutorialWelcome,
      AppLocalizations.tutorialTiles,
      AppLocalizations.tutorialRules,
      AppLocalizations.tutorialScore,
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Top navigation bar for tutorial pages
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTutorialPage = index;
                    });
                    _tutorialPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _currentTutorialPage == index
                          ? Colors.green.shade600
                          : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          [
                            Icons.waving_hand,
                            Icons.dashboard,
                            Icons.rule,
                            Icons.calculate,
                          ][index],
                          color: _currentTutorialPage == index
                              ? Colors.white
                              : (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tutorialTitles[index],
                          style: TextStyle(
                            color: _currentTutorialPage == index
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Tutorial content pages
        Expanded(
          child: PageView(
            controller: _tutorialPageController,
            onPageChanged: (index) {
              setState(() {
                _currentTutorialPage = index;
              });
            },
            children: [
              TutorialContent(
                pageIndex: 0,
                onRuleTap: widget.onRuleTap,
                gameMode: widget.gameMode,
              ),
              TutorialContent(
                pageIndex: 1,
                onRuleTap: widget.onRuleTap,
                gameMode: widget.gameMode,
              ),
              TutorialContent(
                pageIndex: 2,
                onRuleTap: widget.onRuleTap,
                gameMode: widget.gameMode,
              ),
              TutorialContent(
                pageIndex: 3,
                onRuleTap: widget.onRuleTap,
                gameMode: widget.gameMode,
              ),
            ],
          ),
        ),

        // Bottom pagination controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentTutorialPage > 0
                    ? () {
                        _tutorialPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.previous),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
              ),

              Text(
                '${_currentTutorialPage + 1} / 4',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ElevatedButton.icon(
                onPressed: _currentTutorialPage < 3
                    ? () {
                        _tutorialPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(AppLocalizations.next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget to display fan count in a red circle
class FanWidget extends StatelessWidget {
  final String fan;

  const FanWidget({super.key, required this.fan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        fan,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

// RuleCard class
class RuleCard extends StatefulWidget {
  final Rule rule;
  final GameMode mode;

  const RuleCard({
    super.key,
    required this.rule,
    required this.mode,
  });

  @override
  State<RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<RuleCard> {
  bool _showExample = false;

  bool _shouldHideTwImageExample() {
    final name = widget.rule.name;
    return name == AppLocalizations.twNoHonorsNoFlowersPingHu ||
        name == AppLocalizations.twDingBonus ||
        name == AppLocalizations.twDoublePong ||
        name == AppLocalizations.twFakeSingle ||
        name == AppLocalizations.twTrueSingle ||
        name == AppLocalizations.ruleSelfDraw ||
        name == AppLocalizations.ruleMenQianQing ||
        name == AppLocalizations.twConcealedSelfDraw ||
        name == AppLocalizations.twUnderTheSea ||
        name == AppLocalizations.twExposedKong ||
        name == AppLocalizations.twConcealedKongTai ||
        name == AppLocalizations.twFlowerWin ||
        name == AppLocalizations.twKongWin ||
        name == AppLocalizations.twRobbingKong ||
        name == AppLocalizations.twDoubleKongWin ||
        name == AppLocalizations.twRobbingDoubleKong ||
        name == AppLocalizations.ruleHeavenlyHand ||
        name == AppLocalizations.ruleEarthlyHand ||
        name == AppLocalizations.twHumanWin ||
        name == AppLocalizations.twSevenRobOne ||
        name == AppLocalizations.twHeavenlyReady ||
        name == AppLocalizations.twEarthlyReady;
  }

  List<String> _resolveExampleGroupTags() {
    final name = widget.rule.name;

    List<String> allConcealed(int meldCount) {
      return [
        for (int i = 0; i < meldCount; i++) AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    List<String> allExposed(int meldCount) {
      return [
        for (int i = 0; i < meldCount; i++) AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twTwoConcealedPongs) {
      return [
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twThreeConcealedPongs) {
      return [
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twFourConcealedPongs) {
      return [
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twFiveConcealedPongs ||
        name == AppLocalizations.twJianJianHu) {
      return allConcealed(5);
    }

    if (name == AppLocalizations.twExposedDragon ||
        name == AppLocalizations.twExposedMixedDragon ||
        name == AppLocalizations.twAllRevealed) {
      return allExposed(5);
    }

    if (name == AppLocalizations.twConcealedDragon ||
        name == AppLocalizations.twConcealedMixedDragon) {
      return allConcealed(5);
    }

    if (name == AppLocalizations.twHalfRevealed) {
      return [
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twIdenticalSequenceThree ||
        name == AppLocalizations.twMixedTripleSeq) {
      return allConcealed(5);
    }

    if (name == AppLocalizations.twIdenticalSequenceFour ||
        name == AppLocalizations.twFiveIdenticalSeq) {
      return allConcealed(5);
    }

    if (name == AppLocalizations.twFourToOne) {
      return [
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twFourToTwo) {
      return [
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    if (name == AppLocalizations.twFourToFour) {
      return [
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagConcealed,
        AppLocalizations.exampleTagExposed,
        AppLocalizations.exampleTagEyes,
      ];
    }

    return const [];
  }

  List<List<String>> _resolveTwExampleTilesByRule() {
    final name = widget.rule.name;

    if (_shouldHideTwImageExample()) return const [];

    if (name == AppLocalizations.ruleNoFlowers) return const [];
    if (name == AppLocalizations.twProperFlower) return const [
      ['1f'],
      ['5f'],
    ];
    if (name == AppLocalizations.twWrongFlower) return const [
      ['2f'],
      ['6f'],
    ];
    if (name == AppLocalizations.twProperWind) return const [
      ['1z', '1z', '1z'],
    ];
    if (name == AppLocalizations.twOrdinaryWind) return const [
      ['2z', '2z', '2z'],
    ];
    if (name == AppLocalizations.twDragonPong) return const [
      ['5z', '5z', '5z'],
      ['6z', '6z', '6z'],
      ['7z', '7z', '7z'],
    ];
    if (name == AppLocalizations.twNoHonors ||
        name == AppLocalizations.twNoHonorsNoFlowers ||
        name == AppLocalizations.twNoHonorsNoFlowersPingHu) {
      return const [
        ['2m', '3m', '4m'],
        ['4p', '5p', '6p'],
        ['6s', '7s', '8s'],
        ['3m', '4m', '5m'],
        ['2p', '3p', '4p'],
        ['8p', '8p'],
      ];
    }

    if (name == AppLocalizations.ruleAllChows) {
      return const [
        ['1m', '2m', '3m'],
        ['3p', '4p', '5p'],
        ['4s', '5s', '6s'],
        ['7m', '8m', '9m'],
        ['5m', '6m', '7m'],
        ['2p', '2p'],
      ];
    }
    if (name == AppLocalizations.twEyeOf258) {
      return const [
        ['2m', '2m'],
        ['3p', '4p', '5p'],
        ['5s', '6s', '7s'],
        ['7m', '8m', '9m'],
        ['3z', '3z', '3z'],
        ['4m', '5m', '6m'],
      ];
    }
    if (name == AppLocalizations.twChickenHand) {
      return const [
        ['2m', '3m', '4m'],
        ['5p', '6p', '7p'],
        ['7s', '8s', '9s'],
        ['3z', '3z', '3z'],
        ['2p', '2p', '2p'],
        ['6m', '6m'],
      ];
    }

    if (name == AppLocalizations.twTwoConcealedPongs) {
      return const [
        ['1m', '1m', '1m'],
        ['3p', '3p', '3p'],
        ['2s', '3s', '4s'],
        ['6m', '7m', '8m'],
        ['5z', '5z', '5z'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twThreeConcealedPongs) {
      return const [
        ['1m', '1m', '1m'],
        ['3p', '3p', '3p'],
        ['5s', '5s', '5s'],
        ['6m', '7m', '8m'],
        ['5z', '5z', '5z'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twFourConcealedPongs) {
      return const [
        ['1m', '1m', '1m'],
        ['3p', '3p', '3p'],
        ['5s', '5s', '5s'],
        ['7z', '7z', '7z'],
        ['6m', '7m', '8m'],
        ['9m', '9m'],
      ];
    }
    if (name == AppLocalizations.twFiveConcealedPongs ||
        name == AppLocalizations.twJianJianHu) {
      return const [
        ['1m', '1m', '1m'],
        ['3p', '3p', '3p'],
        ['5s', '5s', '5s'],
        ['7z', '7z', '7z'],
        ['9p', '9p', '9p'],
        ['2m', '2m'],
      ];
    }

    if (name == AppLocalizations.twIdenticalSequenceTwo) {
      return const [
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['6p', '7p', '8p'],
        ['3s', '4s', '5s'],
        ['9m', '9m', '9m'],
        ['5p', '5p'],
      ];
    }
    if (name == AppLocalizations.twIdenticalSequenceThree) {
      return const [
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['6p', '7p', '8p'],
        ['9m', '9m', '9m'],
        ['5p', '5p'],
      ];
    }
    if (name == AppLocalizations.twIdenticalSequenceFour) {
      return const [
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['9m', '9m', '9m'],
        ['5p', '5p'],
      ];
    }
    if (name == AppLocalizations.twFiveIdenticalSeq) {
      return const [
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['5p', '5p'],
      ];
    }

    if (name == AppLocalizations.twMixedDoubleSeq) {
      return const [
        ['3m', '4m', '5m'],
        ['3p', '4p', '5p'],
        ['2s', '3s', '4s'],
        ['6m', '7m', '8m'],
        ['9p', '9p', '9p'],
        ['5s', '5s'],
      ];
    }
    if (name == AppLocalizations.twMixedTripleSeq) {
      return const [
        ['3m', '4m', '5m'],
        ['3p', '4p', '5p'],
        ['3s', '4s', '5s'],
        ['6m', '7m', '8m'],
        ['9p', '9p', '9p'],
        ['5s', '5s'],
      ];
    }

    if (name == AppLocalizations.twTwoBrothers) {
      return const [
        ['4m', '4m', '4m'],
        ['5m', '5m', '5m'],
        ['2p', '3p', '4p'],
        ['6s', '7s', '8s'],
        ['1z', '1z', '1z'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twSmallThreeBrothers) {
      return const [
        ['4m', '4m', '4m'],
        ['5m', '5m', '5m'],
        ['6m', '6m', '6m'],
        ['2p', '3p', '4p'],
        ['1z', '1z', '1z'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twBigThreeBrothers) {
      return const [
        ['4m', '4m', '4m'],
        ['5m', '5m', '5m'],
        ['6m', '6m', '6m'],
        ['7m', '7m', '7m'],
        ['1z', '1z', '1z'],
        ['9p', '9p'],
      ];
    }

    if (name == AppLocalizations.twSmallThreeSisters) {
      return const [
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['7s', '8s', '9s'],
        ['1z', '1z', '1z'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twBigThreeSisters) {
      return const [
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['2m', '3m', '4m'],
        ['1z', '1z', '1z'],
        ['9p', '9p'],
      ];
    }

    if (name == AppLocalizations.twFourToOne) {
      return const [
        ['8p', '8p', '8p', '8p'],
        ['2m', '3m', '4m'],
        ['5s', '6s', '7s'],
        ['1z', '1z', '1z'],
        ['6m', '7m', '8m'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twFourToTwo) {
      return const [
        ['8p', '8p', '8p', '8p'],
        ['2m', '2m', '2m', '2m'],
        ['3s', '4s', '5s'],
        ['1z', '1z', '1z'],
        ['6m', '7m', '8m'],
        ['9p', '9p'],
      ];
    }
    if (name == AppLocalizations.twFourToFour) {
      return const [
        ['8p', '8p', '8p', '8p'],
        ['2m', '2m', '2m', '2m'],
        ['6s', '6s', '6s', '6s'],
        ['1z', '1z', '1z', '1z'],
        ['3p', '4p', '5p'],
        ['9m', '9m'],
      ];
    }

    if (name == AppLocalizations.twExposedDragon) {
      return const [
        ['1m', '2m', '3m'],
        ['4m', '5m', '6m'],
        ['7m', '8m', '9m'],
        ['3p', '3p', '3p'],
        ['5z', '5z', '5z'],
        ['7s', '7s'],
      ];
    }
    if (name == AppLocalizations.twConcealedDragon) {
      return const [
        ['1m', '2m', '3m'],
        ['4m', '5m', '6m'],
        ['7m', '8m', '9m'],
        ['3p', '3p', '3p'],
        ['5z', '5z', '5z'],
        ['7s', '7s'],
      ];
    }
    if (name == AppLocalizations.twExposedMixedDragon ||
        name == AppLocalizations.twConcealedMixedDragon) {
      return const [
        ['1m', '2m', '3m'],
        ['4p', '5p', '6p'],
        ['7s', '8s', '9s'],
        ['3p', '3p', '3p'],
        ['5z', '5z', '5z'],
        ['7s', '7s'],
      ];
    }
    if (name == AppLocalizations.twFiveGates) {
      return const [
        ['2m', '3m', '4m'],
        ['5p', '6p', '7p'],
        ['6s', '7s', '8s'],
        ['1z', '1z', '1z'],
        ['5z', '5z'],
      ];
    }
    if (name == AppLocalizations.twMissingOneSuit) {
      return const [
        ['1m', '2m', '3m'],
        ['4m', '4m', '4m'],
        ['2p', '3p', '4p'],
        ['7p', '8p', '9p'],
        ['1z', '1z', '1z'],
        ['5z', '5z'],
      ];
    }
    if (name == AppLocalizations.ruleMixedOneSuit) {
      return const [
        ['1m', '2m', '3m'],
        ['4m', '5m', '6m'],
        ['7m', '8m', '9m'],
        ['1z', '1z', '1z'],
        ['2z', '2z', '2z'],
        ['5z', '5z'],
      ];
    }
    if (name == AppLocalizations.rulePureOneSuit) {
      return const [
        ['1m', '2m', '3m'],
        ['4m', '5m', '6m'],
        ['7m', '8m', '9m'],
        ['2m', '2m', '2m'],
        ['8m', '8m', '8m'],
        ['5m', '5m'],
      ];
    }
    if (name == AppLocalizations.ruleAllPongs) {
      return const [
        ['2m', '2m', '2m'],
        ['4p', '4p', '4p'],
        ['6s', '6s', '6s'],
        ['1z', '1z', '1z'],
        ['9m', '9m', '9m'],
        ['7p', '7p'],
      ];
    }
    if (name == AppLocalizations.twAllRevealed ||
        name == AppLocalizations.twHalfRevealed) {
      return const [
        ['2m', '2m', '2m'],
        ['4p', '4p', '4p'],
        ['6s', '6s', '6s'],
        ['1z', '1z', '1z'],
        ['9m', '9m', '9m'],
        ['7p', '7p'],
      ];
    }
    if (name == AppLocalizations.twLastSevenTiles ||
        name == AppLocalizations.twLastTenTiles) {
      return const [
        ['3m', '4m', '5m'],
        ['6p', '7p', '8p'],
        ['4s', '5s', '6s'],
        ['2z', '2z', '2z'],
        ['7p', '7p', '7p'],
        ['7m', '7m'],
      ];
    }
    if (name == AppLocalizations.ruleSmallThreeDragons) {
      return const [
        ['5z', '5z', '5z'],
        ['6z', '6z', '6z'],
        ['7z', '7z'],
        ['2m', '3m', '4m'],
        ['6p', '7p', '8p'],
        ['9s', '9s', '9s'],
      ];
    }
    if (name == AppLocalizations.ruleBigThreeDragons) {
      return const [
        ['5z', '5z', '5z'],
        ['6z', '6z', '6z'],
        ['7z', '7z', '7z'],
        ['2m', '3m', '4m'],
        ['9s', '9s', '9s'],
        ['8p', '8p'],
      ];
    }
    if (name == AppLocalizations.twSmallThreeWinds) {
      return const [
        ['1z', '1z', '1z'],
        ['2z', '2z', '2z'],
        ['3z', '3z', '3z'],
        ['4z', '4z'],
        ['6p', '7p', '8p'],
        ['9s', '9s', '9s'],
      ];
    }
    if (name == AppLocalizations.twBigThreeWinds) {
      return const [
        ['1z', '1z', '1z'],
        ['2z', '2z', '2z'],
        ['3z', '3z', '3z'],
        ['5z', '5z', '5z'],
        ['6p', '7p', '8p'],
        ['9s', '9s'],
      ];
    }
    if (name == AppLocalizations.ruleSmallFourWinds) {
      return const [
        ['1z', '1z', '1z'],
        ['2z', '2z', '2z'],
        ['3z', '3z', '3z'],
        ['4z', '4z'],
        ['6p', '7p', '8p'],
        ['9s', '9s', '9s'],
      ];
    }
    if (name == AppLocalizations.ruleBigFourWinds) {
      return const [
        ['1z', '1z', '1z'],
        ['2z', '2z', '2z'],
        ['3z', '3z', '3z'],
        ['4z', '4z', '4z'],
        ['9s', '9s', '9s'],
        ['5z', '5z'],
      ];
    }
    if (name == AppLocalizations.ruleThirteenOrphans) {
      return const [
        ['1m'],
        ['9m'],
        ['1p'],
        ['9p'],
        ['1s'],
        ['9s'],
        ['1z'],
        ['2z'],
        ['3z'],
        ['4z'],
        ['5z'],
        ['6z'],
        ['7z'],
        ['1m'],
      ];
    }
    if (name == AppLocalizations.twSixteenNonMatching) {
      return const [
        ['1m'],
        ['4m'],
        ['7m'],
        ['2p'],
        ['5p'],
        ['8p'],
        ['3s'],
        ['6s'],
        ['9s'],
        ['1z'],
        ['2z'],
        ['3z'],
        ['4z'],
        ['5z'],
        ['6z'],
        ['7z'],
      ];
    }
    if (name == AppLocalizations.twMiguiTw) {
      return const [
        ['1m', '1m'],
        ['2m', '2m'],
        ['3p', '3p'],
        ['4p', '4p'],
        ['5s', '5s'],
        ['6s', '6s'],
        ['1z', '1z'],
        ['5z', '5z'],
      ];
    }
    if (name == AppLocalizations.twOneFlowerSet) {
      return const [
        ['1f', '2f', '3f', '4f'],
      ];
    }
    if (name == AppLocalizations.twTwoFlowerSets) {
      return const [
        ['1f', '2f', '3f', '4f'],
        ['5f', '6f', '7f', '8f'],
      ];
    }
    if (name == AppLocalizations.twAllSimples) {
      return const [
        ['2m', '3m', '4m'],
        ['3p', '4p', '5p'],
        ['4s', '5s', '6s'],
        ['6m', '7m', '8m'],
        ['6p', '7p', '8p'],
        ['5p', '5p'],
      ];
    }
    if (name == AppLocalizations.twMixedTerminalChows ||
        name == AppLocalizations.twPureTerminalChows ||
        name == AppLocalizations.twQuanHunYao ||
        name == AppLocalizations.twBanDaiHunYao ||
        name == AppLocalizations.twMixedTerminalsPongs ||
        name == AppLocalizations.twPureTerminalsTw) {
      return const [
        ['1m', '2m', '3m'],
        ['7p', '8p', '9p'],
        ['1s', '1s', '1s'],
        ['9m', '9m', '9m'],
        ['9s', '9s', '9s'],
        ['1z', '1z'],
      ];
    }
    if (name == AppLocalizations.ruleAllHonors) {
      return const [
        ['1z', '1z', '1z'],
        ['2z', '2z', '2z'],
        ['5z', '5z', '5z'],
        ['6z', '6z', '6z'],
        ['7z', '7z'],
      ];
    }
    if (name == AppLocalizations.ruleNineGates) {
      return const [
        ['1m', '1m', '1m'],
        ['2m'],
        ['3m'],
        ['4m'],
        ['5m'],
        ['6m'],
        ['7m'],
        ['8m'],
        ['9m', '9m', '9m'],
        ['5m'],
      ];
    }
    if (name == AppLocalizations.ruleEighteenArhats) {
      return const [
        ['2m', '2m', '2m', '2m'],
        ['5p', '5p', '5p', '5p'],
        ['7s', '7s', '7s', '7s'],
        ['1z', '1z', '1z', '1z'],
        ['9m', '9m'],
      ];
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayExampleTiles = widget.rule.exampleTiles.isNotEmpty
        ? widget.rule.exampleTiles
        : (widget.mode == GameMode.taiwan
              ? _resolveTwExampleTilesByRule()
              : const []);
    final displayExampleTags = widget.mode == GameMode.taiwan
      ? _resolveExampleGroupTags()
      : const <String>[];

    // Keep original rule card implementation...
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rule image or icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.rule.imagePath.isNotEmpty
                          ? Image.asset(
                              widget.rule.imagePath,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.casino,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                            )
                          : const Icon(
                              Icons.casino,
                              size: 40,
                              color: Colors.green,
                            ),
                    ),

                    const SizedBox(width: 12),

                    // Rule information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.rule.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.rule.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FanWidget(fan: widget.rule.fan),
                              const Spacer(),
                              TextButton.icon(
                                icon: Icon(
                                  _showExample
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Colors.green,
                                ),
                                label: Text(
                                  _showExample
                                      ? AppLocalizations.hideExample
                                      : AppLocalizations.viewExample,
                                  style: const TextStyle(color: Colors.green),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showExample = !_showExample;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Expanded example section
          if (_showExample)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.exampleExplanation,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (displayExampleTiles.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(displayExampleTiles.length, (
                        index,
                      ) {
                        final tag = index < displayExampleTags.length
                            ? displayExampleTags[index]
                            : '';
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tag.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.green.shade300
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            TileGroup(tiles: displayExampleTiles[index]),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    widget.rule.explanation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
