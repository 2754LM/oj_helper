import 'package:flutter/material.dart';
import 'package:oj_helper/models/contest.dart';

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
  // 近期比赛
  List<Contest> contests = [];
  // 更新比赛列表
  void setContests(List<Contest> newContests) {
    contests = newContests;
    notifyListeners(); // 通知监听器更新 UI
  }

  // 更新平台选择
  void updatePlatformSelection(String platform, bool value) {
    selectedPlatforms[platform] = value;
    notifyListeners();
  }
}

class RatingProvider extends ChangeNotifier {}

class SolvedNumProvider extends ChangeNotifier {}
