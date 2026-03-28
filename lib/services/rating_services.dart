import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:html/parser.dart' show parse;
import 'package:oj_helper/services/api_service.dart';

class RatingService {
  final Dio dio = ApiService.dio;

  ///获取codeforces的curRating,maxRating
  Future<Rating> getCodeforcesRating({String name = ''}) async {
    final url =
        "https://codeforces.com/api/user.info?handles=$name&checkHistoricHandles=false";
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      final result = data['result'][0];
      return Rating(
        name: name,
        curRating: result['rating'],
        maxRating: result['maxRating'],
      );
    });
  }

  ///获取Atcoder的curRating,maxRating
  Future<Rating> getAtCoderRating({String name = ''}) async {
    final url = "https://atcoder.jp/users/$name";
    return ApiService.safeRequest<String>(() => dio.get(url)).then((data) {
      final document = parse(data);
      final rows = document
          .getElementsByClassName('dl-table mt-2')[0]
          .getElementsByTagName('tr');
      return Rating(
        name: name,
        curRating: int.parse(rows[1].getElementsByTagName('span')[0].text),
        maxRating: int.parse(rows[2].getElementsByTagName('span')[0].text),
      );
    });
  }

  ///获取力扣的curRating,(rating历史，todo)
  Future<List<Rating>> getLeetCodeRating({String name = ''}) async {
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
    return ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.post(url, data: data)).then((res) {
      final ratingList = res['data']['userContestRankingHistory'];
      List<Rating> ratingHistory = [];
      int maxRating = 0;
      for (var i in ratingList) {
        if (i['attended'] == false) continue;
        final currentRating = i['rating'].toInt();
        maxRating = currentRating > maxRating ? currentRating : maxRating;
        ratingHistory.add(Rating(
          name: i['contest']['title'],
          curRating: currentRating,
          maxRating: maxRating,
          ranking: i['ranking'],
          time: i['contest']['startTime'],
        ));
      }
      return ratingHistory;
    });
  }

  ///获取洛谷的curRating和maxRating（近百场）
  Future<Rating> getLuoguRating({String name = ''}) async {
    final searchUrl = 'https://www.luogu.com.cn/api/user/search?keyword=$name';
    final options = Options(headers: {'X-Requested-With': 'XMLHttpRequest'});

    final searchData = await ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.get(searchUrl, options: options));
    final userId = searchData['users'][0]['uid'];

    final ratingUrl =
        'https://www.luogu.com.cn/api/rating/elo?user=$userId&page=1&limit=100';
    return ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.get(ratingUrl, options: options)).then((data) {
      final records = data['records']['result'];
      final curRating = records[0]['rating'];
      int maxRating = 0;
      for (var record in records) {
        maxRating = record['rating'] > maxRating ? record['rating'] : maxRating;
      }
      return Rating(name: name, curRating: curRating, maxRating: maxRating);
    });
  }

  ///获取codeforces的Rating历史
  Future<List<Rating>> getCodeforcesRatingHistory({String name = ''}) async {
    final url = "https://codeforces.com/api/user.rating?handle=$name";
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      final result = data['result'] as List;
      List<Rating> history = [];
      int maxRating = 0;
      for (var entry in result) {
        final currentRating = entry['newRating'] as int;
        maxRating = currentRating > maxRating ? currentRating : maxRating;
        history.add(Rating(
          name: entry['contestName'],
          curRating: currentRating,
          maxRating: maxRating,
          ranking: entry['rank'],
          time: entry['ratingUpdateTimeSeconds'],
        ));
      }
      return history;
    });
  }

  ///获取Atcoder的Rating历史
  Future<List<Rating>> getAtCoderRatingHistory({String name = ''}) async {
    final url = "https://atcoder.jp/users/$name/history/json";
    return ApiService.safeRequest<List<dynamic>>(() => dio.get(url))
        .then((data) {
      List<Rating> history = [];
      int maxRating = 0;
      for (var entry in data) {
        if (entry['IsRated'] == false) continue;
        final currentRating = entry['NewRating'] as int;
        maxRating = currentRating > maxRating ? currentRating : maxRating;
        // AtCoder history API doesn't provide contest name directly in this JSON,
        // but it provides ContestScreenName.
        history.add(Rating(
          name: entry['ContestName'] ?? entry['ContestScreenName'],
          curRating: currentRating,
          maxRating: maxRating,
          ranking: entry['Place'],
          time: DateTime.parse(entry['EndTime']).millisecondsSinceEpoch ~/ 1000,
        ));
      }
      return history;
    });
  }

  ///获取洛谷的Rating历史
  Future<List<Rating>> getLuoguRatingHistory({String name = ''}) async {
    final searchUrl = 'https://www.luogu.com.cn/api/user/search?keyword=$name';
    final options = Options(headers: {'X-Requested-With': 'XMLHttpRequest'});

    final searchData = await ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.get(searchUrl, options: options));
    final userId = searchData['users'][0]['uid'];

    final ratingUrl =
        'https://www.luogu.com.cn/api/rating/elo?user=$userId&page=1&limit=100';
    return ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.get(ratingUrl, options: options)).then((data) {
      final records = (data['records']['result'] as List).reversed.toList();
      List<Rating> history = [];
      int maxRating = 0;
      for (var record in records) {
        final currentRating = record['rating'] as int;
        maxRating = currentRating > maxRating ? currentRating : maxRating;
        history.add(Rating(
          name: record['contest']['name'] ?? '洛谷比赛',
          curRating: currentRating,
          maxRating: maxRating,
          time: record['time'],
        ));
      }
      return history;
    });
  }

  ///获取牛客的Rating历史
  Future<List<Rating>> getNowcoderRatingHistory({String name = ''}) async {
    final url = 'https://ac.nowcoder.com/acm/contest/rating-history?uid=$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      final rateHistory = data['data'] as List;
      List<Rating> history = [];
      int maxRating = 0;
      for (var record in rateHistory) {
        final currentRating = record['rating'].toInt();
        maxRating = currentRating > maxRating ? currentRating : maxRating;
        history.add(Rating(
          name: record['contestName'] ?? '牛客比赛',
          curRating: currentRating,
          maxRating: maxRating,
          ranking: record['rank'],
          time: record['ratingChangeDate'] ~/ 1000,
        ));
      }
      return history;
    });
  }

  ///获取牛客的curRating，maxRating
  Future<Rating> getNowcoderRating({String name = ''}) async {
    final history = await getNowcoderRatingHistory(name: name);
    return history.last;
  }

  ///获取CodeChef的Rating历史
  Future<List<Rating>> getCodeChefRatingHistory({String name = ''}) async {
    // CodeChef doesn't have a simple JSON API for history.
    // We might need to scrape it or use a third-party API if available.
    // For now, let's just return a list with the current rating as a placeholder
    // or try to find where the history data is.
    // Actually, CodeChef's history is often in a script tag as a JSON-like string.
    final url = "https://www.codechef.com/users/$name";
    return ApiService.safeRequest<String>(() => dio.get(url)).then((data) {
      final document = parse(data);
      // History data is often in a JS variable named `all_rating`
      final scripts = document.getElementsByTagName('script');
      for (var script in scripts) {
        if (script.text.contains('var all_rating =')) {
          final start = script.text.indexOf('var all_rating =') +
              'var all_rating ='.length;
          final end = script.text.indexOf(';', start);
          final jsonStr = script.text.substring(start, end).trim();
          final historyData = jsonDecode(jsonStr) as List;
          List<Rating> history = [];
          int maxRating = 0;
          for (var entry in historyData) {
            final currentRating = int.parse(entry['rating']);
            maxRating = currentRating > maxRating ? currentRating : maxRating;
            history.add(Rating(
              name: entry['name'],
              curRating: currentRating,
              maxRating: maxRating,
              ranking: int.parse(entry['rank']),
              time: DateTime.parse(
                          '${entry['getyear']}-${entry['getmonth']}-${entry['getday']}')
                      .millisecondsSinceEpoch ~/
                  1000,
            ));
          }
          return history;
        }
      }
      return [];
    });
  }

  ///获取CodeChef的curRating，maxRating
  Future<Rating> getCodeChefRating({String name = ''}) async {
    final history = await getCodeChefRatingHistory(name: name);
    if (history.isEmpty) {
      throw Exception('Failed to fetch CodeChef rating');
    }
    return history.last;
  }
}
