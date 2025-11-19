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
      final document = parse(response.data);
      final solvedNum = int.parse(document
          .getElementsByClassName('table table-reflow problem-solve')[0]
          .getElementsByTagName('tbody')[0]
          .getElementsByTagName('tr')[4]
          .getElementsByTagName('a')[0]
          .text);
      return SolvedNum(name: name, solvedNum: solvedNum);
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
    final url = 'https://ojhunt.com/api/crawlers/poj/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return SolvedNum(name: name, solvedNum: response.data['data']['solved']);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
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

  //获取蓝桥云课解题数(TODO)
  Future<SolvedNum> getLanqiaoContests({String name = ''}) async {
    var testurl = 'https://www.lanqiao.cn/users/$name/';
    final response = await dio.get(testurl);
    if (response.statusCode != 200) {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
    List<Future<SolvedNum?>> futures = List.generate(
      400,
      (i) => Future(() async {
        var url =
            'https://www.lanqiao.cn/api/v2/user/prepare-match/problem-rank/?page_size=100&page=${i + 1}';
        var response = await dio.get(url);

        if (response.statusCode != 200) {
          throw Exception("请求失败，状态码：${response.statusCode}");
        }

        var list = response.data['data'];
        for (var j in list) {
          print(j);
          if (j['user_id'].toString() == name) {
            return SolvedNum(name: name, solvedNum: j['problem_count']);
          }
        }
        return null;
      }),
    );

    var data = await Future.wait(futures);
    for (var result in data) {
      if (result != null) {
        return result;
      }
    }

    throw Exception("查找失败");
  }


  //获取QOJ解题数
  Future<SolvedNum> getQOJRating({name = ''}) async {
    final url = 'https://qoj.ac/user/profile/$name';
    final response = await dio.get(url);
    if (response.statusCode != 200) {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
    final htmlContent = response.data as String;
    final acceptedPattern = RegExp(r'Accepted problems：(\d+) problems');
    final acceptedMatch = acceptedPattern.firstMatch(htmlContent);
    if (acceptedMatch == null) {
      throw Exception('Failed to parse accepted problems count');
    }
    final acceptedCount = int.parse(acceptedMatch.group(1)!);
    return SolvedNum(
      name: name,
      solvedNum: acceptedCount,
    );
  }
}

void main() async {
  final services = SolvedNumServices();
  final nowcoder = await services.getCodeforcesSolvedNum(name: 'kano07');
  print('Codeforces solved num: ${nowcoder.solvedNum}');
}
