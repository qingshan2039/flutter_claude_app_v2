#!/usr/bin/env bash
# M17/T17.5 测试覆盖率脚本。
#
# 用法：
#   scripts/coverage.sh            # 跑测试 + 生成 lcov + 打印摘要
#   scripts/coverage.sh --html     # 额外生成 HTML 报告（需 lcov/genhtml）
#
# 产物：coverage/lcov.info（已被 .gitignore）。CI 会把它作为 artifact 上传。
set -euo pipefail

echo "🧪 运行测试并收集覆盖率..."
flutter test --coverage

LCOV="coverage/lcov.info"
[[ -f "$LCOV" ]] || { echo "❌ 未生成 $LCOV" >&2; exit 1; }

# 过滤掉不该计入覆盖率的文件（生成代码 / l10n / DI 配置 / 入口）。
# 仅在装了 lcov 时执行；不同 lcov 版本参数差异较大，故容错处理。
if command -v lcov >/dev/null 2>&1; then
  echo "🧹 过滤生成代码 / 入口文件..."
  lcov --remove "$LCOV" \
    '*.g.dart' '*.freezed.dart' '*.config.dart' '*.gen.dart' \
    '*/l10n/app_localizations*.dart' 'lib/main_*.dart' 'lib/main.dart' \
    -o "$LCOV" 2>/dev/null || echo "  (lcov 过滤跳过：版本差异，不影响原始数据)"
fi

# 用 awk 直接从 lcov.info 算总覆盖率（无需安装 lcov，跨版本稳定）。
echo "📊 覆盖率摘要："
awk -F: '
  /^LF:/ { found += $2 }
  /^LH:/ { hit += $2 }
  END {
    if (found > 0)
      printf "   行覆盖 Lines: %d/%d  (%.1f%%)\n", hit, found, hit * 100 / found
    else
      print "   （无覆盖数据）"
  }
' "$LCOV"

# 可选 HTML 报告
if [[ "${1:-}" == "--html" ]]; then
  if command -v genhtml >/dev/null 2>&1; then
    genhtml "$LCOV" -o coverage/html --quiet
    echo "🌐 HTML 报告：coverage/html/index.html"
  else
    echo "⚠️  未安装 genhtml（brew install lcov），跳过 HTML 报告。" >&2
  fi
fi
