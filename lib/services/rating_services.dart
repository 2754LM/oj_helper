import 'package:dio/dio.dart';
import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:html/parser.dart' show parse;

class RatingService {
  final Dio dio = Dio();

  ///获取codeforces的curRating,maxRating
  Future<Rating> getCodeforcesRating({name = ''}) async {
    final url =
        "https://mirror.codeforces.com/api/user.info?handles=$name&checkHistoricHandles=false";
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
  Future<Rating> getAtcoderRating({name = ''}) async {
    final url = "https://atcoder.jp/users/$name";
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      final infor = document.getElementsByClassName("user-gray");
      final curRating = int.parse(infor[1].text);
      final maxRating = int.parse(infor[2].text);
      return Rating(name: name, curRating: curRating, maxRating: maxRating);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取力扣的curRating
  Future<Rating> getLeetcodeRating({name = ''}) async {
    final url = 'https://leetcode.cn/graphql/noj-go/';
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
      }
      """,
      "variables": {"userSlug": name},
      "operationName": "userContestRankingInfo"
    };

    Response response = await dio.post(url, data: data);
    if (response.statusCode == 200) {
      final rating = response.data['data']['userContestRanking']['rating'];
      return Rating(name: name, curRating: rating.toInt());
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取洛谷的curRating和maxRating（近百场）
  Future<Rating> getLuoguRating({name = ''}) async {
    final url =
        'https://www.luogu.com.cn/api/rating/elo?user=$name&page=1&limit=100';
    Response response = await dio.get(url);
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
  Rating tmp = await rs.getLuoguRating(name: '610557');
  print('${tmp.name}的当前rating为${tmp.curRating}，最大rating为${tmp.maxRating}');
}
