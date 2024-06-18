import 'package:dio/dio.dart';
import 'package:html/dom.dart';
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
          .substring(0, 2));
      return SolvedNum(name: name, solvedNum: solvedNum);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取力扣的解题数
  Future<SolvedNum> getLeetcodeRating({name = ''}) async {
    final url = 'https://leetcode.cn/graphql/';
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

  ///获取洛谷的解题数
  Future<SolvedNum> getLuoguRating({name = ''}) async {
    final url = 'https://api.jerryz.com.cn/practice?name=$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      //格式如：已通过: 1666题    未通过: 59题
      final infor = document.getElementsByClassName('title')[1];
      final text = infor.text.trim();
      final solvedNum =
          int.parse(RegExp(r'\d+').firstMatch(text)?.group(0) ?? '0');
      return SolvedNum(name: name, solvedNum: solvedNum);
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
  Future<SolvedNum> getHduRating({name = ''}) async {
    final url = 'https://acm.hdu.edu.cn/userstatus.php?user=$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      final solvedNum = int.parse(document
          .getElementsByTagName('tbody')[4]
          .getElementsByTagName('td')[7]
          .text);
      final links =
          document.querySelectorAll('td:contains("Overall solved") a');
      print(links);
      return SolvedNum(name: name, solvedNum: solvedNum);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取poj的解题数
  Future<SolvedNum> getPOJRating({name = ''}) async {
    final url = 'http://poj.org/userstatus?user_id=$name';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      final solvedNum = int.parse(document
          .getElementsByTagName('tbody')[4]
          .getElementsByTagName('a')[0]
          .text);
      return SolvedNum(name: name, solvedNum: solvedNum);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }
}

void main() async {
  final service = SolvedNumServices();
  SolvedNum tmp = await service.getPOJRating(name: 'dhu_try');
  print(tmp.solvedNum);
}
