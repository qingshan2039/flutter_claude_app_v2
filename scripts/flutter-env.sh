#!/usr/bin/env bash
# M15 / T15.3 多环境构建脚本。
#
# 用法：
#   scripts/flutter-env.sh <dev|staging|prod> [run|build-apk|build-appbundle|build-ios]
#
# 例：
#   scripts/flutter-env.sh dev run
#   scripts/flutter-env.sh prod build-apk
#
# 机制：
#   - --flavor <env>            选择原生 flavor（包名/AppName/Icon，见 build.gradle.kts）
#   - -t lib/main_<env>.dart    选择 Dart 入口（bootstrap(AppEnvironment.<env>)）
#   - --dart-define-from-file   注入编译期常量（env/<env>.json，含 API/DSN 等敏感值）
#
# 敏感配置不入库：env/<env>.json 已被 .gitignore；提交的是 env/<env>.example.json 模板。
set -euo pipefail

ENV="${1:-dev}"
CMD="${2:-run}"

case "$ENV" in
  dev|staging|prod) ;;
  *) echo "❌ 环境必须是 dev|staging|prod，收到：$ENV" >&2; exit 1 ;;
esac

ENTRY="lib/main_${ENV}.dart"
DEFINE_FILE="env/${ENV}.json"

DEFINE_ARGS=()
if [[ -f "$DEFINE_FILE" ]]; then
  DEFINE_ARGS+=("--dart-define-from-file=$DEFINE_FILE")
  echo "ℹ️  使用编译期常量文件：$DEFINE_FILE"
else
  echo "⚠️  未找到 $DEFINE_FILE（将用 EnvConfig 内置默认值）。可从模板复制："
  echo "    cp env/${ENV}.example.json $DEFINE_FILE"
fi

echo "🚀 env=$ENV cmd=$CMD entry=$ENTRY"

case "$CMD" in
  run)            flutter run            --flavor "$ENV" -t "$ENTRY" "${DEFINE_ARGS[@]}" ;;
  build-apk)      flutter build apk      --flavor "$ENV" -t "$ENTRY" "${DEFINE_ARGS[@]}" ;;
  build-appbundle) flutter build appbundle --flavor "$ENV" -t "$ENTRY" "${DEFINE_ARGS[@]}" ;;
  build-ios)      flutter build ios      --flavor "$ENV" -t "$ENTRY" "${DEFINE_ARGS[@]}" ;;
  *) echo "❌ 命令必须是 run|build-apk|build-appbundle|build-ios，收到：$CMD" >&2; exit 1 ;;
esac
