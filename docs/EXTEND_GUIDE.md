---
doc_type: extend_guide
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T20.5
module_id: M20
status: completed
note: "「新增语言」章节由 T08.6 创建；「新增 feature / 权限 / 环境」章节由 T20.5（M20）补全。"
audience: [human_developers, ai_agents]
tags: [guide, extend, feature, i18n, localization, permission, environment, T08, T20, M08, M20]
---

# 扩展指南（EXTEND_GUIDE）

> 本文档说明如何在模板基础上扩展常见能力，每节给出**可照抄的分步操作**。
> 配套阅读：[架构](ARCHITECTURE.md) · [约定规范](CONVENTIONS.md) · [上手指南](GETTING_STARTED.md)。

## 目录

- [新增 feature（业务模块）](#新增-feature业务模块)
- [新增语言（i18n）](#新增语言i18n)
- [新增权限](#新增权限)
- [新增环境](#新增环境)

---

## 新增 feature（业务模块）

模板按 **Feature-First + Clean Architecture** 组织，新增业务模块（以 `profile`「个人资料」为例）遵循固定 6 步。分层职责见 [架构文档](ARCHITECTURE.md)。

### 第 1 步：建目录骨架

```
lib/features/profile/
├── domain/
│   ├── entities/profile.dart                # 纯 Dart 实体
│   ├── repositories/profile_repository.dart # 抽象接口
│   └── use_cases/get_profile_use_case.dart  # 用例
├── data/
│   ├── models/profile_model.dart            # freezed + json
│   ├── mappers/profile_mapper.dart          # Model ↔ Entity
│   ├── datasources/profile_remote_data_source.dart
│   └── repositories/profile_repository_impl.dart
└── presentation/
    ├── providers/profile_controller.dart
    └── pages/profile_page.dart
```

> 约束：`features/profile` **不要** import 其他 `features/*`；共享逻辑放 `core/` 或 `shared/`。

### 第 2 步：domain 层（纯 Dart，先写接口）

```dart
// domain/entities/profile.dart
class Profile {
  const Profile({required this.id, required this.nickname});
  final String id;
  final String nickname;
}

// domain/repositories/profile_repository.dart
abstract class ProfileRepository {
  Future<Result<Profile>> getProfile(String id);   // 跨层统一返回 Result<T>
}

// domain/use_cases/get_profile_use_case.dart
@injectable
class GetProfileUseCase {
  const GetProfileUseCase(this._repo);
  final ProfileRepository _repo;
  Future<Result<Profile>> call(String id) => _repo.getProfile(id);
}
```

### 第 3 步：data 层（Model + Mapper + DataSource + Repository 实现）

```dart
// data/repositories/profile_repository_impl.dart
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote, this._errorMapper);
  final ProfileRemoteDataSource _remote;
  final ErrorMapper _errorMapper;

  @override
  Future<Result<Profile>> getProfile(String id) async {
    try {
      final model = await _remote.fetch(id);
      return Success(model.toEntity());        // Mapper 转实体
    } on Exception catch (e) {
      return Failed(_errorMapper.map(e));      // 异常归一化为 Failure
    }
  }
}
```

> `@LazySingleton(as: Interface)` 让 DI 把接口绑定到实现；`@injectable` 用于工厂。详见 [架构 §6](ARCHITECTURE.md#6-关键横切设计)。

### 第 4 步：presentation 层（Provider/Controller + Page）

```dart
// presentation/providers/profile_controller.dart
final getProfileUseCaseProvider =
    Provider<GetProfileUseCase>((ref) => getIt<GetProfileUseCase>());

final profileProvider = FutureProvider.autoDispose.family<Profile, String>(
  (ref, id) async {
    final result = await ref.watch(getProfileUseCaseProvider).call(id);
    return result.fold(                         // 需 import core/error/result.dart
      onSuccess: (p) => p,
      onFailure: (f) => throw f,                // 让 AsyncValue 进入 error 态
    );
  },
);
```

页面用 M14 的 `AsyncValueWidget` 渲染三态（参考 `features/detail/presentation/pages/detail_page.dart`）。

### 第 5 步：接路由

```dart
// core/router/route_names.dart
static const profile = 'profile';                       // RouteNames
static const profile = '/profile/:id';                  // RoutePaths

// core/router/app_router.dart —— 加一条 GoRoute（跳出 Shell 用 parentNavigatorKey: rootKey）
GoRoute(
  path: RoutePaths.profile,
  name: RouteNames.profile,
  parentNavigatorKey: rootNavigatorKey,
  builder: (context, state) =>
      ProfilePage(id: state.pathParameters['id']!),
),
```

### 第 6 步：生成代码 + 验证

```bash
dart run build_runner build --delete-conflicting-outputs   # 注册 DI、生成 freezed/json
flutter analyze                                            # 期望 No issues found!
flutter test                                               # 加上你的单测后应全绿
```

> 参考实现：`features/auth`（含网络 + Token + 表单）、`features/detail`（路由参数 + 异步三态）、`features/home`（列表 + 刷新分页）。

---

## 新增语言（i18n）

模板的国际化基于 `flutter_localizations` + `intl` + `flutter gen-l10n`（M08）。
ARB 文件在 `lib/l10n/`，生成的强类型 `AppLocalizations` 也在 `lib/l10n/`。

以新增**日语（ja）**为例，4 步完成：

### 第 1 步：新建 ARB 文件

复制模板 ARB `lib/l10n/app_en.arb` 为 `lib/l10n/app_ja.arb`，把 `@@locale` 改为 `ja`，
翻译所有 value。**只需 `@@locale` + 各 key 的翻译**，不需要重复 `@key` 元数据
（元数据只在 template-arb-file `app_en.arb` 中维护）。

```json
{
  "@@locale": "ja",
  "appTitle": "Flutter Claude アプリ",
  "ok": "OK",
  "cancel": "キャンセル",
  "greetingNamed": "こんにちは、{name}さん！",
  "itemCount": "{count, plural, =0{項目なし} other{{count} 件}}",
  "...": "（其余 key 同样翻译）"
}
```

> **复数（plural）注意**：不同语言的复数类别不同。英语有 `one` / `other`，
> 中文/日语只有 `other`，阿拉伯语有 6 类。按目标语言的 CLDR 规则写 `plural` 分支。

### 第 2 步：在支持列表中登记

编辑 [lib/core/i18n/locale_provider.dart](../lib/core/i18n/locale_provider.dart) 的 `kSupportedLocales`：

```dart
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('zh'),
  Locale('ja'),   // ← 新增
];
```

如果在设置页有语言选择 UI，也要加一个 `languageJapanese` key 到所有 ARB，并在
选择列表中加一项。

### 第 3 步：重新生成

```bash
flutter gen-l10n
# 或 flutter pub get（generate: true 会自动触发）
```

会重新生成 `lib/l10n/app_localizations.dart` + `app_localizations_ja.dart`。

### 第 4 步：验证

```bash
flutter analyze        # 确认没有缺失的 key（缺 key 会编译报错）
flutter test           # 跑 i18n 测试
flutter run            # 在设置页切到日语，确认即时生效
```

### 缺失 key 怎么办

如果某个 ARB 漏译某 key，`flutter gen-l10n` 默认会**回退到 template 语言（en）**，
不会崩溃。要强制完整翻译，可在 `l10n.yaml` 加 `untranslated-messages-file: l10n_missing.txt`，
生成后检查该文件列出的缺失项。

### 运行时切换 + 持久化（已内置）

切换语言（M08/T08.4-T08.5 已实现）：

```dart
// 切到中文
ref.read(localeProvider.notifier).setLocale(const Locale('zh'));
// 恢复跟随系统
ref.read(localeProvider.notifier).useSystemLocale();
```

选择会自动写入 `KeyValueStorage`（key: `app.locale`），下次启动读取。首次启动
（无持久化值）返回 `null` = 跟随系统语言。

### 文案使用方式

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appTitle);                          // 简单 key
Text(l10n.greetingNamed('Alice'));            // 占位符
Text(l10n.itemCount(3));                      // 复数
Text(l10n.lastUpdated(DateTime.now()));       // 日期格式化
Text(l10n.priceLabel(19.99));                 // 货币格式化
```

---

## 新增权限

权限基于 M09 的**平台无关抽象**：业务只认 `AppPermission` 枚举（`lib/core/permission/app_permission.dart`），由 `PermissionService` 内部映射到 `permission_handler`。新增一种权限（以「日历 calendar」为例）4 步。详见 [权限文档](permission/PERMISSIONS.md)。

### 第 1 步：扩枚举 + 映射

```dart
// lib/core/permission/app_permission.dart
enum AppPermission {
  camera, photos, microphone, location, notification, storage, bluetooth,
  calendar,   // ← 新增
}
```

在 `PermissionService` 的实现里把 `AppPermission.calendar` 映射到 `permission_handler` 的 `Permission.calendarFullAccess`（请求）与状态翻译（`granted`/`denied`/`permanentlyDenied`/`restricted`/`limited` → `AppPermissionStatus`）。

### 第 2 步：声明原生权限

**Android**（`android/app/src/main/AndroidManifest.xml`）：

```xml
<uses-permission android:name="android.permission.READ_CALENDAR"/>
<uses-permission android:name="android.permission.WRITE_CALENDAR"/>
```

**iOS**（`ios/Runner/Info.plist`）——必须写用途说明，否则审核被拒/闪退：

```xml
<key>NSCalendarsUsageDescription</key>
<string>需要访问日历以创建提醒</string>
```

> `permission_handler` 在 iOS 还要求在 Podfile 用 `GCC_PREPROCESSOR_DEFINITIONS` 打开对应权限宏。参考 M09 已为现有权限配好的写法。

### 第 3 步：UI 文案（若有权限列表页）

在 `features/permission_demo/presentation/pages/permission_demo_page.dart` 的 `_label` switch 补一项 `AppPermission.calendar => '日历'`（switch 是穷尽的，漏写会编译报错——这是有意的保护）。

### 第 4 步：使用

```dart
final status = await getIt<PermissionService>().request(AppPermission.calendar);
if (status.isGranted) { /* ... */ }

// 一站式：含 rationale + 永久拒绝引导跳系统设置
final ok = await PermissionGuide(getIt<PermissionService>()).ensureGranted(
  context, AppPermission.calendar,
  rationaleTitle: '需要日历权限', rationaleMessage: '用于创建提醒',
);
```

被永久拒绝（`status.needsSettings == true`）时用 `PermissionGuide.showSettingsDialog(...)` 引导用户去系统设置。验证：`flutter analyze` + 真机点请求（host 上不弹原生框）。

---

## 新增环境

模板内置 `dev` / `staging` / `prod` 三套环境（[多环境文档](env/ENVIRONMENTS.md)）。新增一套（以 `qa` 为例）需同时动 **Dart 侧**与**原生 flavor 侧**，共 7 处。

### 第 1 步：扩 AppEnvironment 枚举

```dart
// lib/core/env/app_environment.dart
enum AppEnvironment { dev, staging, prod, qa; /* ... */ }
```

`injectableName` 默认取 `name`（即 `'qa'`），与 injectable 的 `@Environment('qa')` 对齐。

### 第 2 步：EnvConfig 增加默认值分支

在 `lib/core/env/env_config.dart` 为 `qa` 提供一套内置默认（baseUrl / flags 等），作为未传 `--dart-define` 时的回退。

### 第 3 步：新建 Dart 入口

```dart
// lib/main_qa.dart
import 'package:flutter_claude_app_v2/bootstrap.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';

void main() => bootstrap(AppEnvironment.qa);
```

### 第 4 步：环境变量文件

```bash
cp env/dev.example.json env/qa.example.json   # 改值，提交模板
cp env/qa.example.json  env/qa.json           # 本地真实值，已被 .gitignore
```

### 第 5 步：原生 flavor

在 `flavorizr.yaml` 增加 `qa` flavor（appId 后缀 / appName / icon），并同步到 Android `android/app/build.gradle.kts` 的 `productFlavors { create("qa") { ... } }`（dimension 与现有一致）。iOS 在 Xcode 加对应 scheme/configuration（或重跑 flavorizr）。如需独立图标，补 `flutter_launcher_icons-qa.yaml`。

### 第 6 步：运行脚本 + VSCode

- `scripts/flutter-env.sh` 的环境白名单 `dev|staging|prod` 加上 `qa`（`case` 两处）。
- `.vscode/launch.json` 复制一份 dev 配置，改 `program: lib/main_qa.dart`、`--flavor qa`、`--dart-define-from-file=env/qa.json`。

### 第 7 步：验证

```bash
dart run build_runner build --delete-conflicting-outputs   # 重新生成按环境的 DI
scripts/flutter-env.sh qa run                              # 跑通 qa
flutter analyze && flutter test                            # 双绿
```

> 关键点：**Dart 入口 + 原生 flavor 必须成对**。只加 `main_qa.dart` 而不加原生 flavor，`--flavor qa` 会因找不到 Gradle flavor 而构建失败。
