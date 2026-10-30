# 給 AI 助理（Claude、Manus…）與人的更新指南

這個儲存庫是一個 GitHub Pages 網站。**`index.html` 不用改**，只改資料檔；推上 `main` 約 1 分鐘後網站自動更新。

**每完成一件事（做好、測試結果、發現問題、改變決定）就更新網站**，不要等人問。

> ⚠️ 網站通常是**公開**的，任何人都看得到。不要放：密碼、token、API key、電子郵件、電話、學生姓名與個資、電腦上的使用者路徑（`C:\Users\…`）、帳號編號。

## 要改哪個檔案

| 想做的事 | 檔案 |
|---|---|
| 網站名稱、分頁、儲存庫 | `data/site.json`（建站時改一次就好） |
| 更新某個目標的狀態 | `data/status.json` 的 `goals`，並更新 `updated` 日期 |
| 更新「下一步」 | `data/status.json` 的 `next` |
| 記錄新版本 | `data/versions.json` **最前面**加一筆 |
| 新增筆記 | `notes/YYYY-MM-DD-主題.md`，並在 `notes/index.json` **最前面**加一筆 |
| 新增 / 修改活動（項目） | `items/YYYY-MM-DD-代號.json`，一筆一個檔；同時在 `items/index.json` 加檔名。人也可以在網站按「＋ 新增」 |

### 目標狀態只能用這四個

`done`（完成）、`doing`（進行中）、`blocked`（卡住）、`todo`（待辦）

項目（活動）的狀態看 `data/site.json` 的 `itemStatus`，例如 `planning`、`registered`、`ongoing`、`done`。

### 版本紀錄格式

```json
{
  "version": "0.2",
  "date": "2026-03-15",
  "author": "Claude",
  "title": "一句話說明這版做了什麼",
  "changes": ["具體改變 1", "具體改變 2"]
}
```

- `author` 寫 `Claude`、`Manus` 或人的名字
- 小改 +0.1；完成一個大目標升到下一個整數（0.9 之後是 0.10，不是 1.0，除非真的完成大目標）

### 項目格式

```json
{
  "title": "名稱",
  "date": "2026-11-20",
  "status": "planning",
  "result": "成績（還沒結束就留空）",
  "summary": "一句話摘要",
  "facts": { "主辦單位": "○○○", "地點": "○○○" },
  "description": "詳細說明，可用 Markdown",
  "files_folders": [],
  "links": [{ "title": "簡章", "url": "https://..." }]
}
```

### 規則

- 不知道的寫 `待補` 或留空，**不要猜**
- 檔名只用英數字、`-`、`_`、`.`（網頁會拒絕其他檔名）
- Google 雲端硬碟 / 文件連結：先拿掉 `ouid=`（帳號編號）和 `usp=` 參數
- 對方說「只當參考、不改網站」的資料，就不要放上網站
- 更正錯誤時加一筆新版本說明更正，不要偷偷改掉舊紀錄

## Commit 訊息

一行說明，開頭標註是誰：

```
[Claude] v0.3：新增 3 月測試結果
[Manus] 補上活動報名連結
```

網站「更新紀錄」分頁直接顯示這些訊息，要讓人看得懂。

## 改之前、改之後

**改之前**
1. `git pull --rebase`：多個 AI / 多個人一起維護，先拿最新版本，避免互相覆蓋
2. 看 `data/versions.json` 第一筆，決定新的版本號

**改之後**
1. 檢查 JSON 格式（多一個或少一個逗號，整頁都會載入失敗）
2. 掃一次敏感資訊（見上方清單）
3. commit、push
4. 等 GitHub Pages 建置完成，打開網站確認看得到新內容（網址加 `?v=commit前7碼` 可以跳過瀏覽器快取）

`tools/publish.ps1` 會自動做 1～4。

## 這個網站的專屬規則（kappa 扭客研究站）

研究「線材種類與並列方式對扭擺扭力係數之影響研究」，隊伍 kappa 扭客。參加過三場比賽：永平高中校內科展 → 新北市科展 → 第二十五屆旺宏科學獎（SA25-782）。內容以最新的旺宏版說明書為準。

- **不要修改作者的原始檔**：`docs/*.pdf`（三份說明書）和 `pages/kappa.html`（作者原作網站）。發現錯誤時，寫進 `data/status.json` 的 `goals`（`status: "todo"`），必要時在 `notes/` 寫一篇筆記說明，由作者決定怎麼改。
- 數字要和說明書一致；轉動慣量一律用 I = 3.27×10⁻⁶ kg·m²（旺宏版已修正舊版 3.253×10⁻⁵ 的 10 倍錯誤）。
- 比賽放在 `items/`，狀態用 `data/site.json` 的 `itemStatus`：`planning` 準備中、`registered` 已報名、`ongoing` 已繳交、`done` 已結束。
- 項目的 `links.url` 只顯示 `https://` 開頭的網址；站內 PDF 請寫完整網址，例如 `https://malixian-hash.github.io/kappa-site/docs/macronix.pdf`。
- `pages/` 是獨立的互動頁面（`ribbon.html` 緞帶扭擺動畫、`wiretwist.html` WireTwist Lab、`kappa.html` kappa 扭客），從筆記、頁尾和「原始檔」分頁連過去；改 `ribbon.html`、`wiretwist.html` 時要保留現有功能。
- 圖片放 `assets/`，筆記裡用 `![說明](assets/檔名.png)`。
