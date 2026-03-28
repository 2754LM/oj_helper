class Config {
  /// 版本检查的远程 URL
  /// 建议格式: { "version": "1.0.0", "updateUrl": "...", "releaseNotes": "..." }
  static const String versionCheckUrl =
      'https://raw.githubusercontent.com/user/repo/main/version.json';

  /// 默认更新跳转链接
  static const String defaultUpdateUrl = 'https://github.com/user/repo/releases/latest';
}
