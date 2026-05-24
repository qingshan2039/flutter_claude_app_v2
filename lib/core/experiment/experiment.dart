import 'package:flutter/foundation.dart';

/// 实验变体（T31.2）。[weight] 为分流权重（相对值）。
@immutable
class Variant {
  const Variant(this.key, {this.weight = 1}) : assert(weight > 0, 'weight 必须为正');

  final String key;
  final int weight;
}

/// A/B 实验定义（T31.2）。
///
/// [controlKey] 为对照组（默认首个变体），灰度回滚时所有用户回落到它。
@immutable
class Experiment {
  Experiment({
    required this.key,
    required this.variants,
    this.enabled = true,
    String? controlKey,
  }) : assert(variants.isNotEmpty, '至少一个变体'),
       controlKey = controlKey ?? variants.first.key;

  final String key;
  final List<Variant> variants;
  final bool enabled;
  final String controlKey;

  int get totalWeight => variants.fold<int>(0, (sum, v) => sum + v.weight);
}

/// 实验分配结果（T31.2）。
@immutable
class ExperimentAssignment {
  const ExperimentAssignment({
    required this.experimentKey,
    required this.variantKey,
    required this.bucket,
    this.forcedControl = false,
  });

  final String experimentKey;
  final String variantKey;

  /// 命中桶（强制控制组时为 -1）。
  final int bucket;

  /// 是否因禁用/回滚被强制落到对照组。
  final bool forcedControl;

  bool isVariant(String key) => variantKey == key;
}
