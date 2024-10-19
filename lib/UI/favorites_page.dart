import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oj_helper/models/contest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final List<String> platforms = [
    '洛谷',
    '牛客',
    'hdu',
    'Codeforces',
    'vjudge',
    '其他',
  ];
  List<Contest> favoriteContests = [];
  late SharedPreferences prefs;
  // 加载收藏夹
  void __loadFavoriteContest() async {
    prefs = await SharedPreferences.getInstance();
    String? cur = prefs.getString('favourite_contests');
    if (cur == null || cur == '') {
      setState(() {});
      return;
    }
    for (String s in cur.split(',')) {
      if (s == '') continue;
      String infor = prefs.getString(s) ?? '';
      List<String> inforList = infor.split(',');
      if (infor == '') continue;
      favoriteContests.add(Contest.fromJson(
        inforList[0],
        int.parse(inforList[1]),
        int.parse(inforList[2]),
        inforList[3],
        inforList[4],
      ));
    }
    favoriteContests
        .sort((a, b) => a.startTimeSeconds.compareTo(b.startTimeSeconds));
    setState(() {});
  }

  // 删除比赛
  void _delFavoriteContest(Contest contest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String infor =
        '${contest.name},${contest.startTimeSeconds},${contest.durationSeconds},${contest.platform},${contest.link}';
    if (prefs.containsKey(contest.name)) {
      await prefs.remove(contest.name);
      String? cur = prefs.getString('favourite_contests');
      List<String> contestNames = [];
      if (cur == null) {
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
        setState(() {});
        return;
      }
      contestNames.add(contest.name);
      prefs.setString('favourite_contests', contestNames.join(','));
    }
    favoriteContests.remove(contest);
    setState(() {});
  }

  // //比赛通知
  // void _showContestNotification(Contest contest, int time) async {
  //   //head：比赛通知
  //   //body：比赛名称：${contest.name}将于${contest.startTime}开始，请做好准备。
  //   //在time+contest.startTimeSeconds时(unix秒）在通知栏提醒
  //   //点击通知栏直接忽略
  //   //代码实现如下，使用flutter_local_notifications
  //   await initializeNotifications();
  //   const AndroidNotificationDetails androidNotificationDetail =
  //       AndroidNotificationDetails(
  //     'contest_notification',
  //     '比赛通知',
  //     priority: Priority.high,
  //     importance: Importance.max,
  //     enableVibration: true,
  //     styleInformation: DefaultStyleInformation(true, true),
  //   );
  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidNotificationDetail,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     time,
  //     '比赛通知',
  //     '${contest.name}将于${contest.startTime}开始，请做好准备。',
  //     notificationDetails,
  //   );
  // }

  @override
  void initState() {
    super.initState();
    __loadFavoriteContest();
  }

  //添加比赛界面
  void _showAddContestDialog() async {
    int startTime = 0, endTime = 0, startYMDseconds = 0, endYMDseconds = 0;
    int startHMseconds = 0, endHMseconds = 0;
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm');
    startTimeController.text = '0000-00-00 00:00';
    endTimeController.text = '0000-00-00 00:00';
    String platform = '其他', link = '', name = '';
    DateTime nowTime = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Builder(builder: (context) {
          return SingleChildScrollView(
            child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('添加比赛', style: TextStyle(fontSize: 20)),
                    // 输入比赛名称
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(labelText: '比赛名称'),
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                    ),
                    // 输入比赛链接
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(labelText: '比赛链接'),
                        onChanged: (value) {
                          link = value;
                        },
                      ),
                    ),
                    // 选择比赛平台
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: '比赛平台'),
                        value: platform,
                        items: platforms.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            platform = value!;
                          });
                        },
                      ),
                    ),

                    // 开始时间
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: startTimeController,
                        decoration: const InputDecoration(
                          labelText: '开始时间',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        readOnly: true,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              DateTime? cur = await showDatePicker(
                                context: context,
                                initialDate: nowTime,
                                firstDate:
                                    nowTime.subtract(Duration(days: 365)),
                                lastDate: nowTime.add(Duration(days: 720)),
                                locale: Locale('zh', 'CN'),
                              );
                              startYMDseconds =
                                  cur?.millisecondsSinceEpoch ?? 0;
                              startYMDseconds ~/= 1000;
                              startTime = startYMDseconds + startHMseconds;
                              startTimeController.text = format.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      startTime * 1000));
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0))),
                            ),
                            child: const Text(
                              '日期',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.of(context).push(
                                showPicker(
                                    okText: '确定',
                                    cancelText: '取消',
                                    context: context,
                                    value: Time(
                                        hour: nowTime.hour,
                                        minute: nowTime.minute),
                                    is24HrFormat: true,
                                    onChange: (cur) {
                                      startHMseconds =
                                          cur.hour * 3600 + cur.minute * 60;
                                      startTime =
                                          startYMDseconds + startHMseconds;
                                      startTimeController.text = format.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              startTime * 1000));
                                      setState(() {});
                                    }),
                              );
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0))),
                            ),
                            child: Text(
                              '时分',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 结束时间
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: endTimeController,
                        decoration: const InputDecoration(
                          labelText: '结束时间',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        readOnly: true,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              DateTime? cur = await showDatePicker(
                                context: context,
                                initialDate: nowTime,
                                firstDate:
                                    nowTime.subtract(Duration(days: 365)),
                                lastDate: nowTime.add(Duration(days: 720)),
                                locale: Locale('zh', 'CN'),
                              );
                              endYMDseconds = cur?.millisecondsSinceEpoch ?? 0;
                              endYMDseconds ~/= 1000;
                              endTime = endYMDseconds + endHMseconds;
                              endTimeController.text = format.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      endTime * 1000));
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0))),
                            ),
                            child: const Text(
                              '日期',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.of(context).push(
                                showPicker(
                                    okText: '确定',
                                    cancelText: '取消',
                                    context: context,
                                    value: Time(
                                        hour: nowTime.hour,
                                        minute: nowTime.minute),
                                    is24HrFormat: true,
                                    onChange: (cur) {
                                      endHMseconds =
                                          cur.hour * 3600 + cur.minute * 60;
                                      endTime = endYMDseconds + endHMseconds;
                                      endTimeController.text = format.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              endTime * 1000));
                                      setState(() {});
                                    }),
                              );
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0))),
                            ),
                            child: Text(
                              '时分',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (startTime == 0 || endTime == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('请选择开始时间和结束时间'),
                  ),
                );
                return;
              } else if (startTime >= endTime) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('结束时间必须大于开始时间'),
                  ),
                );
                return;
              } else if (name == '') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('请输入比赛名称'),
                  ),
                );
                return;
              }
              //比赛名称查重
              for (Contest contest in favoriteContests) {
                if (contest.name == name) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('该比赛名称已存在'),
                    ),
                  );
                  return;
                }
              }
              String infor =
                  '$name,$startTime,${endTime - startTime},$platform,$link';
              await prefs.setString(name, infor);
              String? cur = prefs.getString('favourite_contests');
              List<String> contestNames = [];
              if (cur == null) {
                setState(() {});
                return;
              }
              contestNames = cur.split(',');
              contestNames.add(name);
              prefs.setString('favourite_contests', contestNames.join(','));
              favoriteContests.add(Contest.fromJson(
                  name, startTime, endTime - startTime, platform, link));
              favoriteContests.sort(
                  (a, b) => a.startTimeSeconds.compareTo(b.startTimeSeconds));
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏夹'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showAddContestDialog();
            },
            icon: Icon(Icons.add),
            color: Colors.blue,
            iconSize: 35,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认全部删除？'),
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (Contest contest in favoriteContests) {
                            _delFavoriteContest(contest);
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
          itemCount: favoriteContests.length,
          itemBuilder: (context, index) {
            Contest contest = favoriteContests[index];
            var start = DateTime.fromMillisecondsSinceEpoch(
                contest.startTimeSeconds * 1000);
            var end = DateTime.fromMillisecondsSinceEpoch(
                (contest.startTimeSeconds + contest.durationSeconds) * 1000);
            var diffEnd = end.difference(DateTime.now());
            var diffStart = start.difference(DateTime.now());
            String diffStr;
            Color diffColor;
            if (diffStart.inDays >= 1) {
              diffStr = '距开始${diffStart.inDays} 天';
              diffColor = Colors.black;
            } else if (diffEnd.inMinutes <= 0) {
              diffColor = Colors.grey;
              diffStr = '已结束';
            } else if (diffEnd.inMinutes > 0 && diffStart.inMinutes <= 0) {
              diffStr = '比赛中~';
              diffColor = Colors.green;
            } else {
              diffStr =
                  '距开始${diffStart.inHours} 小时 ${diffStart.inMinutes % 60} 分';
              diffColor = Colors.redAccent;
            }
            return ListTile(
              //超链接名称
              title: InkWell(
                onTap: () {
                  if (contest.link != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认访问？'),
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse(contest.link!));
                              Navigator.pop(context);
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('该比赛暂无链接'),
                        titleTextStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  contest.name,
                  maxLines: 5,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              //比赛时间
              subtitle: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context)
                      .style, //你可以在这里设置默认的样式，这个样式会应用到没有特别指定样式的TextSpan上
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            '开始时间：${contest.startTime}\n结束时间：${contest.endTime}\n',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                      text: diffStr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: diffColor,
                      ),
                    ),
                  ],
                ),
              ),
              leading: Image.asset('assets/platforms/${contest.platform}.jpg',
                  width: 30, height: 30),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                    ),
                    onPressed: () {
                      setState(() {
                        _delFavoriteContest(contest);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
