import 'package:intl/intl.dart';

class Contest {
  final String name;
  final String startTime;
  final String endTime;
  final String duration;
  final String platform;
  final String link;
  final String monthAndDay;

  Contest({
    required this.name,
    required this.startTime,
    required this.duration,
    this.endTime = '',
    required this.platform,
    this.link = '',
    this.monthAndDay = '',
  });

  static Contest fromJson(
      String name, int startTimeSeconds, int durationSeconds, String platform) {
    //格式化时间
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(startTimeSeconds * 1000);
    Duration duration = Duration(seconds: durationSeconds);
    DateTime endTime = startTime.add(duration);

    //格式化输出
    String startTimeStr = formatter.format(startTime);
    String endTimeStr = formatter.format(endTime);
    String durationTimeStr =
        '${duration.inHours} 小时 ${duration.inMinutes % 60} 分钟';

    //返回Contest对象
    return Contest(
        name: name,
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: durationTimeStr,
        platform: platform);
  }
}
