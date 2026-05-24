import 'package:flutter/foundation.dart';

/// 语义化版本号（T23.1）。
///
/// 解析 `major.minor.patch(+build)`（容忍前导 `v` 与缺省段），并提供比较运算符，
/// 用于「当前版本 vs 最新版本 / 最低支持版本」的判断。
///
/// 解析是**宽松**的：非法/缺省段按 0 处理（版本检查宁可降级，也不崩溃）。
///
/// ```dart
/// AppVersion.parse('1.2.3') < AppVersion.parse('1.10.0'); // true（按数值，非字典序）
/// AppVersion.parse('v2.0.0+15');                          // build = 15
/// ```
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, {this.build});

  /// 宽松解析：去掉前导 `v`，按 `.` 拆 major/minor/patch，`+` 后为 build。
  factory AppVersion.parse(String input) {
    final trimmed = input.trim();
    final plusIndex = trimmed.indexOf('+');
    final core = plusIndex == -1 ? trimmed : trimmed.substring(0, plusIndex);
    final buildStr = plusIndex == -1 ? null : trimmed.substring(plusIndex + 1);
    final cleaned = core.startsWith('v') ? core.substring(1) : core;
    final parts = cleaned.split('.');
    int at(int i) => i < parts.length ? (int.tryParse(parts[i].trim()) ?? 0) : 0;
    return AppVersion(
      at(0),
      at(1),
      at(2),
      build: buildStr == null ? null : int.tryParse(buildStr.trim()),
    );
  }

  final int major;
  final int minor;
  final int patch;

  /// 构建号（`+` 之后），可空。比较时 null 视为 0。
  final int? build;

  @override
  int compareTo(AppVersion other) {
    final byMajor = major.compareTo(other.major);
    if (byMajor != 0) return byMajor;
    final byMinor = minor.compareTo(other.minor);
    if (byMinor != 0) return byMinor;
    final byPatch = patch.compareTo(other.patch);
    if (byPatch != 0) return byPatch;
    return (build ?? 0).compareTo(other.build ?? 0);
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;
  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch, build ?? 0);

  @override
  String toString() =>
      build == null ? '$major.$minor.$patch' : '$major.$minor.$patch+$build';
}
