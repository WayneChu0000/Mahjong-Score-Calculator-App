import 'package:flutter/material.dart';

class TutorialContent extends StatefulWidget {
  const TutorialContent({super.key});

  @override
  State<TutorialContent> createState() => _TutorialContentState();
}

class _TutorialContentState extends State<TutorialContent> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 進度指示器
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                '進度: ${_currentStep + 1}/$_totalSteps',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 教程內容
        _buildTutorialStep(_currentStep),

        const SizedBox(height: 24),

        // 導航按鈕
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 上一步按鈕
            if (_currentStep > 0)
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('上一步'),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
              )
            else
              const SizedBox(width: 100), // 占位

            // 下一步或完成按鈕
            if (_currentStep < _totalSteps - 1)
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('下一步'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _currentStep++;
                  });
                },
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('完成教程'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  // 完成教程的邏輯，例如顯示成就或返回首頁
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('恭喜！您已完成麻將教程！')),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  // 根據當前步驟構建相應的教程內容
  Widget _buildTutorialStep(int step) {
    switch (step) {
      case 0:
        return _buildBasicRulesStep();
      case 1:
        return _buildTilesIntroductionStep();
      case 2:
        return _buildCombinationsStep();
      case 3:
        return _buildScoringMethodStep();
      case 4:
        return _buildAdvancedTipsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // 第一步：麻將基礎規則
  Widget _buildBasicRulesStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/tutorial/basic_rules.png', 
                  width: 80, 
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.green.shade100,
                    child: const Icon(Icons.casino, size: 50, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '麻將基礎規則',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '麻將是一種源於中國的傳統遊戲，通常由四人玩，使用一副麻將牌。每位玩家開始時有13張牌，目標是通過摸牌和打牌形成特定的牌型組合。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '基本規則：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRulePoint('每位玩家初始獲得13張牌'),
            _buildRulePoint('輪流摸牌和打牌，手牌始終保持13張'),
            _buildRulePoint('目標是形成4組刻子或順子，加1對將牌'),
            _buildRulePoint('刻子：3張相同的牌'),
            _buildRulePoint('順子：3張同花色連續的牌'),
            _buildRulePoint('將牌：1對相同的牌'),
            const SizedBox(height: 16),
            // 練習按鈕
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('立即練習'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                // 跳轉到練習頁面的邏輯
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('練習功能即將推出！')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 第二步：麻將牌介紹
  Widget _buildTilesIntroductionStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '麻將牌介紹',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '麻將牌共有三種花色：萬子、筒子和條子，每種花色從1到9，各4張。此外還有風牌（東、南、西、北）和箭牌（中、發、白）。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // 萬子牌
            _buildTileCategory('萬子牌', 'assets/images/tutorial/wan.png'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: List.generate(9, (index) => 
                Image.asset(
                  'assets/images/tiles/wan/${index + 1}w.png',
                  width: 35,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 35,
                    height: 45,
                    color: Colors.blue.shade50,
                    alignment: Alignment.center,
                    child: Text('${index + 1}萬'),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 筒子牌
            _buildTileCategory('筒子牌', 'assets/images/tutorial/tong.png'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: List.generate(9, (index) => 
                Image.asset(
                  'assets/images/tiles/tong/${index + 1}t.png',
                  width: 35,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 35,
                    height: 45,
                    color: Colors.orange.shade50,
                    alignment: Alignment.center,
                    child: Text('${index + 1}筒'),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 條子牌
            _buildTileCategory('條子牌', 'assets/images/tutorial/suo.png'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: List.generate(9, (index) => 
                Image.asset(
                  'assets/images/tiles/suo/${index + 1}s.png',
                  width: 35,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 35,
                    height: 45,
                    color: Colors.green.shade50,
                    alignment: Alignment.center,
                    child: Text('${index + 1}條'),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 風牌
            _buildTileCategory('風牌', 'assets/images/tutorial/wind.png'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: ['east', 'south', 'west', 'north'].map((wind) => 
                Image.asset(
                  'assets/images/tiles/feng/$wind.png',
                  width: 35,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 35,
                    height: 45,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Text(
                      wind == 'east' ? '東' : 
                      wind == 'south' ? '南' : 
                      wind == 'west' ? '西' : '北'
                    ),
                  ),
                ),
              ).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 箭牌
            _buildTileCategory('箭牌', 'assets/images/tutorial/arrow.png'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: ['zhong', 'fa', 'bai'].map((arrow) => 
                Image.asset(
                  'assets/images/tiles/jian/$arrow.png',
                  width: 35,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 35,
                    height: 45,
                    color: arrow == 'zhong' ? Colors.red.shade50 : 
                           arrow == 'fa' ? Colors.green.shade50 : Colors.white,
                    alignment: Alignment.center,
                    child: Text(
                      arrow == 'zhong' ? '中' : 
                      arrow == 'fa' ? '發' : '白'
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 第三步：番種組合介紹
  Widget _buildCombinationsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/tutorial/combinations.png', 
                  width: 80, 
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.amber.shade100,
                    child: const Icon(Icons.auto_awesome, size: 50, color: Colors.amber),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '番種組合介紹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '視頻時長: 2:30',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 視頻播放器（模擬）
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_filled,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '點擊播放視頻',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 模擬進度條
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '本視頻講解常見番種組合：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRulePoint('清一色：同一花色的牌組成的和牌', hasIcon: false),
            _buildRulePoint('七對子：7組對子組成的和牌', hasIcon: false),
            _buildRulePoint('對對和：4組刻子加1對將牌', hasIcon: false),
            _buildRulePoint('大三元：中、發、白三種箭牌的刻子', hasIcon: false),
            _buildRulePoint('小四喜：3種風牌的刻子加1對風牌', hasIcon: false),
          ],
        ),
      ),
    );
  }

  // 第四步：計分方法詳解
  Widget _buildScoringMethodStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '計分方法詳解',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '香港麻將計分系統以「番」為單位，每種特定的牌型組合都有對應的番數。番數越高，得分越多。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // 番數表格
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // 表頭
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '牌型名稱',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '番數',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 表格內容
                  _buildScoringRow('平和', '1番'),
                  _buildScoringRow('斷么九', '1番'),
                  _buildScoringRow('門前清', '1番'),
                  _buildScoringRow('自摸', '1番'),
                  _buildScoringRow('全求人', '2番'),
                  _buildScoringRow('混一色', '3番'),
                  _buildScoringRow('七對子', '4番'),
                  _buildScoringRow('碰碰和', '4番'),
                  _buildScoringRow('小三元', '5番'),
                  _buildScoringRow('清一色', '7番'),
                  _buildScoringRow('大三元', '8番'),
                  _buildScoringRow('小四喜', '8番'),
                  _buildScoringRow('字一色', '10番'),
                  _buildScoringRow('大四喜', '13番'),
                  _buildScoringRow('九蓮寶燈', '13番'),
                  _buildScoringRow('十三么', '13番'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              '計分公式：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                children: [
                  Text('基本分 × 2^(番數)'),
                  SizedBox(height: 8),
                  Text('例如：基本分為1分，清一色為7番，則得分為 1 × 2^7 = 128分'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 第五步：進階技巧
  Widget _buildAdvancedTipsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/tutorial/advanced.png', 
                  width: 80, 
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.purple.shade100,
                    child: const Icon(Icons.psychology, size: 50, color: Colors.purple),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '進階技巧與策略',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '掌握了基礎規則和計分方法後，以下進階技巧可以幫助你提升遊戲水平：',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // 技巧列表
            _buildAdvancedTip(
              title: '聽牌選擇',
              description: '儘量選擇多面聽牌，增加和牌機會。例如，23456可以聽14和7，比只聽一張牌的牌型更有利。',
            ),
            const SizedBox(height: 12),
            _buildAdvancedTip(
              title: '防守意識',
              description: '觀察其他玩家打出的牌和碰槓情況，推測他們的聽牌，避免打出危險牌。',
            ),
            const SizedBox(height: 12),
            _buildAdvancedTip(
              title: '牌效分析',
              description: '評估手牌潛力，決定是追求高番還是速和。有時低番快和比等待高番更有利。',
            ),
            const SizedBox(height: 12),
            _buildAdvancedTip(
              title: '局勢判斷',
              description: '根據自己在局中的位置、點數情況和剩餘牌數，調整進攻或防守策略。',
            ),
            
            const SizedBox(height: 24),
            
            // 練習建議
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '練習建議',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRulePoint('使用本應用的練習模式熟悉不同牌型', color: Colors.green.shade800, hasIcon: false),
                  _buildRulePoint('與朋友進行實戰練習，並分析每局得失', color: Colors.green.shade800, hasIcon: false),
                  _buildRulePoint('觀看專業比賽或教學視頻，學習高手策略', color: Colors.green.shade800, hasIcon: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 輔助方法：構建規則要點
  Widget _buildRulePoint(String text, {Color color = Colors.black87, bool hasIcon = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasIcon)
            Icon(Icons.check_circle, size: 20, color: Colors.green)
          else
            const Text('•  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // 輔助方法：構建牌類別標題
  Widget _buildTileCategory(String title, String imagePath) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.category,
            size: 30,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 輔助方法：構建計分表的一行
  Widget _buildScoringRow(String name, String fan) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.grey.shade300,
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                fan,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fan.contains('13') ? Colors.red : Colors.black,
                  fontWeight: fan.contains('13') ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 輔助方法：構建進階技巧項
  Widget _buildAdvancedTip({required String title, required String description}) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}