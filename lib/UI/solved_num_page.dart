import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:oj_helper/models/solved_num.dart';
import 'package:oj_helper/ui/widgets/platform_help.dart';
import 'package:oj_helper/utils/solved_utils.dart' show SolvedUtils;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SolvedNumPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SolvedNumPageState();
}

class _SolvedNumPageState extends State<SolvedNumPage> {
  // 平台名称
  final List<String> _platformNames = [
    'Codeforces',
    'AtCoder',
    '力扣',
    '洛谷',
    '牛客',
    'VJudge',
    'hdu',
    'poj',
    // 'CodeChef',
  ];
  // 平台颜色
  Map<String, Color> _platforColor = {
    'Codeforces': const Color.fromARGB(255, 64, 128, 255), // 深蓝色
    'AtCoder': const Color.fromARGB(255, 102, 178, 255), // 中蓝色
    '力扣': const Color.fromARGB(255, 153, 102, 255), // 淡紫色
    '洛谷': const Color.fromARGB(255, 50, 205, 50), // 深绿色
    'VJudge': const Color.fromARGB(255, 255, 165, 0), // 橘黄色
    'hdu': const Color.fromARGB(255, 150, 150, 150), // 中灰色
    'poj': const Color.fromARGB(255, 200, 200, 200), // 浅灰色
    '牛客': const Color.fromARGB(255, 255, 102, 0), // 橙色
    'CodeChef': const Color.fromARGB(255, 255, 215, 0) //金黄色
  };
  // 平台简称
  Map<String, String> shortNmae = {
    'Codeforces': 'CF',
    'AtCoder': 'AtC',
    '力扣': '力扣',
    '洛谷': '洛谷',
    'VJudge': 'VJ',
    'hdu': 'HDU',
    'poj': 'POJ',
    '牛客': '牛客',
    'CodeChef': 'cchef'
  };
  Map<String, bool> _isLoading = {}; //存储每个平台是否正在查询
  Map<String, String?> _infoMessages = {}; // 存储每个平台的查询信息
  Map<String, int> _platformSolvedNums = {}; // 存储每个平台的解题数
  Map<String, TextEditingController> _usernameControllers = {}; // 存储每个平台的控制器

  @override
  void initState() {
    super.initState();
    _loadPersistedData(); // 加载持久化数据
    // 初始化每个平台的信息为空
    for (var platformName in _platformNames) {
      _isLoading[platformName] = false;
      _infoMessages[platformName] = '';
      _platformSolvedNums[platformName] = 0;
      _usernameControllers[platformName] =
          TextEditingController(); // 为每个平台创建控制器
    }
  }

