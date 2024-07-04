import 'package:flutter/material.dart';
import 'rating_page.dart';
import 'recent_contest_page.dart';
import 'solved_num_page.dart';
import 'favorites_page.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final updateUrl = 'https://api.github.com/2754LM/oj_helper/releases/latest';
  @override
  void initState() {
    super.initState();
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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHight = constraints.maxHeight;
            if (screenWidth / screenHight > 1.1) {
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    leading: SizedBox(height: 10),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.event_note),
                        label: Text('比赛'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.star),
                        label: Text('收藏'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.trending_up),
                        label: Text('分数'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.done),
                        label: Text('题量'),
                      ),
                    ],
                  ),
                  // 页面内容
                  Expanded(
                    child: _pages[_selectedIndex],
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  // 页面内容
                  Expanded(
                    child: _pages[_selectedIndex],
                  ),
                  // 底部导航栏
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(Icons.event_note), label: '比赛'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.star), label: '收藏'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.trending_up), label: '分数'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.done), label: '题量'),
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
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
