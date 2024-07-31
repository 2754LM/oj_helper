import 'package:flutter/material.dart';

Future<void> getLeetcodePlatformHelp(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          titleTextStyle: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
          content: Text(
            'pc端：访问个人主页，昵称下方灰色字体为用户名\n手机端：本人暂时不知道，欢迎pr',
            style: TextStyle(
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        );
      });
}

Future<void> getNowcoderPlatformHelp(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          titleTextStyle: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
          content: Text(
            'pc端：登陆账号后访问ac.nowcoder.com，左侧学号即id\n'
            '移动端：点击个人头像，编辑资料，账号即id',
            style: TextStyle(
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        );
      });
}

Future<void> getLanqiaoPlatformHelp(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('警告'),
          titleTextStyle: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
          content: Text(
            '实验性功能，访问很慢！\n只支持当前赛季题量，题量小于10不予显示\n'
            '蓝桥云课个人界面，网址栏users/后即id',
            style: TextStyle(
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        );
      });
}
