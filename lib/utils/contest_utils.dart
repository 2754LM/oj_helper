import 'dart:core';
import 'package:intl/intl.dart';
import 'package:oj_helper/provider.dart';
import 'package:oj_helper/services/recent_contest_services.dart';
import 'package:oj_helper/models/contest.dart' show Contest;

class ContestUtils {
  static Future<List<List<Contest>>> getRecentContests(
      {int day = 7, ContestProvider? contestProvider}) async {
    RecentContestServices rC = RecentContestServices();
    rC.setDay(day);
    List<Contest> recentContestsList = [];
    Map<String, bool>? selectPlatforms = contestProvider?.selectedPlatforms;
    if (selectPlatforms?['力扣'] == true) {
      recentContestsList.addAll(await rC.getLeetcodeContests());
    }
    if (selectPlatforms?['Codeforces'] == true) {
      recentContestsList.addAll(await rC.getCodeforcesContests());
    }
    if (selectPlatforms?['牛客'] == true) {
      recentContestsList.addAll(await rC.getNowcoderContests());
    }
    if (selectPlatforms?['AtCoder'] == true) {
      recentContestsList.addAll(await rC.getAtCoderContests());
    }
    if (selectPlatforms?['Luogu'] == true) {
      recentContestsList.addAll(await rC.getLuoguContests());
    }
    if (selectPlatforms?['蓝桥云课'] == true) {
      recentContestsList.addAll(await rC.getLanqiaoContests());
    }
    // 开始时间排序
    recentContestsList.sort((a, b) => a.startTime.compareTo(b.startTime));
    //按照开始的日期分组
    List<List<Contest>> timeContests = List.generate(7, (index) => <Contest>[]);
    for (Contest contest in recentContestsList) {
      int dif = (contest.startDateTimeDay!.difference(nowTime).inDays).abs();
      if (dif >= 7) continue;
      try {
        timeContests[dif].add(contest);
      } catch (e) {
        rethrow;
      }
    }
    return timeContests;
  }

  static final DateFormat formatter = DateFormat('M月d日');
  static final DateTime nowTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  static final Map<int, String> weekdayMap = {
    1: '一',
    2: '二',
    3: '三',
    4: '四',
    5: '五',
    6: '六',
    0: '日',
  };
  //获取日期对应名称
  static String getDayName(int index) {
    if (index < 0 || index > 6) return '';
    if (index == 0) {
      return '今日   ${formatter.format(nowTime.add(Duration(days: index)))} 周${weekdayMap[nowTime.weekday % 7]}';
    } else if (index == 1) {
      return '明日   ${formatter.format(nowTime.add(Duration(days: index)))} 周${weekdayMap[(nowTime.weekday + 1) % 7]}';
    } else if (index == 2) {
      return '后日   ${formatter.format(nowTime.add(Duration(days: index)))} 周${weekdayMap[(nowTime.weekday + 2) % 7]}';
    } else {
      return '${formatter.format(nowTime.add(Duration(days: index)))} 周${weekdayMap[(nowTime.weekday + index) % 7]}';
    }
  }
}
