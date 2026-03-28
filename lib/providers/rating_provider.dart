import 'package:flutter/material.dart';
import 'package:oj_helper/models/rating.dart';
import 'package:oj_helper/utils/rating_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingProvider extends ChangeNotifier {
  final List<String> platforms = [
    'Codeforces',
    'AtCoder',
    '力扣',
    '洛谷',
    '牛客',
    'CodeChef',
  ];

  final Map<String, TextEditingController> controllers = {};
  final Map<String, String> infoMessages = {};
  final Map<String, bool> isLoading = {};
  final Map<String, List<Rating>> ratingHistory = {};

  RatingProvider() {
    for (var platform in platforms) {
      controllers[platform] = TextEditingController();
      infoMessages[platform] = '';
      isLoading[platform] = false;
      ratingHistory[platform] = [];
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
    infoMessages[platform] = '';
    notifyListeners();
  }

  void updateInfoMessage(String platform, String message) {
    infoMessages[platform] = message;
    notifyListeners();
  }

  Future<void> queryRating(String platform) async {
    final username = controllers[platform]!.text;
    if (username.isEmpty) return;

    isLoading[platform] = true;
    infoMessages[platform] = '';
    notifyListeners();

    try {
      final result = await RatingUtils.getRating(
        platformName: platform,
        name: username,
      );
      infoMessages[platform] =
          '当前rating:${result.curRating}，最高rating:${result.maxRating}';
    } catch (e) {
      infoMessages[platform] = '查询失败，请检查网络或用户名是否正确';
    } finally {
      isLoading[platform] = false;
      notifyListeners();
    }
  }

  Future<void> fetchRatingHistory(String platform) async {
    final username = controllers[platform]!.text;
    if (username.isEmpty) return;

    isLoading[platform] = true;
    notifyListeners();

    try {
      final history = await RatingUtils.getRatingHistory(
        platformName: platform,
        name: username,
      );
      ratingHistory[platform] = history;
    } catch (e) {
      infoMessages[platform] = '获取历史数据失败';
    } finally {
      isLoading[platform] = false;
      notifyListeners();
    }
  }

  void queryAll() {
    for (var platform in platforms) {
      queryRating(platform);
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
