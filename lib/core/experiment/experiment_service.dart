import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';
import 'package:flutter_claude_app_v2/core/experiment/bucketer.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment_rollback.dart';
import 'package:injectable/injectable.dart';

/// A/B 实验框架（T31.2）。
///
/// 注册实验定义 → 按权重稳定分配变体（[Bucketer]）→ [activate] 上报曝光（M27
/// [Analytics]）。禁用或被 [ExperimentRollback] 回滚时强制回落对照组（T31.3）。
@lazySingleton
class ExperimentService {
  ExperimentService(this._analytics, this._rollback);

  final Analytics _analytics;
  final ExperimentRollback _rollback;

  final Map<String, Experiment> _experiments = <String, Experiment>{};

  void register(Experiment experiment) =>
      _experiments[experiment.key] = experiment;

  Experiment? experiment(String key) => _experiments[key];

  /// 纯权重分配（不上报、不考虑禁用/回滚），便于单测。
  static ExperimentAssignment assignFor(Experiment exp, String unitId) {
    final bucket = Bucketer.bucketOf(
      unitId,
      salt: exp.key,
      buckets: exp.totalWeight,
    );
    var cumulative = 0;
    for (final v in exp.variants) {
      cumulative += v.weight;
      if (bucket < cumulative) {
        return ExperimentAssignment(
          experimentKey: exp.key,
          variantKey: v.key,
          bucket: bucket,
        );
      }
    }
    return ExperimentAssignment(
      experimentKey: exp.key,
      variantKey: exp.controlKey,
      bucket: bucket,
    );
  }

  /// 解析变体：未注册→null；禁用/已回滚→强制对照组；否则权重分配。
  ExperimentAssignment? resolve(String experimentKey, String unitId) {
    final exp = _experiments[experimentKey];
    if (exp == null) return null;
    if (!exp.enabled || _rollback.isRolledBack(experimentKey)) {
      return ExperimentAssignment(
        experimentKey: experimentKey,
        variantKey: exp.controlKey,
        bucket: -1,
        forcedControl: true,
      );
    }
    return assignFor(exp, unitId);
  }

  /// 解析 + 曝光上报（数据上报）。
  Future<ExperimentAssignment?> activate(
    String experimentKey,
    String unitId,
  ) async {
    final assignment = resolve(experimentKey, unitId);
    if (assignment != null) {
      await _analytics.logEvent(
        'experiment_exposure',
        params: <String, Object?>{
          'experiment': assignment.experimentKey,
          'variant': assignment.variantKey,
          'bucket': assignment.bucket,
          'forced_control': assignment.forcedControl,
        },
      );
    }
    return assignment;
  }
}
