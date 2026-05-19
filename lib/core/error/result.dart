import 'package:flutter_claude_app_v2/core/error/failures.dart';

/// 双结果类型：成功时持有 [T] 值，失败时持有 [Failure]。
///
/// 设计要点（T03.3）：
/// - 用 Dart 3 sealed class，编译器穷尽检查 switch 分支
/// - 命名 `Success<T>` / `Failed<T>`，避免 [Failure] 数据类与变体类的名字冲突
/// - 提供 fold / map / flatMap 三件套，避免反复 switch
/// - **不引入 dartz / fpdart 依赖**，模板自给自足
///
/// 使用：
/// ```dart
/// Result<User> r = await repo.getUser();
///
/// // 1. fold
/// final ui = r.fold(
///   (user) => UserCard(user),
///   (failure) => ErrorView(failure),
/// );
///
/// // 2. map（仅成功时变换）
/// Result<String> name = r.map((u) => u.name);
///
/// // 3. flatMap（链式调用下一个 Result）
/// Result<Profile> profile = r.flatMap((u) => loadProfile(u.id));
///
/// // 4. pattern matching（推荐）
/// switch (r) {
///   case Success(:final value): ...
///   case Failed(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// 成功结果，持有 [T] 值。
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// 失败结果，持有 [Failure]。命名为 `Failed` 以避免与 [Failure] 类型冲突。
final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failed<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failed($failure)';
}

extension ResultExtension<T> on Result<T> {
  /// 对成功值应用 [onSuccess]，对失败应用 [onFailure]。两者都必须返回同类型。
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(Failure failure) onFailure,
  ) {
    return switch (this) {
      Success<T>(value: final v) => onSuccess(v),
      Failed<T>(failure: final f) => onFailure(f),
    };
  }

  /// 仅在成功时把值映射成 [R]。失败原样传递。
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final v) => Success<R>(transform(v)),
      Failed<T>(failure: final f) => Failed<R>(f),
    };
  }

  /// 仅在成功时调用下一个 Result-返回函数。
  ///
  /// 与 [map] 的区别：[transform] 已经返回 `Result<R>`，flatMap 不会再嵌套包装。
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final v) => transform(v),
      Failed<T>(failure: final f) => Failed<R>(f),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  /// 仅在成功时返回值，失败返回 null。
  T? get valueOrNull => switch (this) {
    Success<T>(value: final v) => v,
    Failed<T>() => null,
  };

  /// 仅在失败时返回 Failure，成功返回 null。
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(failure: final f) => f,
  };
}
