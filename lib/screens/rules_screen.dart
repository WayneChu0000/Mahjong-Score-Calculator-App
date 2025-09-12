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
  String _selectedRuleSet = 'hk';
  String _searchQuery = '';
  List<Rule> _filteredRules = [];
  late TabController _tabController;
  late PageController _tutorialPageController;
  int _currentTutorialPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredRules = rules;
    _tabController = TabController(length: 2, vsync: this);
    _tutorialPageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tutorialPageController.dispose();
    super.dispose();
  }

  void _filterRules() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredRules = rules;
      } else {
        _filteredRules = rules
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
      title: '規則與教程',
      currentIndex: 2,
      body: Column(
        children: [
          // 頂部標籤
          Material(
            color: Colors.green.shade50,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green.shade800,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(
                  icon: Icon(Icons.menu_book),
                  text: '規則參考',
                ),
                Tab(
                  icon: Icon(Icons.school),
                  text: '麻將教程',
                ),
              ],
            ),
          ),
          
          // 標籤內容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 規則參考頁面
                _buildRulesReferenceTab(),
                
                // 麻將教程頁面
                _buildTutorialTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 規則參考標籤的內容
  Widget _buildRulesReferenceTab() {
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        // 搜尋區域
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedRuleSet,
                      items: const [
                        DropdownMenuItem(value: 'hk', child: Text('香港規則')),
                        DropdownMenuItem(value: 'mixed', child: Text('混雜規則')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRuleSet = newValue;
                            // 實際應用中，這裡可以切換不同的規則集
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '搜尋規則',
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

        // 規則卡片列表
        ..._filteredRules.map((rule) => RuleCard(rule: rule)).toList(),

        // 底部空間，提供良好的滾動體驗
        const SizedBox(height: 16),
      ],
    );
  }
  
  // 教學標籤的內容
  Widget _buildTutorialTab() {
    const tutorialTitles = [
      '歡迎使用',
      '麻將牌型',
      '基本規則',
      '計分系統',
    ];

    return Column(
      children: [
        // 教學頁面導航
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
                          : Colors.grey.shade200,
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
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tutorialTitles[index],
                          style: TextStyle(
                            color: _currentTutorialPage == index 
                                ? Colors.white 
                                : Colors.grey.shade600,
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
        
        // 教學內容頁面
        Expanded(
          child: PageView(
            controller: _tutorialPageController,
            onPageChanged: (index) {
              setState(() {
                _currentTutorialPage = index;
              });
            },
            children: const [
              TutorialContent(pageIndex: 0),
              TutorialContent(pageIndex: 1),
              TutorialContent(pageIndex: 2),
              TutorialContent(pageIndex: 3),
            ],
          ),
        ),
        
        // 底部導航按鈕
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
                label: const Text('上一頁'),
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
                label: const Text('下一頁'),
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

// 顯示番數的紅色圓圈小部件 - 保留原有代碼
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

// RuleCard 類 - 保留原有代碼
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
    // 保留原有的規則卡片實現...
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
                    // 規則圖片或圖標
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
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
                    
                    // 規則信息
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
                              color: Colors.grey.shade700,
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
                                  _showExample ? '隱藏實例' : '查看實例',
                                  style: TextStyle(color: Colors.green),
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
          // 展開的實例部分
          if (_showExample)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '實例說明:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 使用 Wrap 顯示麻將牌
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