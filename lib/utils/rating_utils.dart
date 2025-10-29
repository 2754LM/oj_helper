import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:oj_helper/services/rating_services.dart' show RatingService;

class RatingUtils {
  // Reuse service instance instead of creating new one each time
  static final RatingService _service = RatingService();
  
  static Future<Rating> getRating({platformName = '', name = ''}) async {
    switch (platformName) {
      case 'Codeforces':
        return await _service.getCodeforcesRating(name: name);
      case 'AtCoder':
        return await _service.getAtCoderRating(name: name);
      case '力扣':
        return (await _service.getLeetCodeRating(name: name)).last;
      case '牛客':
        return await _service.getNowcoderRating(name: name);
      case '洛谷':
        return await _service.getLuoguRating(name: name);
      default:
        throw Exception('没有此平台: $platformName');
    }
  }

  static Future<List<Rating>> getRatingList(
      {platformName = '', name = ''}) async {
    return (await _service.getLeetCodeRating(name: name));
  }
}
