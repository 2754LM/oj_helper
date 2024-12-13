import 'package:flutter/material.dart';
import 'package:oj_helper/models/rating.dart';
import 'package:oj_helper/ui/widgets/platform_help.dart';
import 'package:oj_helper/utils/rating_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  // 平台名称
  final List<String> _platformNames = [
    'Codeforces',
    'AtCoder',
    '力扣',
    '洛谷',
    '牛客',
  ];
  Map<String, String?> _infoMessages = {}; // 存储每个平台的查询信息
  Map<String, TextEditingController> _usernameControllers = {}; // 存储每个平台的控制器
  Map<String, bool> _isLoading = {}; //存储每个平台是否正在查询
  Map<String, List<Rating>> _ratingList = {}; // 存储每个平台Rating历史
  @override
  void initState() {
    super.initState();
    _loadPersistedData(); // 加载持久化数据
    // 初始化每个平台的信息为空
    for (var platformName in _platformNames) {
      _infoMessages[platformName] = '';
      _usernameControllers[platformName] =
          TextEditingController(); // 为每个平台创建控制器
      _isLoading[platformName] = false;
    }
  }

  // 加载持久化数据
  Future<void> _loadPersistedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

  // 加载折线图(TODO)
  Future<void> _loadLineChartData() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('别急，没做完'),
          );
        });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分数查询'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () async {
              await _loadLineChartData();
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
                  _queryRating(platformName, username);
                }
              }
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 480,
          mainAxisExtent: 160,
        ),
        itemCount: _platformNames.length,
        itemBuilder: (context, index) {
          final platformName = _platformNames[index];
          return _buildCard(platformName);
        },
      ),
    );
  }

  Widget _buildCard(String platformName) {
    final selectedPlatform = platformName;
    return Card(
      key: ValueKey(platformName),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(172, 211, 218, 220),
          ),
          child: Row(
            children: [
              SizedBox(width: 10),
              Image.asset('assets/platforms/$platformName.jpg',
                  width: 27, height: 27),
              SizedBox(width: 10),
              Text(
                platformName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return _queryRating(
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
                // 使用对应的控制器
                decoration: InputDecoration(
                  labelText: selectedPlatform == '牛客' ? 'id' : '用户名',
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
                            });
                          },
                          icon: Icon(Icons.highlight_off),
                        ),
                ),
                onChanged: (text) {
                  setState(() {
                    _infoMessages[platformName] = '';
                  });
                  _saveUsername(platformName, text);
                }, // 保存用户名
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
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
        // 返回Rating信息
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
      ]),
    );
  }

  void _queryRating(String platformName, String username) async {
    if (username == '') {
      return;
    }
    setState(() {
      _isLoading[platformName] = true;
    });
    Rating? result;
    try {
      result = await RatingUtils.getRating(
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
        _infoMessages[platformName] =
            '当前rating:${result?.curRating}，最高rating:${result?.maxRating}';
      });
    }
  }
}
