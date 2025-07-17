import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/score_service.dart';
import 'dart:io';
import 'dart:async'; // 添加這行引入 StreamSubscription
import 'package:image_picker/image_picker.dart';

class ScoreCalculationScreen extends StatefulWidget {
  final List<Player> players;
  final int currentRound;
  final Function(Map<String, int>) onScoreSubmitted;
  final ScoreService scoreService; // 新增分數服務

  const ScoreCalculationScreen({
    super.key,
    required this.players,
    required this.currentRound,
    required this.onScoreSubmitted,
    required this.scoreService, // 必須提供分數服務
  });

  @override
  State<ScoreCalculationScreen> createState() => _ScoreCalculationScreenState();
}

class _ScoreCalculationScreenState extends State<ScoreCalculationScreen> {
  // 當前選擇的玩家和風向
  late Player _selectedDealer;
  String _selectedWind = '東';
  
  // 和牌方式
  bool _isSelfDraw = true;
  Player? _winningPlayer;
  Player? _discardPlayer;
  
  // 番數和得分
  int _fanCount = 1;
  int _basePoints = 1;
  bool _selfDrawBonus = false;
  bool _fullHouseBonus = false;
  int _flowerCount = 0;
  
  // 牌型預覽
  File? _capturedImage;
  List<List<String>> _tileGroups = [];
  
  // 計算結果
  int _totalPoints = 0;
  
  // 監聽分數變化
  StreamSubscription? _scoreSubscription;

  @override
  void initState() {
    super.initState();
    // 默認選擇第一個玩家作為莊家
    _selectedDealer = widget.players.isNotEmpty ? widget.players[0] : Player(id: 0, name: "玩家1", score: 0);
    _winningPlayer = _selectedDealer;
    
    // 確保只有在有效的 scoreService 時才訂閱
    try {
      // 監聽分數變化
      _scoreSubscription = widget.scoreService.scoreStream.listen((scores) {
        // 當分數變化時，更新UI
        if (mounted) {
          setState(() {
            // 這裡不需要做任何事，因為我們使用 _getPlayerCurrentScore 方法來獲取最新分數
          });
        }
      });
    } catch (e) {
      print('訂閱分數流時出錯: $e');
    }
  }
  
  @override
  void dispose() {
    // 確保安全取消訂閱
    try {
      _scoreSubscription?.cancel();
    } catch (e) {
      print('取消分數訂閱時出錯: $e');
    }
    super.dispose();
  }

  // 計算得分
  void _calculateScore() {
    // 基本得分計算
    int baseScore = _basePoints;
    
    // 計算番數（2的冪次方）
    int fanMultiplier = 1;
    for (int i = 0; i < _fanCount; i++) {
      fanMultiplier *= 2;
    }
    
    // 加上自摸獎勵
    int selfDrawBonus = _selfDrawBonus ? 1 : 0;
    
    // 加上全求人獎勵
    int fullHouseBonus = _fullHouseBonus ? 1 : 0;
    
    // 加上花牌分數
    int flowerPoints = _flowerCount;
    
    // 計算總分
    _totalPoints = baseScore * fanMultiplier + selfDrawBonus + fullHouseBonus + flowerPoints;
    
    setState(() {});
  }

