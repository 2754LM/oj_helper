import 'package:oj_helper/models/solved_num.dart' show SolvedNum;
import 'package:oj_helper/services/solved_num_services.dart'
    show SolvedNumServices;

class SolvedUtils {
  static final SolvedNumServices _rs = SolvedNumServices();

  static Future<SolvedNum> getSolvedNum(
      {String platformName = '', String name = ''}) async {
    switch (platformName) {
      case 'Codeforces':
        return await _rs.getCodeforcesSolvedNum(name: name);
      case 'AtCoder':
        return await _rs.getAtCoderRating(name: name);
      case '力扣':
        return await _rs.getLeetCodeRating(name: name);
      case '洛谷':
        return await _rs.getLuoguRating(name: name);
      case 'VJudge':
        return await _rs.getVJudgeRating(name: name);
      case 'hdu':
        return await _rs.getHduRating(name: name);
      case 'poj':
        return await _rs.getPOJRating(name: name);
      case '牛客':
        return await _rs.getNowcoderRating(name: name);
      case 'QOJ':
        return await _rs.getQOJRating(name: name);
      default:
        throw Exception('Platform not supported: $platformName');
    }
  }
}
