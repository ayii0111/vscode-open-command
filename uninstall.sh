#!/usr/bin/env bash
set -e
NAME="vscode-open-command"
claude plugin uninstall "${NAME}@${NAME}"
claude plugin marketplace remove "$NAME"

# 只刪本插件建立的 /code 指令
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CMD_FILE="$CLAUDE_DIR/commands/code.md"
if grep -qF "($NAME)" "$CMD_FILE" 2>/dev/null; then
	rm -f "$CMD_FILE"
fi

echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
