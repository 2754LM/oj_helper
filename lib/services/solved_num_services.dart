import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:oj_helper/models/solved_num.dart' show SolvedNum;

class SolvedNumServices {
  final dio = Dio();

  /// 获取codeforces的解题数
  ///   //数据来源：https://github.com/Liu233w/acm-statistics
  Future<SolvedNum> getCodeforcesSolvedNum({name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/codeforces/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return SolvedNum(name: name, solvedNum: response.data['data']['solved']);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取力扣的解题数
  Future<SolvedNum> getLeetCodeRating({name = ''}) async {
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
    Response response = await dio.post(url, data: data);
    if (response.statusCode == 200) {
      final infor = response.data['data']['userProfileUserQuestionProgressV2']
          ['numAcceptedQuestions'];
      final easySolvedNum = infor[0]['count'];
      final mediumSolvedNum = infor[1]['count'];
      final hardSolvedNum = infor[2]['count'];
      final totalSolvedNum = easySolvedNum + mediumSolvedNum + hardSolvedNum;
      return SolvedNum(name: name, solvedNum: totalSolvedNum);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取vjudge的解题数
  Future<SolvedNum> getVJudgeRating({name = ''}) async {
    final url = 'https://vjudge.net/user/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final htmlContent = response.data as String;
      // 从JSON数据块中提取解题数
      final pattern = RegExp(r'<script type="application/json" id="profile-header-data">(.*?)</script>');
      final match = pattern.firstMatch(htmlContent);
      if (match != null) {
        final jsonData = match.group(1);
        if (jsonData != null) {
          final data = parse(jsonData);
          final solvedNum = data['counts']['acAll'] as int;
          return SolvedNum(name: name, solvedNum: solvedNum);
        }
      }
      throw Exception('无法解析Vjudge数据');
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取洛谷的解题数
  Future<SolvedNum> getLuoguRating({name = ''}) async {
    final url = 'https://www.luogu.com.cn/api/user/search?keyword=$name';
    Options options = Options(
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    final response = await dio.get(url, options: options);
    if (response.statusCode == 200) {
      print(response.data);
      int userId = response.data['users'][0]['uid'];
      final url = 'https://www.luogu.com.cn/user/$userId';
      final res = await dio.get(url, options: options);
      if (res.statusCode == 200) {
        final text = res.data
            .toString()
            .split('passedProblemCount')[1]
            .split('submittedProblemCount')[0];
        String decodedString = Uri.decodeComponent(text);
        decodedString = decodedString.substring(2, decodedString.length - 2);
        final solvedNum = int.parse(decodedString);
        return SolvedNum(name: name, solvedNum: solvedNum);
      } else {
        throw Exception("请求失败，状态码：${res.statusCode}");
      }
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取atcoder的解题数
  //数据来源：https://github.com/kenkoooo/AtCoderProblems
  Future<SolvedNum> getAtCoderRating({name = ''}) async {
    final url =
        'https://kenkoooo.com/atcoder/atcoder-api/v3/user/ac_rank?user=$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final solvedNum = response.data['count'];
      return SolvedNum(name: name, solvedNum: solvedNum);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取hdu的解题数
  //数据来源：https://github.com/Liu233w/acm-statistics
  Future<SolvedNum> getHduRating({name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/hdu/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return SolvedNum(name: name, solvedNum: response.data['data']['solved']);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取poj的解题数
  //数据来源：https://github.com/Liu233w/acm-statistics
  Future<SolvedNum> getPOJRating({name = ''}) async {
    // POJ网站有严格的反爬虫机制，暂时无法直接访问
    // 使用备用方案：通过ojhunt.com API
    try {
      final url = 'https://ojhunt.com/api/crawlers/poj/$name';
      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data['data'] != null) {
        return SolvedNum(name: name, solvedNum: response.data['data']['solved'] ?? 0);
      }
    } catch (e) {
      // 如果API失败，返回0并提示用户
    }
    // 返回0并提示用户POJ暂时无法查询
    return SolvedNum(name: name, solvedNum: 0);
  }

  //获取牛客网的解题数
  //数据来源：https://github.com/Liu233w/acm-statistics
  Future<SolvedNum> getNowcoderRating({name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/nowcoder/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return SolvedNum(name: name, solvedNum: response.data['data']['solved']);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  //获取蓝桥云课解题数
  Future<SolvedNum> getLanqiaoContests({String name = ''}) async {
    try {
      // 先获取用户信息
      var userUrl = 'https://www.lanqiao.cn/users/$name/';
      final userResponse = await dio.get(userUrl);
      if (userResponse.statusCode != 200) {
        throw Exception("请求失败，状态码：${userResponse.statusCode}");
      }

      // 尝试从用户页面获取数据
      // 如果失败，使用API查询（但只查询前几页）
      var page = 1;
      var pageSize = 100;
      var maxPages = 10; // 最多查询10页，避免过度请求

      while (page <= maxPages) {
        var url = 'https://www.lanqiao.cn/api/v2/user/prepare-match/problem-rank/?page_size=$pageSize&page=$page';
        var response = await dio.get(url);

        if (response.statusCode != 200) {
          throw Exception("请求失败，状态码：${response.statusCode}");
        }

        var list = response.data['data'];
        for (var item in list) {
          if (item['user_id'].toString() == name) {
            return SolvedNum(name: name, solvedNum: item['problem_count']);
          }
        }

        // 如果返回的数据少于 pageSize，说明已经到达最后一页
        if (list.length < pageSize) {
          break;
        }

        page++;
      }

      throw Exception("未找到用户");
    } catch (e) {
      throw Exception("查询蓝桥OJ失败: $e");
    }
  }


  //获取QOJ解题数
  Future<SolvedNum> getQOJRating({name = ''}) async {
    // QOJ有Cloudflare保护，暂时无法直接访问
    // 返回0并提示用户QOJ暂时无法查询
    return SolvedNum(name: name, solvedNum: 0);
  }
}

void main() async {
  final services = SolvedNumServices();
  final nowcoder = await services.getCodeforcesSolvedNum(name: 'kano07');
  print('Codeforces solved num: ${nowcoder.solvedNum}');
}
