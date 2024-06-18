import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/contest.dart' show Contest;
import 'package:html/parser.dart' show parse;

class RecentContestServices {
  final _leetcodeUrl = "https://leetcode.cn/graphql";
  final _atcoderUrl = "https://atcoder.jp/contests/";
  final _codeforcesUrl =
      "https://mirror.codeforces.com/api/contest.list?gym=false";
  final _luoguUrl =
      "https://www.luogu.com.cn/contest/list?page=1&_contentOnly=1";
  final lanqiaoUrl =
      "https://www.lanqiao.cn/api/v2/contests/?sort=opentime&paginate=0&status=not_finished&game_type_code=2";
  final Dio dio = Dio();
  final int _nowSconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  int _queryEndSeconds = 7 * 24 * 60 * 60; //最晚时间

  ///修改查询最晚时间
  void setDay(int day) {
    _queryEndSeconds = day * 24 * 60 * 60;
  }

  ///判断比赛时间是否符合时间范围
  ///@return: 比赛过早返回2，比赛过晚返回1，其余返回0
  int _isIntime({int startTime = 0, int duration = 0}) {
    int endTime = startTime + duration;
    if (startTime > _queryEndSeconds + _nowSconds || duration >= 24 * 60 * 60) {
      return 1;
    } else if (endTime < _nowSconds) {
      return 2;
    }
    return 0;
  }

