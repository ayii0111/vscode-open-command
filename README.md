# vscode-open-command

A Claude Code command that opens the current session directory in VS Code — locally, without calling the model.

在 CC 輸入 `/code`（有自動提示），就會用 VS Code 開啟當前 session 的目錄，輸入框隨即清空，整個過程不會產生任何模型呼叫。

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/vscode-open-command/main/install.sh | bash
```

安裝後在 CC 執行 `/reload-plugins` 或重啟 CC 套用。

若 `~/.claude/commands/code.md` 已存在且不是本插件建立的，安裝會中止，不會覆蓋。

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/vscode-open-command/main/uninstall.sh | bash
```

## Requirements

- `bash`
- VS Code 的 `code` 指令：在 VS Code 執行「Shell Command: Install 'code' command in PATH」。macOS 上沒裝也會退回 `/Applications/Visual Studio Code.app` 內建的 `code`
- `python3`（選用）：用來從 hook 輸入讀取 session 目錄；沒有時改用 hook 的工作目錄

## 原理

- CC 認出 `/code` 時觸發 `UserPromptExpansion` hook，hook 在本機執行 `code <cwd>`
- hook 回傳 `continue:false` 中止這則 prompt，所以 command 內容從未送給模型，輸入框也會清空（`decision:block` 則會把 prompt 放回輸入框）
- hook 採 plugin 安裝；command 則由安裝腳本手動放進 `~/.claude/commands/`，指令提示才會是 `/code`，而非 `/vscode-open-command:code`
