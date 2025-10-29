import 'package:dio/dio.dart';
import 'package:oj_helper/services/http_client.dart';

class ReportServices {
  final dio = HttpClient.instance;
  Future<List<Map<String, dynamic>>> fetchCodeforcesData(String handle) async {
    // Codeforces API has a maximum count limit, using a reasonable value
    final codeforcesUrl =
        'https://codeforces.com/api/user.status?handle=$handle&from=1&count=10000';
    final response = await dio.get(codeforcesUrl);
    if (response.statusCode != 200 || response.data['status'] != 'OK') {
      throw Exception('Failed to fetch data: ${response.data['comment']}');
    }
    final Set<String> st = {};
    final List<Map<String, dynamic>> ans = [];
    for (var i in response.data['result']) {
      final problem = i['problem'];
      if (problem == null || i['verdict'] != 'OK') {
        continue;
      }
      final tmp =
          '${problem['contestId']}${problem['index']}${problem['name']}';
      if (st.add(tmp)) {
        ans.add({
          'rating': problem['rating'] ?? 0,
          'tags': problem['tags'] ?? [],
        });
      }
    }
    return ans;
  }
}