  ///获取力扣比赛
  Future<List<Contest>> getLeetcodeContests() async {
    final body = {
      "query": """
      {
        contestUpcomingContests {
          title
          startTime
          duration
        }
      }
      """
    };
    Response response = await dio.post(
      _leetcodeUrl,
      data: body,
    );
    if (response.statusCode == 200) {
      //解析数据
      final contestList = response.data["data"]["contestUpcomingContests"];
      List<Contest> contests = [];
      //力扣的比赛分部比较散乱，最近两场的代码是在一起的，所以只取前两场
      for (var i = 0; i < 2; i++) {
        //解析信息
        final name = contestList[i]['title'];
        final startTime = contestList[i]['startTime'];
        final duration = contestList[i]['duration'];
        //判断时间范围
        if (_isIntime(startTime: startTime, duration: duration) == 1) continue;
        if (_isIntime(startTime: startTime, duration: duration) == 2) break;
        //添加信息
        contests.add(Contest.fromJson(name, startTime, duration, "力扣"));
      }
      return contests;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取Codeforces比赛
  Future<List<Contest>> getCodeforcesContests() async {
    Response response = await dio.get(_codeforcesUrl);
    if (response.statusCode == 200) {
      List<Contest> contests = [];
      List<dynamic> contestList = response.data['result'];
      // 按开始时间倒序
      contestList.sort((a, b) => b['startTimeSeconds'] - a['startTimeSeconds']);
      for (var i = 0; i < contestList.length; i++) {
        int startTime = contestList[i]['startTimeSeconds'];
        int duration = contestList[i]['durationSeconds'];
        //判断时间范围
        if (_isIntime(startTime: startTime, duration: duration) == 1) continue;
        if (_isIntime(startTime: startTime, duration: duration) == 2) break;
        contests.add(Contest.fromJson(
            contestList[i]['name'], startTime, duration, 'Codeforces'));
      }
      return contests;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取牛客比赛
  Future<List<Contest>> getNowcoderContests() async {
    Response response =
        await dio.get("https://ac.nowcoder.com/acm/contest/vip-index");
    if (response.statusCode == 200) {
      List<Contest> contests = [];
      //解析html
      final document = parse(response.data);
      final contestList = document.getElementsByClassName("platform-item-main");
      for (var i = 0; i < contestList.length; i++) {
        final title = contestList[i].getElementsByTagName("a")[0].text;
        //time格式如下
        // 比赛时间：    2024-06-23 19:00
        //  至     2024-06-23 21:00
        //  (时长:2小时)
        final time =
            contestList[i].getElementsByClassName("match-time-icon")[0].text;
        // 查找所有匹配的时间，格式如2024-06-23 21:00
        final RegExp timeRegExp = RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}');
        final matches = timeRegExp.allMatches(time);
        final startTimeStr = matches.elementAt(0).group(0)!;
        final endTimeStr = matches.elementAt(1).group(0)!;
        //转换成unix时间戳
        final startTime =
            DateTime.parse(startTimeStr).millisecondsSinceEpoch ~/ 1000;
        final endTime =
            DateTime.parse(endTimeStr).millisecondsSinceEpoch ~/ 1000;
        final duration = endTime - startTime;
        if (_isIntime(startTime: startTime, duration: duration) == 1) continue;
        if (_isIntime(startTime: startTime, duration: duration) == 2) break;
        //添加元素
        contests.add(Contest.fromJson(title, 0, 0, '牛客'));
      }
      return contests;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取Atcoder比赛
  Future<List<Contest>> getAtcoderContests() async {
    Response response = await dio.get(_atcoderUrl);
    if (response.statusCode == 200) {
      List<Contest> contests = [];
      final document = parse(response.data);
      final upComingContests = document
          .getElementById('contest-table-upcoming')!
          .getElementsByTagName('tr');
      //atcoder这个信息第一行是表头，并且他已经按时间顺序正序了
      for (var i = 1; i < upComingContests.length; i++) {
        //解析信息
        final title = upComingContests[i].getElementsByTagName("a")[1].text;
        final time =
            upComingContests[i].getElementsByClassName("fixtime-full")[0].text;
        final duration = upComingContests[i]
            .getElementsByClassName("text-center")[1]
            .text
            .split(':');
        //转换为 Unix 时间戳
        //原格式time：2024-06-29 21:00:00+0900
        //原格式duration：02:00
        DateFormat starttimeFormat = DateFormat('yyyy-MM-dd HH:mm:ssZ');
        final startTime =
            starttimeFormat.parse(time).millisecondsSinceEpoch ~/ 1000;
        int durationTime =
            int.parse(duration[0]) * 3600 + int.parse(duration[1]) * 60;
        //判断时间范围
        if (_isIntime(startTime: startTime, duration: durationTime) == 1) {
          continue;
        }
        if (_isIntime(startTime: startTime, duration: durationTime) == 2) break;
        //添加元素
        contests
            .add(Contest.fromJson(title, startTime, durationTime, 'AtCoder'));
      }
      return contests;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取洛谷比赛
  Future<List<Contest>> getLuoguContests({bool isRated = true}) async {
    Response response = await dio.get(_luoguUrl);
    if (response.statusCode == 200) {
      List<Contest> contests = [];
      final contestList = response.data['currentData']['contests']['result'];
      for (var i = 0; i < contestList.length; i++) {
        if (contestList[i]['rated'] == false && isRated == true) continue;
        final name = contestList[i]['name'];
        final startTime = contestList[i]['startTime'];
        final duration = contestList[i]['endTime'] - startTime;
        //判断时间范围
        if (_isIntime(startTime: startTime, duration: duration) == 1) continue;
        if (_isIntime(startTime: startTime, duration: duration) == 2) break;
        //添加元素
        contests.add(Contest.fromJson(name, startTime, duration, '洛谷'));
      }
      return contests;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取蓝桥杯比赛
  Future<List<Contest>> getLanqiaoContests() async {
    Response response = await dio.get(lanqiaoUrl);
    if (response.statusCode == 200) {
      List<Contest> contests = [];
      for (var i = 0; i < response.data.length; i++) {
        final name = response.data[i]['name'];
        //time格式如2024-06-29T19:00:00+08:00
        final time = response.data[i]['open_at'];
        DateFormat starttimeFormat = DateFormat('yyyy-MM-ddTHH:mm:ssZ');
        final startTime =
            starttimeFormat.parse(time).millisecondsSinceEpoch ~/ 1000;
        final endTime = starttimeFormat
                .parse(response.data[i]['end_at'])
                .millisecondsSinceEpoch ~/
            1000;
        final duration = endTime - startTime;
        //判断时间范围
        if (_isIntime(startTime: startTime, duration: duration) == 1) continue;
        if (_isIntime(startTime: startTime, duration: duration) == 2) break;
        //添加元素
        contests.add(Contest.fromJson(name, startTime, duration, '蓝桥云课'));
      }
      return contests;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }
}

void main() async {
  final recentContest = RecentContestServices();
  final atc = await recentContest.getNowcoderContests();
  for (var contest in atc) {
    print('${contest.name} ${contest.startTime} ${contest.duration}');
  }
}
