#!/usr/bin/env bash
# M21/T21.5 包体积分析。
#
# 用 `flutter build --analyze-size` 输出产物各部分（Dart AOT / .so / assets / 字体
# 等）的体积明细，并生成可在 DevTools「App size tooling」打开的 JSON 报告。
#
# 用法：
#   scripts/analyze_size.sh [dev|staging|prod] [apk|appbundle|ios] [android-arm64|android-arm|android-x64]
# 例：
#   scripts/analyze_size.sh prod apk android-arm64     # 默认
#
# 说明：
#   - --analyze-size 需要 release 构建；apk/ios 需指定单一 --target-platform。
#   - 终端打印体积树；同时把 JSON 写到 ~/.flutter-devtools/，可在 DevTools 里
#     「Open app size tool」加载对比两次构建的差异。
set -euo pipefail

FLAVOR="${1:-prod}"
FORMAT="${2:-apk}"
PLATFORM="${3:-android-arm64}"

case "$FLAVOR" in
  dev|staging|prod) ;;
  *) echo "❌ flavor 必须是 dev|staging|prod，收到：$FLAVOR" >&2; exit 1 ;;
esac

ENTRY="lib/main_${FLAVOR}.dart"
DEFINE_FILE="env/${FLAVOR}.json"

ARGS=(--flavor "$FLAVOR" -t "$ENTRY" --release --analyze-size)
if [[ -f "$DEFINE_FILE" ]]; then
  ARGS+=("--dart-define-from-file=$DEFINE_FILE")
else
  echo "⚠️  未找到 $DEFINE_FILE，使用 EnvConfig 内置默认值"
fi

echo "📦 体积分析：flavor=$FLAVOR format=$FORMAT platform=$PLATFORM"
case "$FORMAT" in
  apk)       flutter build apk       "${ARGS[@]}" --target-platform "$PLATFORM" ;;
  appbundle) flutter build appbundle "${ARGS[@]}" ;;
  ios)       flutter build ios       "${ARGS[@]}" --target-platform ios ;;
  *) echo "❌ format 必须是 apk|appbundle|ios，收到：$FORMAT" >&2; exit 1 ;;
esac

echo "✅ 分析完成。可在 DevTools → Open app size tool 加载 ~/.flutter-devtools/ 下的 JSON。"
