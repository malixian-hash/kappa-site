# kappa 扭客研究站

科展研究「線材種類與並列方式對扭擺扭力係數之影響研究」的進度網站：https://malixian-hash.github.io/kappa-site/

使用「一般網站模板」：`index.html` 不用改，內容都在資料檔。分頁：目前進度、比賽專區、版本紀錄、分析筆記、原始檔、更新紀錄。

## 維護

- 規則寫在 `AGENTS.md`，人和 AI 助理（Claude、Manus）都照這份做
- 開場白：

  > 這個網站的儲存庫是 `malixian-hash/kappa-site`（網址 https://malixian-hash.github.io/kappa-site/）。請先讀 AGENTS.md，照規則更新。每完成一件事就更新網站，發布前跑 tools\publish.ps1。

- 發布（Windows）：`powershell -ExecutionPolicy Bypass -File tools\publish.ps1 -Message "[名字] v版本：說明"`

## 本機預覽

```
python -m http.server 8000
```

打開 http://localhost:8000 （直接雙擊 index.html 不行）。

## 檔案

| 檔案 | 用途 |
|---|---|
| `index.html` | 網站引擎（不用改） |
| `data/site.json` | 網站設定 |
| `data/status.json` | 目前進度、待辦、下一步 |
| `data/versions.json` | 版本紀錄 |
| `data/files.json` | 原始檔分頁的清單 |
| `items/*.json`、`items/index.json` | 比賽（一場一個檔） |
| `notes/*.md`、`notes/index.json` | 分析筆記 |
| `pages/` | 互動頁面：緞帶扭擺動畫、WireTwist Lab、kappa 扭客 |
| `docs/` | 三份說明書 PDF |
| `assets/` | 圖片 |
| `tools/publish.ps1` | 檢查 + 發布 |
