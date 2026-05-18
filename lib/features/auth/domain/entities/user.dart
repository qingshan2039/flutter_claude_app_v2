import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// 领域层用户实体（Entity）。
///
/// 设计原则：
/// - 纯 Dart，不携带 JSON 序列化逻辑
/// - 不依赖 Flutter / Dio / 任何 IO
/// - 字段使用业务语义命名（camelCase）
///
/// 与数据层 [UserModel] 的转换由 `data/mappers/user_mapper.dart` 完成。
@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    DateTime? createdAt,
  }) = _User;
}
