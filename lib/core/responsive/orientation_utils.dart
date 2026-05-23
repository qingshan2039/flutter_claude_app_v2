import 'package:flutter/services.dart';

/// 屏幕方向锁定模式（T12.7）。
enum OrientationLockMode { portrait, landscape, all }

/// 屏幕方向工具（T12.7）。
///
/// 横竖屏切换时，Flutter 默认**保留 State**（不重建 State 对象），故业务无需特殊处理
/// 状态保留；滚动位置等用 `PageStorageKey` 即可跨方向保留（见 RESPONSIVE.md）。
///
/// 本工具负责「锁定 / 解锁方向」：
/// ```dart
/// await OrientationUtils.lockPortrait();   // 视频页竖屏锁定
/// await OrientationUtils.unlock();          // 恢复自由旋转
/// ```
abstract final class OrientationUtils {
  /// 把锁定模式映射为允许的 [DeviceOrientation] 列表。纯函数，便于测试。
  static List<DeviceOrientation> orientationsFor(OrientationLockMode mode) {
    return switch (mode) {
      OrientationLockMode.portrait => const <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      OrientationLockMode.landscape => const <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      OrientationLockMode.all => DeviceOrientation.values,
    };
  }

  static Future<void> lock(OrientationLockMode mode) =>
      SystemChrome.setPreferredOrientations(orientationsFor(mode));

  static Future<void> lockPortrait() => lock(OrientationLockMode.portrait);

  static Future<void> lockLandscape() => lock(OrientationLockMode.landscape);

  /// 恢复所有方向自由旋转。
  static Future<void> unlock() => lock(OrientationLockMode.all);
}
