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

Future<void> getLuoguPlatformHelp(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          titleTextStyle: TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
          content: Text(
            '访问个人主页，右侧用户编号即id',
            style: TextStyle(
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        );
      });
}
