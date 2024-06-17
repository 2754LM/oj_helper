import 'package:flutter/material.dart';

import 'rating_page.dart';
import 'recent_contest_page.dart';
import 'solved_num_page.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  //页面列表
  final List<Widget> _pages = [
    RecentContestPage(),
    RatingPage(),
    SolvedNumPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //动画样式
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // 动画持续时间
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation, // 使用 淡入淡出动画
          child: child,
        ),
        child: _pages[_selectedIndex], // 使用 _pages[_selectedIndex] 作为子组件
      ),
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: '比赛'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: '分数'),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: '题量'),
        ],
        currentIndex: _selectedIndex,
        // 点击事件
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
