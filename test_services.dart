import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'dart:convert';

class TestServices {
  final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }));

  Future<void> testLuoguSolved(String name) async {
    print('Testing Luogu Solved for $name...');
    try {
      final searchUrl =
          'https://www.luogu.com.cn/api/user/search?keyword=$name';
      final response = await dio.get(searchUrl,
          options: Options(headers: {'X-Requested-With': 'XMLHttpRequest'}));
      final userId = response.data['users'][0]['uid'];
      print('Found User ID: $userId');

      final userUrl = 'https://www.luogu.com.cn/user/$userId';
      final res = await dio.get(userUrl);
      final body = res.data.toString();

      final match =
          RegExp(r'"passedProblemCount"\s*:\s*(\d+)').firstMatch(body);
      if (match != null) {
        print('Solved: ${match.group(1)}');
      } else {
        print('Regex failed on HTML');
        // Search for the snippet
        if (body.contains('passedProblemCount')) {
          final start = body.indexOf('passedProblemCount');
          print('Snippet: ${body.substring(start, start + 50)}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> testVJudgeSolved(String name) async {
    print('\nTesting VJudge Solved for $name...');
    try {
      final url = 'https://vjudge.net/user/solveDetail/$name';
      final response = await dio.get(url);
      final data = response.data;
      final acRecords = data['acRecords'] as Map<String, dynamic>;
      int total = 0;
      acRecords.forEach((key, value) {
        total += (value as List).length;
      });
      print('Solved: $total');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> testCodeChefRating(String name) async {
    print('\nTesting CodeChef Rating for $name...');
    try {
      final url = "https://www.codechef.com/users/$name";
      final response = await dio.get(url);
      final body = response.data.toString();
      if (body.contains('var all_rating =')) {
        print('Found all_rating script');
        final start =
            body.indexOf('var all_rating =') + 'var all_rating ='.length;
        final end = body.indexOf(';', start);
        final jsonStr = body.substring(start, end).trim();
        final data = jsonDecode(jsonStr);
        print('History length: ${data.length}');
        print('Latest Rating: ${data.last['rating']}');
      } else {
        print('all_rating script not found');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

void main() async {
  final ts = TestServices();
  await ts.testLuoguSolved('luogu');
  await ts.testVJudgeSolved('tourist');
  await ts.testCodeChefRating('gennady.korotkevich');
}
