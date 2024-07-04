import 'package:intl/intl.dart';

class Contest {
  final String name;
  final String startTime;
  final String endTime;
  final String duration;
  final String platform;
  final String? link;
  DateTime? startDateTimeDay;
  final String startHourMinute;
  final String endHourMinute;
  int startTimeSeconds;
  int durationSeconds;
  String formattedStartTime;
  String formattedEndTime;
  String fomattedDuration;
  Contest({
    required this.name,
    required this.startTime,
    required this.duration,
    this.endTime = '',
    required this.platform,
    this.link,
    this.startDateTimeDay,
    this.startHourMinute = '',
    this.endHourMinute = '',
    this.startTimeSeconds = 0,
    this.durationSeconds = 0,
    this.formattedStartTime = '',
    this.formattedEndTime = '',
    this.fomattedDuration = '',
  });

  static Contest fromJson(
      String name, int startTimeSeconds, int durationSeconds, String platform,
      [String? link]) {
    //格式化时间
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    DateFormat formatter2 = DateFormat('HH:mm');
    DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(startTimeSeconds * 1000);
    Duration duration = Duration(seconds: durationSeconds);
    DateTime endTime = startTime.add(duration);
    //格式化输出
    String startTimeStr = formatter.format(startTime);
    String endTimeStr = formatter.format(endTime);
    String durationTimeStr =
        '${duration.inHours} 小时 ${duration.inMinutes % 60} 分钟';
    DateTime startDateTimeDay =
        DateTime(startTime.year, startTime.month, startTime.day, 23, 59, 59);
    String startHourMinute = formatter2.format(startTime);
    String endHourMinute = formatter2.format(endTime);
    //返回Contest对象
    return Contest(
      name: name,
      startTime: startTimeStr,
      endTime: endTimeStr,
      duration: durationTimeStr,
      platform: platform,
      startDateTimeDay: startDateTimeDay,
      startHourMinute: startHourMinute,
      endHourMinute: endHourMinute,
      link: link,
      startTimeSeconds: startTimeSeconds,
      durationSeconds: durationSeconds,
      formattedStartTime: startTimeStr,
      formattedEndTime: endTimeStr,
      fomattedDuration: durationTimeStr,
    );
  }
}
