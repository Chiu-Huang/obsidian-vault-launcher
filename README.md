# ov — Windows 資料夾快速開啟 Obsidian Vault

工具位置：`C:\Users\ching\Desktop\Codex\random\obsidian-vault-launcher`

## 使用方式

在 Windows File Explorer 開啟任意資料夾，點擊網址列，輸入：

```cmd
ov .
```

也可以在 PowerShell 或 CMD 指定路徑：

```cmd
ov "D:\My Notes"
```

或不輸入參數時，使用命令提示字元的目前工作資料夾：

```cmd
ov
```

## 目前狀態（2026-10-30 本機實測）

- 已將本工具目錄加入 **使用者 PATH**，不需要管理員權限。
- 已登錄的 Vault：**可直接開啟**，使用 Obsidian 官方 `obsidian://open?vault=...` URI。
- 本機 Obsidian 安裝版本：**1.9.14**；官方命令列工具 `Obsidian.com` **尚不存在**。
- 尚未登錄的新資料夾：目前 `ov` 會提示缺少 CLI，並開啟 Obsidian 的 Vault Manager，需要手動選擇一次資料夾。
- 驗證結果：`ov.cmd "C:\Users\ching\Desktop\Codex\random"` 成功執行，返回碼 0。

## 讓新資料夾也可一行命令開啟（需要你手動完成）

1. 先備份重要筆記與 Obsidian 設定（例：`%APPDATA%\obsidian`）。
2. 從 [Obsidian 官方下載頁](https://obsidian.md/download) 安裝較新版 Obsidian；需要 **1.12.7 或更新的安裝程式**（僅在 App 內更新不一定更新 CLI 安裝組件）。
3. 開啟 Obsidian → **Settings → General → Command line interface**，啟用 CLI，依照畫面指示完成註冊。
4. 關閉並重新開啟終端機；輸入 `obsidian version` 確認 CLI 正常。此時再使用 `ov .`，工具會自動找到 `Obsidian.com`。
5. 對新資料夾執行 `ov .`。程式會透過 Obsidian CLI 的 `eval` 呼叫社群提出的內部 IPC `vault-open`。

**注意：** 新資料夾的自動開啟依賴 **非官方** Obsidian Electron IPC，未獲官方相容性保證；未來若更新造成失效，需修改 `ov-core.ps1`。工具不會直接修改全域 `obsidian.json` 的 Vault 登錄紀錄。

參考文件：
- 官方 CLI：<https://obsidian.md/help/cli>
- 社群 workaround：<https://forum.obsidian.md/t/open-a-folder-as-a-new-obsidian-vault-using-its-filepath-via-the-uri/112323>

## 如果輸入 `ov .` 找不到命令

已完成使用者 PATH 註冊，但 **目前已開啟的 Explorer / Terminal 可能仍沿用舊 PATH**。

1. 先新開一個 PowerShell / CMD，輸入 `where.exe ov`。
2. 如果還找不到，**登出 Windows 再登入**（或者重新啟動 Explorer），再測試。
3. 可用下列命令重複安裝 PATH（不會重複加入）：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\ching\Desktop\Codex\random\obsidian-vault-launcher\install-path.ps1"
```

在 PowerShell 也可不經 PATH 直接執行：

```powershell
& "C:\Users\ching\Desktop\Codex\random\obsidian-vault-launcher\ov.cmd" .
```

## 檔案說明

- `ov.cmd`：Windows File Explorer、CMD、PowerShell 使用的入口。
- `ov-core.ps1`：檢查路徑、查詢既有 Vault，並呼叫 URI 或 CLI。
- `install-path.ps1`：僅追加本目錄到**目前使用者**的 PATH。

`ov-core.ps1` 另支援 `-CheckOnly`（僅偵測、不開啟）：

```powershell
& "C:\Users\ching\Desktop\Codex\random\obsidian-vault-launcher\ov-core.ps1" -Folder "." -CheckOnly
```
