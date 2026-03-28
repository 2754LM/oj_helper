import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:oj_helper/models/solved_num.dart' show SolvedNum;
import 'package:oj_helper/services/api_service.dart';

class SolvedNumServices {
  final Dio dio = ApiService.dio;

  /// 获取codeforces的解题数
  Future<SolvedNum> getCodeforcesSolvedNum({String name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/codeforces/$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      return SolvedNum(name: name, solvedNum: data['data']['solved']);
    });
  }

  ///获取力扣的解题数
  Future<SolvedNum> getLeetCodeRating({String name = ''}) async {
    const url = 'https://leetcode.cn/graphql/';
    final data = {
      "query": """
      query userProfileUserQuestionProgressV2(\$userSlug: String!) {
        userProfileUserQuestionProgressV2(userSlug: \$userSlug) {
          numAcceptedQuestions{
            count
            difficulty
          }
        }
      }
      """,
      "variables": {"userSlug": name},
      "operationName": "userProfileUserQuestionProgressV2"
    };
    return ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.post(url, data: data)).then((res) {
      final info = res['data']['userProfileUserQuestionProgressV2']
          ['numAcceptedQuestions'];
      final totalSolvedNum =
          info.fold<int>(0, (sum, item) => sum + (item['count'] as int));
      return SolvedNum(name: name, solvedNum: totalSolvedNum);
    });
  }

  ///获取vjudge的解题数
  Future<SolvedNum> getVJudgeRating({String name = ''}) async {
    final url = 'https://vjudge.net/user/solveDetail/$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      final acRecords = data['acRecords'] as Map<String, dynamic>;
      int total = 0;
      acRecords.forEach((key, value) {
        total += (value as List).length;
      });
      return SolvedNum(name: name, solvedNum: total);
    });
  }

  ///获取洛谷的解题数
  Future<SolvedNum> getLuoguRating({String name = ''}) async {
    final searchUrl = 'https://www.luogu.com.cn/api/user/search?keyword=$name';
    final options = Options(headers: {'X-Requested-With': 'XMLHttpRequest'});

    final searchData = await ApiService.safeRequest<Map<String, dynamic>>(
        () => dio.get(searchUrl, options: options));
    if (searchData['users'] == null || searchData['users'].isEmpty) {
      throw Exception('未找到用户: $name');
    }
    final userId = searchData['users'][0]['uid'];

    final userUrl = 'https://www.luogu.com.cn/user/$userId';
    // 洛谷的页面数据通常包含在 _feInjection 中，或者直接在 HTML 里能搜到 passedProblemCount
    return ApiService.safeRequest<String>(
        () => dio.get(userUrl, options: options)).then((res) {
      final match = RegExp(r'"passedProblemCount"\s*:\s*(\d+)').firstMatch(res);
      if (match != null) {
        return SolvedNum(name: name, solvedNum: int.parse(match.group(1)!));
      } else {
        // 备选方案：尝试从 _feInjection 解析
        try {
          if (res.contains('window._feInjection =')) {
            final start = res.indexOf('window._feInjection =') +
                'window._feInjection ='.length;
            final end = res.indexOf(';', start);
            final jsonStr = res.substring(start, end).trim();
            final data = json.decode(jsonStr);
            final solved = data['currentData']['user']['passedProblemCount'];
            if (solved != null) {
              return SolvedNum(name: name, solvedNum: solved);
            }
          }
        } catch (_) {}
        throw Exception('解析洛谷通过题目数失败');
      }
    });
  }

  ///获取atcoder的解题数
  Future<SolvedNum> getAtCoderRating({String name = ''}) async {
    final url =
        'https://kenkoooo.com/atcoder/atcoder-api/v3/user/ac_rank?user=$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      return SolvedNum(name: name, solvedNum: data['count']);
    });
  }

  ///获取hdu的解题数
  Future<SolvedNum> getHduRating({String name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/hdu/$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      return SolvedNum(name: name, solvedNum: data['data']['solved']);
    });
  }

  ///获取poj的解题数
  Future<SolvedNum> getPOJRating({String name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/poj/$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      return SolvedNum(name: name, solvedNum: data['data']['solved']);
    });
  }

  ///获取牛客网的解题数
  Future<SolvedNum> getNowcoderRating({String name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/nowcoder/$name';
    return ApiService.safeRequest<Map<String, dynamic>>(() => dio.get(url))
        .then((data) {
      return SolvedNum(name: name, solvedNum: data['data']['solved']);
    });
  }

  ///获取QOJ解题数
  Future<SolvedNum> getQOJRating({String name = ''}) async {
    final url = 'https://qoj.ac/user/profile/$name';
    return ApiService.safeRequest<String>(() => dio.get(url)).then((data) {
      final acceptedPattern = RegExp(r'Accepted problems：(\d+) problems');
      final acceptedMatch = acceptedPattern.firstMatch(data);
      if (acceptedMatch == null) {
        throw Exception('Failed to parse accepted problems count');
      }
      return SolvedNum(
          name: name, solvedNum: int.parse(acceptedMatch.group(1)!));
    });
  }
}
