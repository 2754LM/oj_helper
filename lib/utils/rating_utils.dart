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
      case 'LeetCode':
        return await rs.getLeetCodeRating(name: name);
      case 'Nowcoder':
        return await rs.getNowcoderRating(name: name);
      case 'Luogu':
        return await rs.getLuoguRating(name: name);
      default:
        throw Exception('没有此平台: $platformName');
    }
  }
}
