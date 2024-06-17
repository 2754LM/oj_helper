import 'package:dio/dio.dart';

Future<void> _loadContests() async {
  final dio = Dio();
  await dio.get("https://ac.nowcoder.com/acm/contest/vip-index");
}

void main() {
  _loadContests();
}
