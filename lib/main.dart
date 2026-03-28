import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oj_helper/providers/contest_provider.dart';
import 'package:oj_helper/providers/rating_provider.dart';
import 'package:oj_helper/providers/solved_num_provider.dart';
import 'package:oj_helper/route/routes.dart';
import 'package:oj_helper/services/notification_service.dart';
import 'package:oj_helper/services/version_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (Android only)
  if (Platform.isAndroid) {
    await NotificationService.init();
  }

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      center: true,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ContestProvider()..loadPlatformSelection(),
        ),
        ChangeNotifierProvider(
          create: (context) => RatingProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SolvedNumProvider(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh', 'CN'),
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light().copyWith(primary: Colors.blue),
        ),
        onGenerateRoute: Routes.generateRoute,
        initialRoute: RoutePath.home,
        builder: (context, child) {
          return UpgradeWrapper(child: child!);
        },
      ),
    );
  }
}

class UpgradeWrapper extends StatefulWidget {
  final Widget child;
  const UpgradeWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<UpgradeWrapper> createState() => _UpgradeWrapperState();
}

class _UpgradeWrapperState extends State<UpgradeWrapper> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  void _checkForUpdate() async {
    // Wait a bit before checking
    await Future.delayed(const Duration(seconds: 2));
    final updateInfo = await VersionService.checkForUpdate();
    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('新版本发布: ${updateInfo['latestVersion']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('更新内容:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(updateInfo['releaseNotes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后再说'),
          ),
          ElevatedButton(
            onPressed: () {
              launchUrl(Uri.parse(updateInfo['updateUrl']));
              Navigator.pop(context);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
