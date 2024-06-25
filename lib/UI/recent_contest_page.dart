import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:oj_helper/models/contest.dart' show Contest;
import 'package:oj_helper/provider.dart';
import 'package:oj_helper/ui/widgets/dialog_checkbox.dart' show DialogCheckbox;
import 'package:oj_helper/utils/contest_utils.dart' show ContestUtils;
import 'package:provider/provider.dart';

class RecentContestPage extends StatefulWidget {
  @override
  State<RecentContestPage> createState() => _RecentContestPageState();
}

class _RecentContestPageState extends State<RecentContestPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final platForms = ['Codeforces', 'AtCoder', '洛谷', '蓝桥云课', '力扣', '牛客'];
  // 按日期分类的比赛列表，长度为7
  Dio dio = Dio();
  // 查询天数，默认7天
  int day = 7;
  // 加载状态
  bool isLoading = false;

  /// 获取近期比赛
  void _loadContests() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    ContestProvider contestProvider =
        Provider.of<ContestProvider>(context, listen: false);
    List<List<Contest>> nowContests = await ContestUtils.getRecentContests(
        day: day, contestProvider: contestProvider);
    contestProvider.setContests(nowContests);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('近期比赛'),
          background: Container(
            color: Colors.white,
          ),
        ),
        actions: [
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.filter_alt),
            color: Colors.blue,
            iconSize: 35,
            onPressed: _showPlatformSelection, // 打开筛选弹窗
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.blue,
            iconSize: 35,
            onPressed: _loadContests, //加载比赛
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading // 显示加载动画
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                )
              : _buildBody(),
        ],
      ),
    );
  }

  // 显示平台选择弹窗
  void _showPlatformSelection() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            children: [
              Row(children: [
                SizedBox(width: 20),
                Text(
                  '显示无赛程日',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Spacer(),
                Switch(
                  value: Provider.of<ContestProvider>(context).showEmptyDay,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        Provider.of<ContestProvider>(context, listen: false)
                            .toggleShowEmptyDay(value);
                      });
                    }
                  },
                ),
                SizedBox(width: 20),
              ]),
              for (var name in platForms) ...[
                Divider(color: Colors.grey, thickness: 1.5),
                DialogCheckbox(
                  title: name,
                  value: Provider.of<ContestProvider>(context)
                      .selectedPlatforms[name],
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        Provider.of<ContestProvider>(context, listen: false)
                            .updatePlatformSelection(name, value!);
                      });
                    }
                  },
                ),
              ]
            ],
          );
        });
  }

  // 构建列表
  Widget _buildBody() {
    return Consumer<ContestProvider>(
      builder: (context, contestProvider, child) {
        return ListView.builder(
          itemCount: contestProvider.timeContests.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildCard(index, contestProvider.timeContests[index]);
          },
          padding: EdgeInsets.all(5.0),
        );
      },
    );
  }

  Widget _buildCard(int index, List<Contest> recentContests) {
    bool flag = false;
    final dayName = ContestUtils.getDayName(index);
    for (int i = 0; i < recentContests.length; i++) {
      if (Provider.of<ContestProvider>(context)
              .selectedPlatforms[recentContests[i].platform] ==
          true) {
        flag = true;
        break;
      }
    }
    if (!Provider.of<ContestProvider>(context).showEmptyDay && flag == false) {
      return Container();
    }
    return Card.outlined(
        elevation: 5,
        shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))
            .copyWith(
                side: const BorderSide(color: Colors.blueAccent, width: 3)),
        child: Column(
          children: [
            ListTile(
              title: Text(dayName),
              titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Divider(color: Colors.blueAccent, thickness: 3),
            Column(
              children: [
                SizedBox(height: 10),
                if (!flag)
                  Text(
                    '这里没有比赛喵~',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                for (int i = 0; i < recentContests.length; i++) ...[
                  //是否选中
                  if (Provider.of<ContestProvider>(context)
                          .selectedPlatforms[recentContests[i].platform] ==
                      true) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(children: [
                        SizedBox(width: 20),
                        Image.asset(
                            'assets/platforms/${recentContests[i].platform}.jpg',
                            width: 30,
                            height: 30),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recentContests[i].name,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                '${recentContests[i].startHourMinute} - ${recentContests[i].endHourMinute}',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    if (i != recentContests.length - 1) ...[
                      SizedBox(height: 10),
                      Divider(color: Colors.blueAccent, thickness: 3),
                    ]
                  ]
                ],
                SizedBox(height: 20),
              ],
            ),
          ],
        ));
  }
}
