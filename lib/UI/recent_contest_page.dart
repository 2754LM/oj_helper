import 'package:flutter/material.dart';
import 'package:oj_helper/utils/contest_utils.dart' show ContestUtils;
import 'package:oj_helper/models/contest.dart' show Contest;
import 'package:dio/dio.dart';
import 'package:oj_helper/UI/widgets/dialog_checkbox.dart' show DialogCheckbox;

class RecentContestPage extends StatefulWidget {
  @override
  State<RecentContestPage> createState() => _RecentContestPageState();
}

class _RecentContestPageState extends State<RecentContestPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Dio dio = Dio();
  // 查询天数，默认7天
  int day = 7;
  // 近期比赛
  List<Contest> contests = [];
  //平台选择列表
  Map<String, bool> selectedPlatforms = {
    'Codeforces': true,
    'AtCoder': true,
    'Luogu': true,
    '蓝桥云课': true,
    '力扣': true,
    '牛客': true,
  };

  // 加载状态
  bool isLoading = false;

  /// 获取近期比赛
  void _loadContests() async {
    setState(() {
      isLoading = true;
    });
    contests = await ContestUtils.getRecentContests();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('近期比赛'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showPlatformSelection, // 打开筛选弹窗
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildBody(contests),
          Align(
            alignment: Alignment.bottomRight, // 右下角
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _loadContests, // 加载比赛数据
                child: const Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示平台选择弹窗
  void _showPlatformSelection() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text('筛选平台'), children: [
            DialogCheckbox(
              title: 'Codeforces',
              value: selectedPlatforms['Codeforces'],
              onChanged: (value) {
                setState(() {
                  selectedPlatforms['Codeforces'] = value!;
                });
              },
            ),
            DialogCheckbox(
              title: 'AtCoder',
              value: selectedPlatforms['AtCoder'],
              onChanged: (value) {
                setState(() {
                  selectedPlatforms['AtCoder'] = value!;
                });
              },
            ),
            DialogCheckbox(
              title: 'Luogu',
              value: selectedPlatforms['Luogu'],
              onChanged: (value) {
                setState(() {
                  selectedPlatforms['Luogu'] = value!;
                });
              },
            ),
            DialogCheckbox(
              title: '蓝桥云课',
              value: selectedPlatforms['蓝桥云课'],
              onChanged: (value) {
                setState(() {
                  selectedPlatforms['蓝桥云课'] = value!;
                });
              },
            ),
            DialogCheckbox(
              title: '力扣',
              value: selectedPlatforms['力扣'],
              onChanged: (value) {
                setState(() {
                  selectedPlatforms['力扣'] = value!;
                });
              },
            ),
            DialogCheckbox(
              title: '牛客',
              value: selectedPlatforms['牛客'],
              onChanged: (value) {
                setState(() {
                  selectedPlatforms['牛客'] = value!;
                });
              },
            ),
            ElevatedButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ]);
        });
  }

  // 构建比赛列表
  Widget _buildBody(List<Contest> contests) {
    return ListView.separated(
      itemCount: contests.length,
      itemBuilder: (BuildContext context, int index) {
        if (selectedPlatforms[contests[index].platform] == true) {
          return ListTile(
            title: Text(contests[index].name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('开始时间：${contests[index].startTime}'),
                Text('结束时间：${contests[index].endTime}'),
                Text('比赛时长：${contests[index].duration}'),
                Text('比赛平台：${contests[index].platform}'),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 1,
        );
      },
    );
  }
}
