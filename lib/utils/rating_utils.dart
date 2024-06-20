import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:oj_helper/services/rating_services.dart' show RatingService;

class RatingtUtils {
  static Future<Rating> getRating({platformName = '', name = ''}) async {
    RatingService rs = RatingService();
    switch (platformName) {
      case 'Codeforces':
        return await rs.getCodeforcesRating(name: name);
      case 'AtCoder':
        return await rs.getAtCoderRating(name: name);
      case '力扣':
        return await rs.getLeetCodeRating(name: name);
      case '牛客':
        return await rs.getNowcoderRating(name: name);
      case '洛谷':
        return await rs.getLuoguRating(name: name);
      default:
        throw Exception('没有此平台: $platformName');
    }
  }
}
