#!/usr/bin/env bash
# M16/T16.4 Android 发布打包脚本（多 flavor + 签名 + 混淆）。
#
# 用法：scripts/build_android.sh <dev|staging|prod> [apk|aab] [--split-per-abi]
#   scripts/build_android.sh prod aab                  # 默认（AAB 由 Play 按设备分发，无需手动拆分）
#   scripts/build_android.sh prod apk --split-per-abi  # APK 按 ABI 拆分（T21.5 包体积优化）
#
# 签名：在 android/key.properties 配置后，release 自动用正式签名（见
#   android/app/build.gradle.kts）；未配置则回退 debug 签名（仅供本地）。
# 混淆：--obfuscate + --split-debug-info；符号产物在 build/symbols/<flavor>，
#   崩溃还原与上报（Sentry）需要，务必妥善留存。
# 包体积（T21.5）：
#   - AAB（推荐上架）：Google Play 自动按设备 ABI/密度/语言切分，安装包最小，无需 --split-per-abi。
#   - APK 直分发：加 --split-per-abi 为每个 ABI（arm64-v8a/armeabi-v7a/x86_64）各出一个包，
#     单包体积约为 universal APK 的 1/3。
set -euo pipefail

FLAVOR="${1:-prod}"
FORMAT="${2:-aab}"
SPLIT_FLAG="${3:-}"

case "$FLAVOR" in
  dev|staging|prod) ;;
  *) echo "❌ flavor 必须是 dev|staging|prod，收到：$FLAVOR" >&2; exit 1 ;;
esac

ENTRY="lib/main_${FLAVOR}.dart"
DEFINE_FILE="env/${FLAVOR}.json"
SYMBOLS="build/symbols/${FLAVOR}"

ARGS=(--flavor "$FLAVOR" -t "$ENTRY" --release
      --obfuscate --split-debug-info="$SYMBOLS")
if [[ -f "$DEFINE_FILE" ]]; then
  ARGS+=("--dart-define-from-file=$DEFINE_FILE")
else
  echo "⚠️  未找到 $DEFINE_FILE，使用 EnvConfig 内置默认值"
fi

echo "🤖 Android build: flavor=$FLAVOR format=$FORMAT split=${SPLIT_FLAG:-none}"
case "$FORMAT" in
  apk)
    if [[ "$SPLIT_FLAG" == "--split-per-abi" ]]; then
      ARGS+=(--split-per-abi)
    fi
    flutter build apk "${ARGS[@]}"
    ;;
  aab)
    if [[ "$SPLIT_FLAG" == "--split-per-abi" ]]; then
      echo "ℹ️  AAB 由 Play 自动按 ABI 分发，忽略 --split-per-abi"
    fi
    flutter build appbundle "${ARGS[@]}"
    ;;
  *) echo "❌ format 必须是 apk|aab" >&2; exit 1 ;;
esac

echo "✅ 完成。符号文件：$SYMBOLS（请留存用于崩溃还原）"
