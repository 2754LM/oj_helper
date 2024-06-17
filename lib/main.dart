import 'package:flutter/material.dart';

import 'UI/navigation_page.dart';
import 'UI/recent_contest_page.dart';
import 'UI/rating_page.dart';
import 'UI/solved_num_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 注册路由
      routes: {
        '/比赛': (context) => RecentContestPage(), // 比赛页面
        '/分数': (context) => RatingPage(), // 分数页面
        '/题量': (context) => SolvedNumPage(), // 题量页面
      },
      home: NavigationPage(), // 使用 NavigationPage 作为根页面
    );
  }
}
