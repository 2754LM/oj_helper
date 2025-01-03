import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/report_services.dart';

class CfReportPage extends StatefulWidget {
  @override
  State<CfReportPage> createState() {
    return _CfReportPageState();
  }
}

class _CfReportPageState extends State<CfReportPage> {
  List<PieChartSectionData> dataList = [];
  ReportServices report = ReportServices();
  final TextEditingController _controller = TextEditingController();

  void _fetchData() async {
    String username = _controller.text;
    List<Map<String, dynamic>> data =
        await report.fetchCodeforcesData(username);
    Map<String, int> tag = {};
    Map<int, int> rating = {};
    for (var i in data) {
      for (var j in i['tags']) {
        tag[j] = tag[j] == null ? 1 : tag[j]! + 1;
      }
      rating[i['rating']] =
          rating[i['rating']] == null ? 1 : rating[i['rating']]! + 1;
    }
    setState(() {
      dataList = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cf分析'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '请输入cf用户名',
                      border: OutlineInputBorder(),
                    ),
                    onEditingComplete: _fetchData,
                  ),
                ),
                const SizedBox(width: 10), // 添加间距
                ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('查询'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: dataList,
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放控制器
    super.dispose();
  }
}
