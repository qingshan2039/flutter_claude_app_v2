import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';

/// 数据层 [UserModel] → 领域层 [User] 转换。
extension UserModelToEntity on UserModel {
  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    createdAt: createdAt,
  );
}

/// 领域层 [User] → 数据层 [UserModel] 转换。
///
/// 多用于把领域对象提交回后端（如更新用户资料）。
extension UserEntityToModel on User {
  UserModel toModel() => UserModel(
    id: id,
    name: name,
    email: email,
    createdAt: createdAt,
  );
}
