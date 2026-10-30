# AGENTS.md：kappa 扭客研究站維護規則

這個網站由 Claude 與 Manus 共同維護。任何 AI 助理（或人）修改網站前，請先讀完這份文件。

## 專案是什麼

科展研究「線材種類與並列方式對扭擺扭力係數之影響研究」的網站，隊伍名稱 kappa 扭客。
研究參加過三場比賽，依時間先後：永平高中校內科展 → 新北市科展 → 第二十五屆旺宏科學獎（SA25-782）。
內容以最新的旺宏版說明書為準。

網站是純靜態 HTML，放在 GitHub Pages，沒有建置步驟，改完 push 到 `main` 就會上線。

## 檔案結構

| 路徑 | 內容 |
| --- | --- |
| `index.html` | 主站：全站搜尋、分頁列，以及目前進度、比賽專區、版本紀錄、分析筆記、原始檔、更新紀錄六個分頁，以及「緞帶」專題分頁（`id="view-ribbon"`，含互動動畫） |
| `contests/*.json` | 比賽專區的資料，一場比賽一個檔案 |
| `contests/index.json` | 所有比賽檔名的清單（備援用，見下方） |
| `assets/` | 圖片，例如 `fig7-double-wire.png`（雙線並列扭轉示意圖） |
| `pages/wiretwist.html` | WireTwist Lab 研究網站（分頁內嵌） |
| `pages/kappa.html` | kappa 扭客研究網站（分頁內嵌） |
| `docs/*.pdf` | 三份說明書原始檔：`yongping.pdf`、`ntpc.pdf`、`macronix.pdf` |

## 常見工作

### 新增一場比賽

1. 在 `contests/` 新增一個檔案，檔名用 `YYYY-MM-DD-英文代稱.json`，例如 `2026-12-22-yphs-science-fair.json`。日期不確定時用年份開頭。
2. 內容照下面的格式，沒有資料的欄位留空字串，不要刪掉欄位。
3. 把新檔名加進 `contests/index.json`。
4. 在 `index.html` 的「更新紀錄」分頁最上面加一筆紀錄。

```json
{
  "title": "比賽名稱",
  "status": "準備中",
  "date": "2026-12-22",
  "organizer": "主辦單位",
  "location": "地點",
  "team": "隊伍 / 作品名稱",
  "category": "科別 · 組別",
  "code": "參賽編號",
  "result": "成績，例如：決賽入圍",
  "summary": "一兩句話的簡介",
  "notes": "備註",
  "timeline": [
    { "date": "2026-10-20", "text": "完成報名", "done": true },
    { "date": "2026-11-13", "text": "第一階段說明書繳交截止", "done": false }
  ],
  "links": [
    { "label": "作品說明書（PDF）", "href": "docs/macronix.pdf" }
  ]
}
```

- `status` 只能是 `準備中`、`已報名`、`已繳交`、`已結束` 其中之一。
- `date` 用 `YYYY-MM-DD`，比賽會依日期由新到舊排列。
- `links.href` 只接受 `https://` 開頭的網址，或站內的 `docs/`、`pages/` 路徑。

### 更新比賽進度

直接改那場比賽的 JSON 檔，例如把時程的 `done` 改成 `true`、填上 `result`。

### 更新「目前進度」「分析筆記」「版本紀錄」

這三個分頁的內容直接寫在 `index.html` 裡，各自是 `id="view-progress"`、`id="view-notes"`、`id="view-versions"` 的 `<section>`。照現有的格式新增或修改，新的項目放最上面。

### 新增一個分頁

在 `index.html` 底部 `<script>` 裡的 `TABS` 陣列加一行，並在 `<main>` 裡加一個 `id="view-<id>"` 的 `<section class="view pane" hidden>`。全站搜尋會自動把新分頁的內容收進去。

## 規則

- 全部使用繁體中文。
- 數字要和說明書一致；如果發現說明書的數字有錯，寫進「分析筆記」，不要直接改掉研究數據。
- 轉動慣量一律用 I = 3.27×10⁻⁶ kg·m²（旺宏版已修正舊版 3.253×10⁻⁵ 的 10 倍錯誤）。
- 不要放學生的個人資料（姓名、電話、照片）除非使用者明確要求。
- 每次修改都在「更新紀錄」分頁加一筆，寫日期與改了什麼，並在 commit 訊息說明。
- 改完用瀏覽器打開 `index.html` 確認：分頁能切換、搜尋找得到新內容、手機寬度不會左右捲動。
