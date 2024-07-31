import 'package:oj_helper/models/solved_num.dart' show SolvedNum;
import 'package:oj_helper/services/solved_num_services.dart'
    show SolvedNumServices;

class SolvedUtils {
  static Future<SolvedNum> getSolvedNum({platformName = '', name = ''}) async {
    SolvedNumServices rs = SolvedNumServices();
    switch (platformName) {
      case 'Codeforces':
        return await rs.getCodeforcesSolvedNum(name: name);
      case 'AtCoder':
        return await rs.getAtCoderRating(name: name);
      case '力扣':
        return await rs.getLeetCodeRating(name: name);
      case '洛谷':
        return await rs.getLuoguRating(name: name);
      case 'VJudge':
        return await rs.getVJudgeRating(name: name);
      case 'hdu':
        return await rs.getHduRating(name: name);
      case 'poj':
        return await rs.getPOJRating(name: name);
      case '牛客':
        return await rs.getNowcoderRating(name: name);
      case '蓝桥云课':
        return await rs.getLanqiaoContests(name: name);
      default:
        throw Exception('Platform not supported');
    }
  }
}
