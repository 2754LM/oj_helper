import 'package:flutter/material.dart';
import 'package:oj_helper/ui/ccpc.dart';
import 'package:oj_helper/ui/favorites_page.dart';
import 'package:oj_helper/ui/navigation_page.dart';
import 'package:oj_helper/ui/oier_page.dart';
import 'package:oj_helper/ui/rating_page.dart';
import 'package:oj_helper/ui/recent_contest_page.dart';
import 'package:oj_helper/ui/service_page.dart';
import 'package:oj_helper/ui/setting_page.dart';
import 'package:oj_helper/ui/solvednum_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePath.home:
        return pageRoute(NavigationPage());
      case RoutePath.contest:
        return pageRoute(RecentContestPage());
      case RoutePath.service:
        return pageRoute(ServicePage());
      case RoutePath.setting:
        return pageRoute(SettingPage());
      case RoutePath.rating:
        return pageRoute(RatingPage());
      case RoutePath.solvednum:
        return pageRoute(SolvedNumPage());
      case RoutePath.star:
        return pageRoute(FavoritesPage());
      case RoutePath.ccpc:
        return pageRoute(CcpcPage());
      case RoutePath.oier:
        return pageRoute(OierPage());
    }
    return pageRoute(Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}'))));
  }

  static MaterialPageRoute pageRoute(Widget page) {
    return MaterialPageRoute(
      builder: (context) {
        return page;
      },
    );
  }
}

class RoutePath {
  static const String home = '/';
  static const String contest = '/contest';
  static const String service = '/service';
  static const String setting = '/setting';
  static const String rating = '/rating';
  static const String solvednum = '/solved_num';
  static const String star = '/star';
  static const String ccpc = '/ccpc';
  static const String oier = '/oier';
}
