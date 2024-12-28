import 'package:flutter/material.dart';
import 'package:oj_helper/ui/favorites_page.dart';
import 'package:oj_helper/ui/service_page.dart';
import 'package:oj_helper/ui/setting_page.dart';

import 'recent_contest_page.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
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
    ServicePage(),
    SettingPage(),
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
                        icon: Icon(Icons.list),
                        label: Text('功能'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        label: Text('设置'),
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
                          icon: Icon(Icons.list), label: '功能'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: '设置'),
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