  // 拍照獲取牌型
  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        // 實際應用中，這裡應該有圖像識別邏輯來解析麻將牌
        // 這裡使用示例數據
        _tileGroups = [
          ["1w", "2w", "3w"],
          ["7t", "8t", "9t"],
          ["1s", "1s", "1s"],
          ["east", "east", "east"],
          ["fa", "fa"]
        ];
      });
    }
  }

  // 提交得分
  void _submitScore() {
    Map<String, int> scoreChanges = {};
    
    // 根據自摸或放槍計算各玩家得分變化
    if (_isSelfDraw && _winningPlayer != null) {
      // 自摸：其他玩家都輸分
      for (var player in widget.players) {
        if (player.id != _winningPlayer!.id) {
          // 自摸時其他玩家都輸相同的分
          scoreChanges[player.id.toString()] = -_totalPoints;
        }
      }
      // 贏家得到所有分數
      scoreChanges[_winningPlayer!.id.toString()] = _totalPoints * (widget.players.length - 1);
    } else if (!_isSelfDraw && _winningPlayer != null && _discardPlayer != null) {
      // 放槍：只有放槍者輸分
      scoreChanges[_discardPlayer!.id.toString()] = -_totalPoints;
      scoreChanges[_winningPlayer!.id.toString()] = _totalPoints;
    }
    
    // 更新分數服務中的分數
    widget.scoreService.updateScores(scoreChanges);
    
    // 增加回合數
    widget.scoreService.incrementRound();
    
    // 調用回調函數，更新得分
    widget.onScoreSubmitted(scoreChanges);
    
    // 顯示提交成功的消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分數已更新，進入下一局')),
    );
    
    // 返回上一頁
    Navigator.pop(context);
  }

  // 獲取玩家當前分數
  int _getPlayerCurrentScore(Player player) {
    return widget.scoreService.getPlayerScore(player.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    // 使用當前莊家和風向構建標題
    String title = "第${widget.currentRound}局：莊家 - ${_selectedDealer.name} (${_selectedWind})";
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // 顯示幫助信息
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 玩家選擇區域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '莊家設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 莊家選擇下拉框
                    DropdownButtonFormField<Player>(
                      decoration: const InputDecoration(
                        labelText: '莊家',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedDealer,
                      items: widget.players.map((player) {
                        return DropdownMenuItem<Player>(
                          value: player,
                          child: Text('${player.name} (當前: ${_getPlayerCurrentScore(player)}分)'),
                        );
                      }).toList(),
                      onChanged: (Player? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDealer = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // 風向選擇
                    const Text('風向'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Radio<String>(
                            value: '東',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('東'),
                          Radio<String>(
                            value: '南',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('南'),
                          Radio<String>(
                            value: '西',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('西'),
                          Radio<String>(
                            value: '北',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('北'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 和牌設定
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '和牌',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 自摸或放槍選擇
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isSelfDraw,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _isSelfDraw = value;
                              });
                            }
                          },
                        ),
                        const Text('自摸'),
                        const SizedBox(width: 24),
                        Radio<bool>(
                          value: false,
                          groupValue: _isSelfDraw,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _isSelfDraw = value;
                              });
                            }
                          },
                        ),
                        const Text('放槍'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 和牌玩家選擇
                    DropdownButtonFormField<Player>(
                      decoration: const InputDecoration(
                        labelText: '和牌玩家',
                        border: OutlineInputBorder(),
                      ),
                      value: _winningPlayer,
                      items: widget.players.map((player) {
                        return DropdownMenuItem<Player>(
                          value: player,
                          child: Text('${player.name} (當前: ${_getPlayerCurrentScore(player)}分)'),
                        );
                      }).toList(),
                      onChanged: (Player? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _winningPlayer = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // 放槍玩家選擇（僅當選擇放槍時顯示）
                    if (!_isSelfDraw)
                      DropdownButtonFormField<Player>(
                        decoration: const InputDecoration(
                          labelText: '放槍玩家',
                          border: OutlineInputBorder(),
                        ),
                        value: _discardPlayer ?? (_winningPlayer == widget.players[0] ? widget.players.length > 1 ? widget.players[1] : null : widget.players[0]),
                        items: widget.players
                            .where((player) => player.id != _winningPlayer?.id)
                            .map((player) {
                          return DropdownMenuItem<Player>(
                            value: player,
                            child: Text('${player.name} (當前: ${_getPlayerCurrentScore(player)}分)'),
                          );
                        }).toList(),
                        onChanged: (Player? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _discardPlayer = newValue;
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 番數和得分設定
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '番數',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 番數選擇
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: '番數',
                        border: OutlineInputBorder(),
                      ),
                      value: _fanCount,
                      items: List.generate(13, (index) => index + 1).map((fan) {
                        return DropdownMenuItem<int>(
                          value: fan,
                          child: Text('$fan 番'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _fanCount = newValue;
                            _calculateScore();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // 基本分設定
                    const Text('基本分:'),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(value: 1, label: Text('1分')),
                          ButtonSegment<int>(value: 2, label: Text('2分')),
                          ButtonSegment<int>(value: 4, label: Text('4分')),
                        ],
                        selected: {_basePoints},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _basePoints = newSelection.first;
                            _calculateScore();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 額外獎勵選項
                    CheckboxListTile(
                      title: const Text('自摸(+1分)'),
                      value: _selfDrawBonus,
                      onChanged: (bool? value) {
                        setState(() {
                          _selfDrawBonus = value ?? false;
                          _calculateScore();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('全求人(+1分)'),
                      value: _fullHouseBonus,
                      onChanged: (bool? value) {
                        setState(() {
                          _fullHouseBonus = value ?? false;
                          _calculateScore();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    // 花牌數量選擇
                    const Text('花牌數量:'),
                    const SizedBox(height: 8),
                    // 使用Wrap來解決溢出問題
                    Wrap(
                      spacing: 8,
                      children: [0, 1, 2, 3, 4].map((count) {
                        final isSelected = _flowerCount == count;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _flowerCount = count;
                              _calculateScore();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 拍照獲取牌型按鈕
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照獲取牌型'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _captureImage,
            ),
            
            const SizedBox(height: 16),
            
            // 牌局預覽區域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '牌局預覽區域',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_capturedImage != null)
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_capturedImage!),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '拍照或選擇牌型以顯示預覽',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 得分摘要區域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '得分計算',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 得分詳情列表
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('項目')),
                        DataColumn(label: Text('分數')),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('基本番')),
                          DataCell(Text('$_basePoints')),
                        ]),
                        if (_fullHouseBonus)
                          const DataRow(cells: [
                            DataCell(Text('全求人')),
                            DataCell(Text('1')),
                          ]),
                        if (_selfDrawBonus)
                          const DataRow(cells: [
                            DataCell(Text('自摸')),
                            DataCell(Text('1')),
                          ]),
                        if (_flowerCount > 0)
                          DataRow(cells: [
                            const DataCell(Text('花牌')),
                            DataCell(Text('$_flowerCount')),
                          ]),
                        DataRow(cells: [
                          const DataCell(Text('總得分', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('$_totalPoints points', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 底部操作按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitScore,
                    child: const Text('下一局', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // 取消計算，返回上一頁
                      Navigator.pop(context);
                    },
                    child: const Text('取消', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 顯示幫助對話框
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('計分說明'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('1. 選擇莊家和風向'),
              SizedBox(height: 8),
              Text('2. 選擇和牌方式（自摸或放槍）'),
              SizedBox(height: 8),
              Text('3. 輸入番數和基本分'),
              SizedBox(height: 8),
              Text('4. 選擇額外獎勵（自摸、全求人等）'),
              SizedBox(height: 8),
              Text('5. 拍照獲取牌型或手動選擇'),
              SizedBox(height: 8),
              Text('6. 確認得分計算結果'),
              SizedBox(height: 8),
              Text('7. 點擊"下一局"保存並進入下一局'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
}