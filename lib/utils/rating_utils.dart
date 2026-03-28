import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:oj_helper/services/rating_services.dart' show RatingService;

class RatingUtils {
  static final RatingService _rs = RatingService();

  static Future<Rating> getRating(
      {String platformName = '', String name = ''}) async {
    switch (platformName) {
      case 'Codeforces':
        return await _rs.getCodeforcesRating(name: name);
      case 'AtCoder':
        return await _rs.getAtCoderRating(name: name);
      case '力扣':
        final ratings = await _rs.getLeetCodeRating(name: name);
        if (ratings.isEmpty) throw Exception('No rating data found');
        return ratings.last;
      case '牛客':
        return await _rs.getNowcoderRating(name: name);
      case '洛谷':
        return await _rs.getLuoguRating(name: name);
      case 'CodeChef':
        return await _rs.getCodeChefRating(name: name);
      default:
        throw Exception('没有此平台: $platformName');
    }
  }

  static Future<List<Rating>> getRatingHistory(
      {String platformName = '', String name = ''}) async {
    switch (platformName) {
      case 'Codeforces':
        return await _rs.getCodeforcesRatingHistory(name: name);
      case 'AtCoder':
        return await _rs.getAtCoderRatingHistory(name: name);
      case '力扣':
        return await _rs.getLeetCodeRating(name: name);
      case '洛谷':
        return await _rs.getLuoguRatingHistory(name: name);
      case '牛客':
        return await _rs.getNowcoderRatingHistory(name: name);
      case 'CodeChef':
        return await _rs.getCodeChefRatingHistory(name: name);
      default:
        return [];
    }
  }

  static Future<List<Rating>> getRatingList(
      {String platformName = '', String name = ''}) async {
    return await _rs.getLeetCodeRating(name: name);
  }
}
