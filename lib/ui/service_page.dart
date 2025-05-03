import 'package:flutter/material.dart';

import '../route/routes.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能列表'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 计算每行的列数
          double width = constraints.maxWidth;
          int crossAxisCount = (width / 180).floor();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1, // 使按钮为正方形
            ),
            padding: const EdgeInsets.all(16.0),
            itemCount: 5, // 按钮数量
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildSquareButton(
                    context,
                    '解题数量',
                    'assets/images/solvednum.jpg',
                    () {
                      Navigator.pushNamed(context, RoutePath.solvednum);
                    },
                  );
                case 1:
                  return _buildSquareButton(
                    context,
                    '排位分',
                    'assets/images/rating.png',
                    () {
                      Navigator.pushNamed(context, RoutePath.rating);
                    },
                  );
                case 2:
                  return _buildSquareButton(
                    context,
                    'ccpcfinder',
                    'assets/images/ccpc.jpg',
                    () {
                      Navigator.pushNamed(context, RoutePath.ccpc);
                    },
                  );
                case 3:
                  return _buildSquareButton(
                    context,
                    'oierdb',
                    'assets/images/oier.jpg',
                    () {
                      Navigator.pushNamed(context, RoutePath.oier);
                    },
                  );
                // case 4:
                //   return _buildSquareButton(
                //     context,
                //     'cf分析',
                //     'assets/images/report.png',
                //     () {
                //       Navigator.pushNamed(context, RoutePath.cf_report);
                //     },
                //   );
                default:
                  return Container();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context, String title,
      String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[100], // 使用灰色背景
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
