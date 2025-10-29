import 'package:flutter/material.dart';
import 'package:oj_helper/models/contest.dart' show Contest;
import 'package:oj_helper/provider.dart';
import 'package:oj_helper/ui/widgets/dialog_checkbox.dart' show DialogCheckbox;
import 'package:oj_helper/utils/contest_utils.dart' show ContestUtils;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/sentence_services.dart';

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
  // 查询天数，默认7天
  int day = 7;
  // 加载状态
  bool isLoading = false;
  final sentenceServices = SentenceServices();
  Map<String, dynamic> sentence = {};

  ///获取近期比赛
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

  //收藏比赛
  void _favoriteContest(Contest contest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String infor =
        '${contest.name},${contest.startTimeSeconds},${contest.durationSeconds},${contest.platform},${contest.link}';
    if (prefs.containsKey(contest.name)) {
      await prefs.remove(contest.name);
      String? cur = prefs.getString('favourite_contests');
      List<String> contestNames = [];
      if (cur == null) {
        prefs.setString('favourite_contests', '');
        setState(() {});
        return;
      }
      contestNames = cur.split(',');
      contestNames.remove(contest.name);
      prefs.setString('favourite_contests', contestNames.join(','));
    } else {
      await prefs.setString(contest.name, infor);
      String? cur = prefs.getString('favourite_contests');
      List<String> contestNames = [];
      if (cur == null) {
        prefs.setString('favourite_contests', '');
        setState(() {});
        return;
      }
      contestNames = cur.split(',');
      contestNames.add(contest.name);
      prefs.setString('favourite_contests', contestNames.join(','));
    }
    setState(() {});
  }

  void _getSentences() async {
    sentence = await sentenceServices.getSentences();
  }

  void _wait() {
    //加载中警告
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全速加载中，老大别急喵'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getSentences();
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('近期比赛'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
        actions: [
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
            onPressed: isLoading ? _wait : _loadContests, //加载比赛
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading // 显示加载动画
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          sentence['content'] ?? '风落吴江雪，纷纷入酒杯。',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ],
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
    bool flag = false; //是否有赛事
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
            //每天具体赛事
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
                //每个比赛
                for (int i = 0; i < recentContests.length; i++) ...[
                  if (Provider.of<ContestProvider>(context)
                          .selectedPlatforms[recentContests[i].platform] ==
                      true) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(children: [
                        SizedBox(width: 20),
                        // 平台图标
                        Image.asset(
                            'assets/platforms/${recentContests[i].platform}.jpg',
                            width: 30,
                            height: 30),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (recentContests[i].link != null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('确认访问？'),
                                        titleTextStyle: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('取消'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              launchUrl(Uri.parse(
                                                  recentContests[i].link!));
                                              Navigator.pop(context);
                                            },
                                            child: const Text('确定'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  recentContests[i].name,
                                  maxLines: 5,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              //比赛时间
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
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20.0), // 添加水平间距
                          child: FutureBuilder<bool>(
                            future: _isFavorite(recentContests[i]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return IconButton(
                                  onPressed: () {
                                    _favoriteContest(recentContests[i]);
                                    // 更新收藏状态
                                  },
                                  iconSize: 28,
                                  icon: Icon(
                                      snapshot.data!
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: snapshot.data!
                                          ? Colors.amber
                                          : Colors.black),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
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

  Future<bool> _isFavorite(Contest contest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(contest.name);
  }
}
