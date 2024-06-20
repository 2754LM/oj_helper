import 'package:flutter/material.dart';
import 'package:oj_helper/models/rating.dart';
import 'package:oj_helper/utils/rating_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final List<String> _platformNames = [
    'Codeforces',
    'AtCoder',
    '力扣',
    '洛谷',
    '牛客',
  ];

  Map<String, String?> _infoMessages = {};
  Map<String, TextEditingController> _usernameControllers = {}; // 存储每个平台的控制器

  @override
  void initState() {
    super.initState();
    _loadPersistedData(); // 加载持久化数据
    // 初始化每个平台的信息为空
    for (var platformName in _platformNames) {
      _infoMessages[platformName] = null;
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
      }
    }
  }

  // 保存用户输入的用户名
  Future<void> _saveUsername(String platformName, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(platformName, username);
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/platforms/牛客.jpg'), context);
    precacheImage(AssetImage('assets/platforms/洛谷.jpg'), context);
    precacheImage(AssetImage('assets/platforms/力扣.jpg'), context);
    precacheImage(AssetImage('assets/platforms/AtCoder.jpg'), context);
    precacheImage(AssetImage('assets/platforms/Codeforces.jpg'), context);
    return Scaffold(
        drawer: Drawer(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('分数查询'),
            background: Container(
              // 设置背景颜色
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 480,
            mainAxisExtent: 160,
          ),
          itemCount: _platformNames.length,
          itemBuilder: (context, index) {
            final platformName = _platformNames[index];
            return _buildCard(platformName, index);
          },
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.search),
            onPressed: () {
              // 使用 for 循环遍历所有平台进行查询
              for (var platformName in _platformNames) {
                final username = _usernameControllers[platformName]!.text;
                if (username.isNotEmpty) {
                  _queryRating(platformName, username);
                }
              }
            }));
  }

  Widget _buildCard(String platformName, int index) {
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
              IconButton(
                onPressed: () => null,
                icon: const Icon(Icons.help),
              ),
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
                  labelText:
                      selectedPlatform == '牛客' || selectedPlatform == '洛谷'
                          ? 'id'
                          : '用户名',
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
                    _infoMessages[platformName] = null;
                  });
                  _saveUsername(platformName, text);
                }, // 保存用户名
              ),
            ),
            SizedBox(width: 20),
          ],
        ),

        // Rating信息
        if (_infoMessages[platformName] != null)
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
    Rating? result;
    try {
      result = await RatingtUtils.getRating(
          platformName: platformName, name: username);
    } catch (e) {
      setState(() {
        _infoMessages[platformName] = '查询失败，请检查网络或用户名是否正确';
      });
      return;
    }
    if (platformName == '力扣') {
      setState(() {
        _infoMessages[platformName] = '当前rating:${result?.curRating}';
      });
    } else {
      setState(() {
        _infoMessages[platformName] =
            '当前rating:${result?.curRating}，最高rating:${result?.maxRating}';
      });
    }
  }
}
