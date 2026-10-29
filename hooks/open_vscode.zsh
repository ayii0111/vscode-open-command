#!/bin/zsh

# 別名 無: /code 的 UserPromptExpansion hook，用 VS Code 開啟當前 session 目錄
# CC 認出 /code → 觸發 UserPromptExpansion → 這裡開完 VS Code 後回傳 continue:false，
# user-commands/code.md 的內容從未送出，因此整個流程不會產生任何模型呼叫。
# 用 continue:false（而非 decision:block）中止，輸入框才會清空；block 會把 prompt 放回輸入框。

local payload=$(command cat)
local target_dir=$(print -r -- $payload | command jq -r '.cwd // empty' 2>/dev/null)
[[ $target_dir ]] || target_dir=$PWD

local reason=""
if ! [[ -d $target_dir ]]; then
  reason="找不到目錄：$target_dir"
elif command code $target_dir >/dev/null 2>&1; then
  reason="已用 VS Code 開啟 $target_dir"
else
  reason="code 指令執行失敗（確認 VS Code 的 code 指令已安裝到 PATH）"
fi

command jq -cn --arg r $reason '{continue:false, stopReason:$r}'

unset payload target_dir reason
return 0
