import 'package:oj_helper/services/recent_contest_services.dart';
import 'package:oj_helper/models/contest.dart' show Contest;

class ContestUtils {
  static Future<List<Contest>> getRecentContests({int day = 7}) async {
    RecentContestServices rC = RecentContestServices();
    rC.setDay(day);
    List<Contest> recentContestsList = [];
    //获取最近的比赛
    List<Contest> leetcodeContests = await rC.getLeetcodeContests();
    List<Contest> codeforcesContests = await rC.getCodeforcesContests();
    List<Contest> nowcoderContests = await rC.getNowcoderContests();
    List<Contest> atcoderContests = await rC.getAtcoderContests();
    List<Contest> luoguContests = await rC.getLuoguContests();
    List<Contest> lanqiaoContests = await rC.getLanqiaoContests();
    //合并所有比赛
    recentContestsList.addAll(leetcodeContests);
    recentContestsList.addAll(codeforcesContests);
    recentContestsList.addAll(nowcoderContests);
    recentContestsList.addAll(atcoderContests);
    recentContestsList.addAll(luoguContests);
    recentContestsList.addAll(lanqiaoContests);
    // 开始时间排序
    recentContestsList.sort((a, b) => a.startTime.compareTo(b.startTime));
    return recentContestsList;
  }
}

void main() {
  ContestUtils.getRecentContests().then((value) {
    for (var contest in value) {
      print(
          '${contest.name} ${contest.startTime} ${contest.endTime} ${contest.duration} ${contest.platform}');
    }
  });
}
