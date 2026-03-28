import 'package:flutter/material.dart';
import 'package:oj_helper/models/contest.dart';
import 'package:oj_helper/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContestProvider extends ChangeNotifier {
  // 平台选择列表
  Map<String, bool> selectedPlatforms = {
    'Codeforces': true,
    'AtCoder': true,
    '洛谷': true,
    '蓝桥云课': true,
    '力扣': true,
    '牛客': true,
  };

  // 提醒提前时间 (分钟)
  int notificationLeadTime = 15;

  // 本地保存筛选条件
  Future<void> savePlatformSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final platformList = selectedPlatforms.entries
        .map((e) => '${e.key}:${e.value}')
        .toList(); // 需要类型转换
    await prefs.setStringList('selectedPlatforms', platformList);
  }

  // 加载筛选条件和设置
  Future<void> loadPlatformSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final platformList = prefs.getStringList('selectedPlatforms') ?? [];
    for (final entry in platformList) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        selectedPlatforms[parts[0]] = parts[1] == 'true';
      }
    }
    notificationLeadTime = prefs.getInt('notificationLeadTime') ?? 15;
    notifyListeners();
  }

  // 更新提醒提前时间
  Future<void> updateNotificationLeadTime(int minutes) async {
    notificationLeadTime = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationLeadTime', minutes);

    // Reschedule all existing notifications with new lead time
    // This is a bit complex as we don't have the full contest objects here
    // For now, let's just notify and new favorites will use the new time.
    // In a production app, you might want to store favorited Contest objects.
    notifyListeners();
  }

  // 本地更新筛选条件
  void updatePlatformSelection(String platform, bool value) {
    selectedPlatforms[platform] = value;
    notifyListeners();
    savePlatformSelection(); // 保存数据到 SharedPreferences
  }

  // 近期比赛列表
  List<List<Contest>> timeContests = [];
  // 更新比赛列表
  void setContests(List<List<Contest>> nowContests) {
    timeContests = nowContests;
    notifyListeners(); // 通知监听器更新 UI
  }

  //显示有无比赛日
  bool showEmptyDay = true;
  void toggleShowEmptyDay(bool value) {
    showEmptyDay = value;
    notifyListeners();
  }

  // 加载状态
  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // 收藏状态
  final Set<String> favoriteContestNames = {};

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteListStr = prefs.getString('favourite_contests') ?? '';
    if (favoriteListStr.isNotEmpty) {
      favoriteContestNames.addAll(favoriteListStr.split(','));
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Contest contest) async {
    final prefs = await SharedPreferences.getInstance();
    final int notificationId = contest.name.hashCode.abs();

    if (favoriteContestNames.contains(contest.name)) {
      favoriteContestNames.remove(contest.name);
      await prefs.remove(contest.name);
      // Cancel notification
      await NotificationService.cancelNotification(notificationId);
    } else {
      favoriteContestNames.add(contest.name);
      final infor =
          '${contest.name},${contest.startTimeSeconds},${contest.durationSeconds},${contest.platform},${contest.link}';
      await prefs.setString(contest.name, infor);

      // Schedule notification
      final DateTime contestStartTime =
          DateTime.fromMillisecondsSinceEpoch(contest.startTimeSeconds * 1000);
      final DateTime notificationTime =
          contestStartTime.subtract(Duration(minutes: notificationLeadTime));

      await NotificationService.scheduleNotification(
        id: notificationId,
        title: '比赛提醒',
        body: '您的收藏比赛【${contest.name}】将在$notificationLeadTime分钟后开始！',
        scheduledDate: notificationTime,
      );
    }
    await prefs.setString('favourite_contests', favoriteContestNames.join(','));
    notifyListeners();
  }

  bool isFavorite(String contestName) {
    return favoriteContestNames.contains(contestName);
  }
}
