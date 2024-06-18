import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oj_helper/models/contest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContestProvider extends ChangeNotifier {
  // 平台选择列表
  Map<String, bool> selectedPlatforms = {
    'Codeforces': true,
    'AtCoder': true,
    'Luogu': true,
    '蓝桥云课': true,
    '力扣': true,
    '牛客': true,
  };

  // 本地保存筛选条件
  Future<void> savePlatformSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final platformList = selectedPlatforms.entries
        .map((e) => '${e.key}:${e.value}')
        .toList(); // 需要类型转换
    await prefs.setStringList('selectedPlatforms', platformList);
  }

  // 加载筛选条件
  Future<void> loadPlatformSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final platformList =
        prefs.getStringList('selectedPlatforms') ?? []; // 不需要类型转换
    for (final entry in platformList) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        selectedPlatforms[parts[0]] = parts[1] == 'true';
      }
    }
    notifyListeners();
  }

  // 本地更新筛选条件
  void updatePlatformSelection(String platform, bool value) {
    selectedPlatforms[platform] = value;
    notifyListeners();
    savePlatformSelection(); // 保存数据到 SharedPreferences
  }

  // 近期比赛
  List<Contest> contests = [];
  // 更新比赛列表
  void setContests(List<Contest> newContests) {
    contests = newContests;
    notifyListeners(); // 通知监听器更新 UI
  }
}

class RatingProvider extends ChangeNotifier {}

class SolvedNumProvider extends ChangeNotifier {}
