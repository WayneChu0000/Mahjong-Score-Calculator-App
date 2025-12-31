import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../models/rule.dart';
import '../widgets/tile_group.dart';
import 'tutorial_content.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> with SingleTickerProviderStateMixin {
  String _selectedFan = 'All';
  String _searchQuery = '';
  List<Rule> _filteredRules = [];
  late TabController _tabController;
  late PageController _tutorialPageController;
  late TextEditingController _searchController;
  int _currentTutorialPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredRules = rules;
    _tabController = TabController(length: 2, vsync: this);
    _tutorialPageController = PageController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tutorialPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterRules() {
    setState(() {
      List<Rule> tempRules = rules;
      
      // Filter by fan
      if (_selectedFan != 'All') {
        // Extract number from "X fan" string in rule.fan
        // rule.fan format is "X fan"
        // _selectedFan format is "X Fan" or "X Fans"
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
            .where((rule) =>
                rule.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                rule.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Rules & Tutorial',
      currentIndex: 1,
      body: Column(
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
              tabs: const [
                Tab(
                  icon: Icon(Icons.menu_book),
                  text: 'Rules Reference',
                ),
                Tab(
                  icon: Icon(Icons.school),
                  text: 'Mahjong Tutorial',
                ),
              ],
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
                _buildTutorialTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Rules reference tab content
  Widget _buildRulesReferenceTab() {
    // Generate fan options
    final List<String> fanOptions = ['All'];
    for (int i = 1; i <= 13; i++) {
      fanOptions.add('$i Fan${i > 1 ? 's' : ''}');
    }

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
                        decoration: const InputDecoration(
                          labelText: 'Search Rules',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
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
        ..._filteredRules.map((rule) => RuleCard(rule: rule)).toList(),

        // Bottom space for good scrolling experience
        const SizedBox(height: 16),
      ],
    );
  }
  
  void _navigateToRule(String ruleName) {
    setState(() {
      _searchQuery = ruleName;
      _searchController.text = ruleName;
      _selectedFan = 'All'; // Reset fan filter to ensure rule is found
      _filterRules();
    });
    _tabController.animateTo(0); // Switch to Rules Reference tab
  }

  // Tutorial tab content
  Widget _buildTutorialTab() {
    const tutorialTitles = [
      'Welcome',
      'Mahjong Tiles',
      'Basic Rules',
      'Score',
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Tutorial page navigation
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
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
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
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tutorialTitles[index],
                          style: TextStyle(
                            color: _currentTutorialPage == index 
                                ? Colors.white 
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
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
              TutorialContent(pageIndex: 0, onRuleTap: _navigateToRule),
              TutorialContent(pageIndex: 1, onRuleTap: _navigateToRule),
              TutorialContent(pageIndex: 2, onRuleTap: _navigateToRule),
              TutorialContent(pageIndex: 3, onRuleTap: _navigateToRule),
            ],
          ),
        ),
        
        // Bottom navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentTutorialPage > 0
                    ? () {
                        setState(() {
                          _currentTutorialPage--;
                        });
                        _tutorialPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
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
                        setState(() {
                          _currentTutorialPage++;
                        });
                        _tutorialPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
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

  const RuleCard({super.key, required this.rule});

  @override
  State<RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<RuleCard> {
  bool _showExample = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                        color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.rule.imagePath.isNotEmpty
                          ? Image.asset(
                              widget.rule.imagePath,
                              errorBuilder: (context, error, stackTrace) => const Icon(
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
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FanWidget(fan: widget.rule.fan),
                              const Spacer(),
                              TextButton.icon(
                                icon: Icon(
                                  _showExample ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  color: Colors.green,
                                ),
                                label: Text(
                                  _showExample ? 'Hide Example' : 'View Example',
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
                color: isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example Explanation:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Use Wrap to display mahjong tiles
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.rule.exampleTiles.map((group) => 
                      TileGroup(tiles: group)
                    ).toList(),
                  ),
                  const SizedBox(height: 8),
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