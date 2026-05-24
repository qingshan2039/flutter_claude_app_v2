import 'package:flutter/foundation.dart';

/// 单个启动阶段的耗时记录（T21.1）。
///
/// - [sinceStart]：从 [StartupTracker.begin] 到本阶段的**累计**耗时。
/// - [delta]：相对**上一个**阶段的增量（即本阶段单独花了多久）。
@immutable
class StartupPhase {
  const StartupPhase(this.name, this.sinceStart, this.delta);

  final String name;
  final Duration sinceStart;
  final Duration delta;

  @override
  String toString() =>
      '$name +${delta.inMilliseconds}ms (@${sinceStart.inMilliseconds}ms)';
}

/// 启动耗时埋点（T21.1）。
///
/// 度量从进程进入 `bootstrap` 到**首帧渲染**之间各阶段的耗时，定位启动瓶颈
/// （DI 解析、存储 @preResolve、错误处理安装等）。
///
/// 设计要点：
/// - **不依赖 DI**：用 [StartupTracker.instance] 全局单例，可在 `configureDependencies`
///   之前就开始计时（DI 本身的耗时也要被测量）。
/// - 各阶段在 [bootstrap] 中调用 [mark]；首帧在 `addPostFrameCallback` 中调用
///   [markFirstFrame]，随后把 [summary] 交给 `AppLogger`。
/// - 纯 Dart、可实例化，便于单测（测试用自己的实例，避免污染全局）。
///
/// ```dart
/// StartupTracker.instance.begin();           // 进程刚进入 bootstrap
/// // ... 初始化 ...
/// StartupTracker.instance.mark('di');        // 记录一个阶段
/// StartupTracker.instance.markFirstFrame();  // 首帧
/// logger.i(StartupTracker.instance.summary());
/// ```
class StartupTracker {
  StartupTracker();

  /// 全局单例（供 [bootstrap] 使用；测试请自行 `StartupTracker()`）。
  static final StartupTracker instance = StartupTracker();

  final Stopwatch _stopwatch = Stopwatch();
  final List<StartupPhase> _phases = <StartupPhase>[];
  Duration _lastElapsed = Duration.zero;
  Duration? _firstFrame;

  /// 是否正在计时。
  bool get isRunning => _stopwatch.isRunning;

  /// 已记录的阶段（只读快照）。
  List<StartupPhase> get phases => List<StartupPhase>.unmodifiable(_phases);

  /// 首帧时间（从 [begin] 起算）；未记录首帧前为 null。
  Duration? get firstFrameTime => _firstFrame;

  /// 开始计时（清空既有状态）。应在进程进入启动流程后**尽早**调用。
  void begin() {
    _phases.clear();
    _lastElapsed = Duration.zero;
    _firstFrame = null;
    _stopwatch
      ..reset()
      ..start();
  }

  /// 记录一个命名阶段，返回该阶段记录。未 [begin] 时记录的 [sinceStart] 为 0。
  StartupPhase mark(String name) {
    final now = _stopwatch.elapsed;
    final phase = StartupPhase(name, now, now - _lastElapsed);
    _phases.add(phase);
    _lastElapsed = now;
    return phase;
  }

  /// 记录首帧（同时作为名为 `firstFrame` 的阶段）。重复调用只取首次。
  void markFirstFrame() {
    if (_firstFrame != null) return;
    final phase = mark('firstFrame');
    _firstFrame = phase.sinceStart;
  }

  /// 生成可读摘要（交给 AppLogger / 打印）。无阶段时返回提示串。
  String summary() {
    if (_phases.isEmpty) {
      return '[startup] no phases recorded '
          '(仅在通过 bootstrap 启动的入口采集)';
    }
    final buffer = StringBuffer('[startup] phases (since process start):');
    for (final phase in _phases) {
      buffer.write(
        '\n  ${phase.name.padRight(16)} '
        '+${phase.delta.inMilliseconds}ms  '
        '(@${phase.sinceStart.inMilliseconds}ms)',
      );
    }
    if (_firstFrame != null) {
      buffer.write('\n  → first frame at ${_firstFrame!.inMilliseconds}ms');
    }
    return buffer.toString();
  }

  /// 重置（主要用于测试）。
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _phases.clear();
    _lastElapsed = Duration.zero;
    _firstFrame = null;
  }
}
