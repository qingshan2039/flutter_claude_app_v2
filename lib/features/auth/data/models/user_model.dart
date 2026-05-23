import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart' show User;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 数据层用户 Model（DTO）。
///
/// 设计原则：
/// - 字段映射后端 JSON 协议（snake_case 通过 @JsonKey 映射到 camelCase）
/// - 携带 fromJson / toJson 序列化方法
/// - 不直接出现在 domain / presentation 层；用 mapper 转 [User] 后再向上传递
@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
