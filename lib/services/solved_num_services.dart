import 'package:dio/dio.dart';
import 'package:oj_helper/models/solved_num.dart' show SolvedNum;
import 'package:html/parser.dart' show parse;

class SolvedNumServices {
  final dio = Dio();

  /// 获取codeforces的解题数
  Future<SolvedNum> getCodeforcesSolvedNum({name = ''}) async {
    final url = 'https://mirror.codeforces.com/profile/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      final solvedNum = int.parse(document
          .getElementsByClassName('_UserActivityFrame_counterValue')[0]
          .text
          .split(' ')[0]);
      return SolvedNum(name: name, solvedNum: solvedNum);
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
  //数据来源：https://github.com/Liu233w/acm-statistics
  Future<SolvedNum> getLuoguRating({name = ''}) async {
    final url = 'https://ojhunt.com/api/crawlers/luogu/$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return SolvedNum(name: name, solvedNum: response.data['data']['solved']);
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
}

void main() async {
  final services = SolvedNumServices();
  final nowcoder = await services.getLanqiaoContests(name: '2328736');
  print(nowcoder.solvedNum);
}
