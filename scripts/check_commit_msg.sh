#!/usr/bin/env bash
# M16/T16.2 Conventional Commits 校验（由 lefthook commit-msg 调用）。
# 用法：check_commit_msg.sh <commit-msg-file>
set -euo pipefail

MSG_FILE="${1:?需要 commit message 文件路径}"
HEADER="$(head -n1 "$MSG_FILE")"

# 放行自动生成的提交（merge / revert / fixup / squash）。
if printf '%s' "$HEADER" | grep -qE '^(Merge |Revert |fixup!|squash!)'; then
  exit 0
fi

# type(scope)!: subject —— type 必填、scope 可选、! 可选、冒号后需有描述。
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9_./-]+\))?!?: .+'

if ! printf '%s' "$HEADER" | grep -qE "$PATTERN"; then
  cat >&2 <<EOF
❌ commit message 不符合 Conventional Commits 规范：
   "$HEADER"

   正确格式：<type>(<scope>): <描述>
   type 可选值：feat fix docs style refactor perf test build ci chore revert
   示例：
     feat(env): 增加 staging flavor
     fix: 修复登录态丢失
     docs(readme): 更新运行说明
EOF
  exit 1
fi
