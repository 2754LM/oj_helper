import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:oj_helper/ui/widgets/dialog_checkbox.dart' show DialogCheckbox;
import 'package:oj_helper/models/contest.dart' show Contest;
import 'package:oj_helper/provider.dart';
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

  Dio dio = Dio();
  // 查询天数，默认7天
  int day = 7;

  // 加载状态
  bool isLoading = false;

  /// 获取近期比赛
  void _loadContests() async {
    setState(() {
      isLoading = true;
    });
    // 获取 Provider 实例
    ContestProvider contestProvider =
        Provider.of<ContestProvider>(context, listen: false);
    List<Contest> newContests = await ContestUtils.getRecentContests();
    contestProvider.setContests(newContests); // 更新比赛列表
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('近期比赛'),
          background: Container(
            // 设置背景颜色
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          TextButton.icon(
            label: Text("筛选平台"),
            icon: const Icon(Icons.filter_alt),
            onPressed: _showPlatformSelection, // 打开筛选弹窗
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _loadContests,
        child: const Icon(Icons.search),
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
              value: Provider.of<ContestProvider>(context)
                  .selectedPlatforms['Codeforces'],
              onChanged: (value) {
                setState(() {
                  Provider.of<ContestProvider>(context, listen: false)
                      .updatePlatformSelection('Codeforces', value!);
                });
              },
            ),
            DialogCheckbox(
              title: 'AtCoder',
              value: Provider.of<ContestProvider>(context)
                  .selectedPlatforms['AtCoder'],
              onChanged: (value) {
                setState(() {
                  Provider.of<ContestProvider>(context, listen: false)
                      .updatePlatformSelection('AtCoder', value!);
                });
              },
            ),
            DialogCheckbox(
              title: 'Luogu',
              value: Provider.of<ContestProvider>(context)
                  .selectedPlatforms['Luogu'],
              onChanged: (value) {
                setState(() {
                  Provider.of<ContestProvider>(context, listen: false)
                      .updatePlatformSelection('Luogu', value!);
                });
              },
            ),
            DialogCheckbox(
              title: '蓝桥云课',
              value: Provider.of<ContestProvider>(context)
                  .selectedPlatforms['蓝桥云课'],
              onChanged: (value) {
                setState(() {
                  Provider.of<ContestProvider>(context, listen: false)
                      .updatePlatformSelection('蓝桥云课', value!);
                });
              },
            ),
            DialogCheckbox(
              title: '力扣',
              value:
                  Provider.of<ContestProvider>(context).selectedPlatforms['力扣'],
              onChanged: (value) {
                setState(() {
                  Provider.of<ContestProvider>(context, listen: false)
                      .updatePlatformSelection('力扣', value!);
                });
              },
            ),
            DialogCheckbox(
              title: '牛客',
              value:
                  Provider.of<ContestProvider>(context).selectedPlatforms['牛客'],
              onChanged: (value) {
                setState(() {
                  Provider.of<ContestProvider>(context, listen: false)
                      .updatePlatformSelection('牛客', value!);
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
  Widget _buildBody() {
    return Consumer<ContestProvider>(
      builder: (context, contestProvider, child) {
        return ListView.separated(
          itemCount: contestProvider.contests.length,
          itemBuilder: (BuildContext context, int index) {
            if (contestProvider.selectedPlatforms[
                    contestProvider.contests[index].platform] ==
                true) {
              return ListTile(
                title: Text(contestProvider.contests[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('开始时间：${contestProvider.contests[index].startTime}'),
                    Text('结束时间：${contestProvider.contests[index].endTime}'),
                    Text('比赛时长：${contestProvider.contests[index].duration}'),
                    Text('比赛平台：${contestProvider.contests[index].platform}'),
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
      },
    );
  }
}
