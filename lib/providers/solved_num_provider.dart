import 'package:flutter/material.dart';
import 'package:oj_helper/utils/solved_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolvedNumProvider extends ChangeNotifier {
  final List<String> platforms = [
    'Codeforces',
    'AtCoder',
    '力扣',
    '洛谷',
    '牛客',
    'VJudge',
    'hdu',
    'poj',
    'QOJ'
  ];

  final Map<String, Color> platformColors = {
    'Codeforces': const Color.fromARGB(255, 64, 128, 255),
    'AtCoder': const Color.fromARGB(255, 102, 178, 255),
    '力扣': const Color.fromARGB(255, 153, 102, 255),
    '洛谷': const Color.fromARGB(255, 50, 205, 50),
    'VJudge': const Color.fromARGB(255, 255, 165, 0),
    'hdu': const Color.fromARGB(255, 150, 150, 150),
    'poj': const Color.fromARGB(255, 200, 200, 200),
    '牛客': const Color.fromARGB(255, 255, 102, 0),
    'QOJ': const Color.fromARGB(255, 255, 20, 147),
  };

  final Map<String, String> shortNames = {
    'Codeforces': 'CF',
    'AtCoder': 'AtC',
    '力扣': '力扣',
    '洛谷': '洛谷',
    'VJudge': 'VJ',
    'hdu': 'HDU',
    'poj': 'POJ',
    '牛客': '牛客',
    'QOJ': 'QOJ'
  };

  final Map<String, TextEditingController> controllers = {};
  final Map<String, String> infoMessages = {};
  final Map<String, bool> isLoading = {};
  final Map<String, int> solvedNums = {};

  SolvedNumProvider() {
    for (var platform in platforms) {
      controllers[platform] = TextEditingController();
      infoMessages[platform] = '';
      isLoading[platform] = false;
      solvedNums[platform] = 0;
    }
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var platform in platforms) {
      final storedUsername = prefs.getString(platform);
      if (storedUsername != null) {
        controllers[platform]!.text = storedUsername;
      }
    }
    notifyListeners();
  }

  Future<void> saveUsername(String platform, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(platform, username);
  }

  void clearUsername(String platform) {
    controllers[platform]!.clear();
    saveUsername(platform, '');
    solvedNums[platform] = 0;
    infoMessages[platform] = '';
    notifyListeners();
  }

  void updateInfoMessage(String platform, String message) {
    infoMessages[platform] = message;
    notifyListeners();
  }

  Future<void> querySolvedNum(String platform) async {
    final username = controllers[platform]!.text;
    if (username.isEmpty) return;

    List<String> usernames = username
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    isLoading[platform] = true;
    infoMessages[platform] = '';
    notifyListeners();

    int totalSolved = 0;
    try {
      for (String user in usernames) {
        final result = await SolvedUtils.getSolvedNum(
          platformName: platform,
          name: user,
        );
        totalSolved += result.solvedNum;
      }
      solvedNums[platform] = totalSolved;
      infoMessages[platform] = usernames.length > 1
          ? '总解题数: $totalSolved (${usernames.length}个用户)'
          : '已解决: $totalSolved';
    } catch (e) {
      infoMessages[platform] = '查询失败，请检查网络或用户名是否正确';
    } finally {
      isLoading[platform] = false;
      notifyListeners();
    }
  }

  void queryAll() {
    for (var platform in platforms) {
      querySolvedNum(platform);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
