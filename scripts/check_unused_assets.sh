#!/usr/bin/env bash
# M21/T21.5 未使用资源检测。
#
# 扫描资源目录下的每个文件，在 lib/ 源码（含 flutter_gen 生成的 assets.gen.dart）
# 中按**文件名**查引用，报告未被引用的资源，帮助清理包体积。
#
# 用法：
#   scripts/check_unused_assets.sh [资源目录=assets] [--strict]
#   --strict：存在未引用资源时以退出码 1 结束（可用于 CI 拦截）。
#
# 注意：这是**启发式**检测（按 basename 匹配）。动态拼接路径（如 'icon_$name.png'）
# 可能误报为未使用——请人工复核后再删除。
set -euo pipefail

ASSETS_DIR="${1:-assets}"
STRICT="no"
[[ "${2:-}" == "--strict" ]] && STRICT="yes"
SRC_DIR="lib"

if [[ ! -d "$ASSETS_DIR" ]]; then
  echo "ℹ️  资源目录不存在：$ASSETS_DIR（无需检测）"
  exit 0
fi

unused=0
total=0
while IFS= read -r -d '' file; do
  total=$((total + 1))
  base="$(basename "$file")"
  if ! grep -rqF "$base" "$SRC_DIR"; then
    echo "🟡 未引用：$file"
    unused=$((unused + 1))
  fi
done < <(find "$ASSETS_DIR" -type f -print0)

echo "—"
echo "扫描资源：$total 个，未引用：$unused 个"

if [[ "$unused" -gt 0 && "$STRICT" == "yes" ]]; then
  echo "❌ --strict：存在未引用资源" >&2
  exit 1
fi
echo "✅ 检测完成"
