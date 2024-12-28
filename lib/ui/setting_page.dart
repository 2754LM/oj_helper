import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String curVersion = '';
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    _getCurVersion();
  }

  Future<void> _getCurVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      curVersion = 'v${packageInfo.version}';
    });
  }

  Future<void> checkForUpdate() async {
    setState(() {
      isChecking = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.github.com/repos/2754LM/oj_helper/releases/latest'));
      if (response.statusCode == 200) {
        final latestRelease = json.decode(response.body);
        String latestVersion = latestRelease['tag_name'];
        String releaseBody = latestRelease['body'];

        if (latestVersion != curVersion) {
          _showUpdateDialog(curVersion, latestVersion, releaseBody);
        } else {
          _showNoUpdateDialog();
        }
      } else {
        _showErrorDialog('无法获取最新版本信息');
      }
    } catch (e) {
      _showErrorDialog('检查更新时发生错误');
    } finally {
      setState(() {
        isChecking = false;
      });
    }
  }

  void _showUpdateDialog(
      String curVersion, String latestVersion, String releaseBody) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新版本可用'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前版本: $curVersion 新版本: $latestVersion'),
              SizedBox(height: 8),
              Text('版本说明:\n$releaseBody'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('暂不更新'),
            ),
            TextButton(
              onPressed: () {
                launchUrlString(
                    "https://github.com/2754LM/oj_helper/releases/latest");
                Navigator.of(context).pop();
              },
              child: Text('前往更新'),
            ),
          ],
        );
      },
    );
  }

  void _showNoUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('没有可用的更新'),
          content: Text('当前版本为($curVersion)，没有可用的更新。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置中心'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text("检查更新"),
            subtitle: const Text("检查有无新版本"),
            onTap: checkForUpdate,
          ),
          if (isChecking) CircularProgressIndicator(), // 显示加载指示器
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("官方网站"),
            subtitle: const Text("源神.常州大学.com"),
            onTap: () => launchUrlString("https://cczu-ossa.github.io/home/"),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("开源地址"),
            subtitle: const Text("https://github.com/2754LM/oj_helper"),
            onTap: () => launchUrlString("https://github.com/2754LM/oj_helper"),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("QQ群"),
            subtitle: const Text("947560153"),
            onTap: () => launchUrlString(
                "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=6wgGLJ_NmKQl7f9Ws6JAprbTwmG9Ouei&authKey=g7bXX%2Bn2dHlbecf%2B8QfGJ15IFVOmEdGTJuoLYfviLg7TZIsZCu45sngzZfL3KktN&noverify=0&group_code=947560153"),
          ),
        ],
      ),
    );
  }
}
