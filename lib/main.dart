import 'package:flutter/material.dart';
import 'package:oj_helper/provider.dart';
import 'ui/navigation_page.dart';
import 'ui/recent_contest_page.dart';
import 'ui/rating_page.dart';
import 'ui/solved_num_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ContestProvider()
              ..loadPlatformSelection()), // 初始化 ContestProvider
        ChangeNotifierProvider(
            create: (context) => RatingProvider()), // 初始化 RatingProvider
        ChangeNotifierProvider(
            create: (context) => SolvedNumProvider()) // 初始化 SolvedNumProvider,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.light()
              .copyWith(primary: const Color.fromARGB(255, 255, 255, 255)),
        ),
        // 注册路由
        routes: {
          '/比赛': (context) => RecentContestPage(), // 比赛页面
          '/分数': (context) => RatingPage(), // 分数页面
          '/题量': (context) => SolvedNumPage(), // 题量页面
        },
        home: NavigationPage(), // 使用 NavigationPage 作为根页面
      ),
    );
  }
}
