#!/usr/bin/env bash
# /code 的 UserPromptExpansion hook：用 VS Code 開啟當前 session 目錄
#
# CC 認出 /code → 觸發 UserPromptExpansion → 這裡開完 VS Code 後回傳 continue:false，
# commands/code.md 的內容從未送出，因此整個流程不會產生任何模型呼叫。
# 用 continue:false（而非 decision:block）中止，輸入框才會清空；block 會把 prompt 放回輸入框。
#
# 只依賴 bash：cwd 優先由 python3 從 hook 輸入解析，沒有 python3 時退回 hook 的工作目錄。
set -u
INPUT=$(cat)

# continue:false 中止這則 prompt；stopReason 會顯示給使用者
stop() {
	local r=${1//\\/\\\\}
	r=${r//\"/\\\"}
	printf '{"continue":false,"stopReason":"%s"}\n' "$r"
	exit 0
}

DIR=""
if command -v python3 >/dev/null 2>&1; then
	DIR=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)
fi
[ -n "$DIR" ] || DIR=$PWD
[ -d "$DIR" ] || stop "找不到目錄：$DIR"

# code 不在 PATH 時，退回 macOS 的預設安裝位置
CODE_BIN=$(command -v code 2>/dev/null)
MAC_CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
[ -z "$CODE_BIN" ] && [ -x "$MAC_CODE" ] && CODE_BIN=$MAC_CODE
[ -n "$CODE_BIN" ] || stop "找不到 code 指令：請在 VS Code 執行「Shell Command: Install 'code' command in PATH」"

"$CODE_BIN" "$DIR" >/dev/null 2>&1 || stop "code 指令執行失敗：$DIR"
stop "已用 VS Code 開啟 $DIR"
