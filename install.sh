#!/usr/bin/env bash
set -e
NAME="vscode-open-command"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CMD_FILE="$CLAUDE_DIR/commands/code.md"
MARK="($NAME)"

# 已有別人的 /code 指令就不覆蓋，避免蓋掉使用者原有的設定
if [ -e "$CMD_FILE" ] && ! grep -qF "$MARK" "$CMD_FILE" 2>/dev/null; then
	echo "✗ $CMD_FILE 已存在且不是本插件建立的，為避免覆蓋已中止安裝。" >&2
	exit 1
fi

# 本機執行：用本地路徑
if [ -f "$(dirname "$0")/.claude-plugin/plugin.json" ]; then
	DIR="$(cd "$(dirname "$0")" && pwd)"
	claude plugin marketplace add "$DIR"
else
	# curl | bash：用 GitHub source
	claude plugin marketplace add "ayii0111/$NAME"
fi
claude plugin install "${NAME}@${NAME}"

# command 手動放進 commands/，指令提示才會是 /code 而非 /vscode-open-command:code
mkdir -p "$CLAUDE_DIR/commands"
rm -f "$CMD_FILE"
printf -- '---\ndescription: %s 用 VS Code 開啟當前目錄（本機執行，不呼叫模型）\ndisable-model-invocation: true\n---\n' "$MARK" >"$CMD_FILE"

echo "✓ 安裝完成。在 CC 執行 /reload-plugins 或重啟 CC 套用。"