  // 加载持久化数据
  Future<void> _loadPersistedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 从 SharedPreferences 加载用户名
    for (var platformName in _platformNames) {
      String? storedUsername = prefs.getString(platformName);
      if (storedUsername != null) {
        _usernameControllers[platformName]!.text = storedUsername;
        setState(() {});
      }
    }
  }

  // 保存用户输入的用户名
  Future<void> _saveUsername(String platformName, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(platformName, username);
  }

  //加载饼状图
  Future<void> _loadPieChartData() async {
    final size = MediaQuery.of(context).size;
    final higthtSize = size.height * 0.8;
    final widghtSize = size.width * 0.8;
    List<PieChartSectionData> dataList = [];
    int sum = 0;
    for (var platformName in _platformNames) {
      if (_platformSolvedNums[platformName] == 0) {
        continue;
      }
      sum += _platformSolvedNums[platformName]!;
      dataList.add(PieChartSectionData(
        title: shortNmae[platformName],
        value: _platformSolvedNums[platformName]!.toDouble(),
        showTitle: true,
        color: _platforColor[platformName]!,
        radius: higthtSize < widghtSize ? higthtSize * 0.4 : widghtSize * 0.4,
        titlePositionPercentageOffset: 0.6,
        borderSide: BorderSide(
          width: 1,
          color: Colors.black,
        ),
        titleStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ));
    }
    if (sum == 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('提示'),
              children: [
                Text('暂无数据，请先查询题目',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                    maxLines: 2),
              ],
            );
          });
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('解题统计'),
          children: [
            Wrap(children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '总计：$sum题',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green, // 设置文本颜色
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  SizedBox(
                    width: widghtSize < higthtSize
                        ? widghtSize
                        : higthtSize, // 设置宽度
                    height: widghtSize < higthtSize
                        ? widghtSize
                        : higthtSize, // 设置高度
                    child: PieChart(
                      PieChartData(
                        sections: dataList,
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  )
                ],
              ),
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('题目统计'), // 设置标题
          background: Container(
            color: Colors.white, // 设置背景颜色
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () async {
              await _loadPieChartData();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () {
              // 遍历所有平台进行查询
              for (var platformName in _platformNames) {
                final username = _usernameControllers[platformName]!.text;
                if (username.isNotEmpty) {
                  _querySolvedNum(platformName, username);
                }
              }
            },
          ),
        ],
      ),
      //显示的card网格
      body: Wrap(
        children: [
          for (var i in _platformNames) ...[
            _buildCard(i),
          ]
          // StaggeredGridView.extentBuilder(
          //   maxCrossAxisExtent: 480,
          //   staggeredTileBuilder: (index) => StaggeredTile.fit(1),
          //   itemCount: _platformNames.length,
          //   itemBuilder: (context, index) {
          //     return _buildCard(_platformNames[index], index);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildCard(String platformName) {
    return Card(
      key: ValueKey(platformName),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //card头部
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(172, 211, 218, 220),
            ),
            //平台信息
            child: Row(
              children: [
                SizedBox(width: 10),
                Image.asset('assets/platforms/$platformName.jpg',
                    width: 27, height: 27),
                SizedBox(width: 10),
                Text(
                  platformName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(child: const SizedBox()),
                if (platformName == '牛客')
                  IconButton(
                    onPressed: () async {
                      await getNowcoderPlatformHelp(context);
                    },
                    icon: const Icon(Icons.help),
                  ),
                if (platformName == '力扣')
                  IconButton(
                    onPressed: () async {
                      await getLeetcodePlatformHelp(context);
                    },
                    icon: const Icon(Icons.help),
                  )
                else
                  Container(),
                IconButton(
                  onPressed: () {
                    _querySolvedNum(
                        platformName, _usernameControllers[platformName]!.text);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          SizedBox(height: 13),
          // 输入框
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _usernameControllers[platformName],
                  enabled: _isLoading[platformName] == false,
                  // 使用对应的控制器
                  decoration: InputDecoration(
                    labelText: platformName == '牛客' ? 'id' : '用户名',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: const TextStyle(color: Colors.blue),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    suffixIcon: _usernameControllers[platformName]!.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _usernameControllers[platformName]!.clear();
                                _saveUsername(platformName, '');
                                _infoMessages[platformName] = '';
                              });
                            },
                            icon: Icon(Icons.highlight_off),
                          ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _platformSolvedNums[platformName] = 0;
                      _infoMessages[platformName] = '';
                    });
                    _saveUsername(platformName, text);
                  }, // 保存用户名
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
          // 进度条
          if (_isLoading[platformName] == true)
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    backgroundColor: const Color.fromARGB(255, 126, 186, 213),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                SizedBox(width: 20),
              ],
            )
          else
            const SizedBox(),
          //返回信息
          if (_infoMessages[platformName] != '')
            Text(
              _infoMessages[platformName]!,
              style: TextStyle(
                  fontSize: 16,
                  color: _infoMessages[platformName] != '查询失败，请检查网络或用户名是否正确'
                      ? Colors.green
                      : Colors.red),
              textAlign: TextAlign.center,
              maxLines: 2,
            )
        ],
      ),
    );
  }

  // 查询SolvedNum函数
  void _querySolvedNum(String platformName, String username) async {
    if (username == '') {
      return;
    }
    setState(() {
      _isLoading[platformName] = true;
    });
    SolvedNum? solvedNumResult;
    try {
      solvedNumResult = await SolvedUtils.getSolvedNum(
          platformName: platformName, name: username);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading[platformName] = false;
          _infoMessages[platformName] = '查询失败，请检查网络或用户名是否正确';
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading[platformName] = false;
        _platformSolvedNums[platformName] = solvedNumResult!.solvedNum;
        _infoMessages[platformName] = '已解决：${solvedNumResult.solvedNum}';
      });
    }
  }
}
