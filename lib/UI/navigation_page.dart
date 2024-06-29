import 'package:flutter/material.dart';
import 'rating_page.dart';
import 'recent_contest_page.dart';
import 'solved_num_page.dart';
import 'favorites_page.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final updateUrl = 'https://api.github.com/2754LM/oj_helper/releases/latest';
  @override
  void initState() {
    super.initState();
    FlutterXUpdate.init();
    //安卓自动更新（todo）
  }

  //当前选中项
  int _selectedIndex = 0;
  //页面列表
  final List<Widget> _pages = [
    RecentContestPage(),
    FavoritesPage(),
    RatingPage(),
    SolvedNumPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //动画样式
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _pages[_selectedIndex],
      ),
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: '比赛'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '收藏'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: '分数'),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: '题量'),
        ],
        selectedIconTheme: IconThemeData(
          color: Colors.blue,
          size: 30,
        ),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        selectedLabelStyle: TextStyle(color: Colors.blue),
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
