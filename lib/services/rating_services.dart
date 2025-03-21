import 'package:dio/dio.dart';
import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:html/parser.dart' show parse;

class RatingService {
  final Dio dio = Dio();

  ///获取codeforces的curRating,maxRating
  Future<Rating> getCodeforcesRating({name = ''}) async {
    final url =
        "https://codeforces.com/api/user.info?handles=$name&checkHistoricHandles=false";
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      final rating = response.data['result'][0]['rating'];
      final maxRating = response.data['result'][0]['maxRating'];
      return Rating(name: name, curRating: rating, maxRating: maxRating);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取Atcoder的curRating,maxRating
  Future<Rating> getAtCoderRating({name = ''}) async {
    final url = "https://atcoder.jp/users/$name";
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      final rating = document
          .getElementsByClassName('dl-table mt-2')[0]
          .getElementsByTagName('tr');
      return Rating(
          name: name,
          curRating: int.parse(rating[1].getElementsByTagName('span')[0].text),
          maxRating: int.parse(rating[2].getElementsByTagName('span')[0].text));
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取力扣的curRating,(rating历史，todo)
  Future<List<Rating>> getLeetCodeRating({name = ''}) async {
    const url = 'https://leetcode.cn/graphql/noj-go/';
    final data = {
      "query": """
      query userContestRankingInfo(\$userSlug: String!) {
        userContestRanking(userSlug: \$userSlug) {
          rating
          globalRanking
          localRanking
          globalTotalParticipants
          localTotalParticipants
          topPercentage
        }
        userContestRankingHistory(userSlug: \$userSlug) {
          attended
          rating
          ranking
          contest{
            title
            startTime
          }
        }
      }
      """,
      "variables": {"userSlug": name},
      "operationName": "userContestRankingInfo"
    };
    Response response = await dio.post(url, data: data);
    if (response.statusCode == 200) {
      final ratingList = response.data['data']['userContestRankingHistory'];
      List<Rating> ratingHistory = [];
      int maxmRating = 0;
      for (var i in ratingList) {
        if (i['attended'] == false) continue;
        maxmRating =
            i['rating'] > maxmRating ? i['rating'].toInt() : maxmRating;
        ratingHistory.add(Rating(
            name: i['contest']['title'],
            curRating: i['rating'].toInt(),
            maxRating: maxmRating,
            ranking: i['ranking'],
            time: i['contest']['startTime']));
      }
      return ratingHistory;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取洛谷的curRating和maxRating（近百场）
  Future<Rating> getLuoguRating({name = ''}) async {
    final baseUrl = 'https://www.luogu.com.cn/api/user/search?keyword=$name';
    Options options = Options(
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    int userId;
    Response response = await dio.get(baseUrl, options: options);
    if (response.statusCode == 200) {
      userId = response.data['users'][0]['uid'];
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
    final url =
        'https://www.luogu.com.cn/api/rating/elo?user=$userId&page=1&limit=100';
    response = await dio.get(url, options: options);
    if (response.statusCode == 200) {
      final curRating = response.data['records']['result'][0]['rating'];
      int maxRating = 0;
      for (var i in response.data['records']['result']) {
        maxRating = i['rating'] > maxRating ? i['rating'] : maxRating;
      }
      return Rating(name: name, curRating: curRating, maxRating: maxRating);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取牛客的curRating，maxRating
  Future<Rating> getNowcoderRating({name = ''}) async {
    final url = 'https://ac.nowcoder.com/acm/contest/rating-history?uid=$name';
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      final rateHistory = response.data['data'];
      final curRating = rateHistory.last['rating'].toInt();
      //获取rateHisory的最大rating
      int maxRating = 0;
      for (var i in rateHistory) {
        maxRating =
            i['rating'].toInt() > maxRating ? i['rating'].toInt() : maxRating;
      }
      return Rating(name: name, curRating: curRating, maxRating: maxRating);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }
}

void main() async {
  RatingService rs = RatingService();
  var tmp = await rs.getLeetCodeRating(name: 'lu-ming-b');
  for (var i in tmp) {
    print("${i.name} ${i.curRating} ${i.maxRating} ${i.time} ${i.ranking}");
  }
}
