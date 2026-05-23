import 'package:flutter/widgets.dart';

/// 圆角 Token（T10.1）。
abstract final class RadiusTokens {
  static const double none = 0;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  // Radius 快捷方式
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);

  // BorderRadius 快捷方式
  static const BorderRadius allSm = BorderRadius.all(radiusSm);
  static const BorderRadius allMd = BorderRadius.all(radiusMd);
  static const BorderRadius allLg = BorderRadius.all(radiusLg);
  static const BorderRadius topLg = BorderRadius.vertical(top: radiusLg);

  /// 胶囊形（按钮 / chip）
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
}
