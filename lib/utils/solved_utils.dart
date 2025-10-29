import 'package:oj_helper/models/solved_num.dart' show SolvedNum;
import 'package:oj_helper/services/solved_num_services.dart'
    show SolvedNumServices;

class SolvedUtils {
  // Reuse service instance instead of creating new one each time
  static final SolvedNumServices _service = SolvedNumServices();
  
  static Future<SolvedNum> getSolvedNum({platformName = '', name = ''}) async {
    switch (platformName) {
      case 'Codeforces':
        return await _service.getCodeforcesSolvedNum(name: name);
      case 'AtCoder':
        return await _service.getAtCoderRating(name: name);
      case '力扣':
        return await _service.getLeetCodeRating(name: name);
      case '洛谷':
        return await _service.getLuoguRating(name: name);
      case 'VJudge':
        return await _service.getVJudgeRating(name: name);
      case 'hdu':
        return await _service.getHduRating(name: name);
      case 'poj':
        return await _service.getPOJRating(name: name);
      case '牛客':
        return await _service.getNowcoderRating(name: name);
      case '蓝桥云课':
        return await _service.getLanqiaoContests(name: name);
      default:
        throw Exception('Platform not supported');
    }
  }
}
