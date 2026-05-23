#!/usr/bin/env bash
# M16/T16.5 iOS 发布打包脚本（需 macOS + Xcode + 已配置签名/描述文件）。
#
# 用法：scripts/build_ios.sh <dev|staging|prod> [ipa|testflight]
#   scripts/build_ios.sh prod ipa          # 仅构建 .ipa
#   scripts/build_ios.sh prod testflight   # 构建并经 fastlane 上传 TestFlight
#
# 前置：ios/ 下完成 scheme（dev/staging/prod）与签名配置；
#   TestFlight 需 ios/fastlane/Appfile 填好 apple_id/team_id，并配置 App Store
#   Connect API Key（建议用环境变量，勿入库）。
set -euo pipefail

FLAVOR="${1:-prod}"
ACTION="${2:-ipa}"

case "$FLAVOR" in
  dev|staging|prod) ;;
  *) echo "❌ flavor 必须是 dev|staging|prod" >&2; exit 1 ;;
esac

ENTRY="lib/main_${FLAVOR}.dart"
DEFINE_FILE="env/${FLAVOR}.json"
SYMBOLS="build/symbols/${FLAVOR}"

DEFINE_ARGS=()
[[ -f "$DEFINE_FILE" ]] && DEFINE_ARGS+=("--dart-define-from-file=$DEFINE_FILE")

case "$ACTION" in
  ipa)
    flutter build ipa --flavor "$FLAVOR" -t "$ENTRY" --release \
      --obfuscate --split-debug-info="$SYMBOLS" "${DEFINE_ARGS[@]}"
    echo "✅ 产物：build/ios/ipa/*.ipa"
    ;;
  testflight)
    # 交给 fastlane（见 ios/fastlane/Fastfile 的 :beta lane）
    ( cd ios && bundle exec fastlane beta flavor:"$FLAVOR" )
    ;;
  *)
    echo "❌ action 必须是 ipa|testflight" >&2; exit 1 ;;
esac
