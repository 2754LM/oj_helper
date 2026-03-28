import 'package:package_info_plus/package_info_plus.dart';
import 'package:oj_helper/services/api_service.dart';
import 'package:oj_helper/utils/config.dart';
import 'dart:developer' as developer;

class VersionService {
  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      // 获取当前应用版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      developer.log('Checking for update... Current version: $currentVersion', name: 'VersionService');

      // 从远程 URL 获取最新版本信息
      final response = await ApiService.dio.get(Config.versionCheckUrl);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null || data['version'] == null) {
          throw Exception('远程版本数据格式错误');
        }

        final remoteVersion = data['version'] as String;
        developer.log('Remote version found: $remoteVersion', name: 'VersionService');

        if (_isVersionGreater(remoteVersion, currentVersion)) {
          return {
            'hasUpdate': true,
            'latestVersion': remoteVersion,
            'updateUrl': data['updateUrl'] ?? Config.defaultUpdateUrl,
            'releaseNotes': data['releaseNotes'] ?? '发现新版本，请更新。',
          };
        } else {
          developer.log('App is up to date.', name: 'VersionService');
        }
      } else {
        throw Exception('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // 记录详细的错误信息以便调试
      developer.log(
        'Version check failed',
        name: 'VersionService',
        error: e,
        stackTrace: stackTrace,
      );
      
      // 可以选择抛出异常或返回特定标识，由 UI 层决定是否提示用户
      // 目前维持原逻辑返回 null，但记录了详细日志
    }
    return null;
  }

  static bool _isVersionGreater(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return true;
      if (v1Parts[i] < v2Parts[i]) return false;
    }
    return v1Parts.length > v2Parts.length;
  }
}
