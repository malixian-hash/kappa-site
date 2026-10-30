# kappa 扭客研究站

科展研究「線材種類與並列方式對扭擺扭力係數之影響研究」的網站。

- 網站內容：研究歷程、比賽紀錄、說明書版本、分析筆記、原始檔，以及兩個研究網站
- 由 Claude 與 Manus 共同維護，維護規則見 [AGENTS.md](AGENTS.md)

## 本機預覽

比賽資料是用 `fetch` 讀取的，請用本機伺服器開啟，不要直接雙擊 `index.html`：

```
python -m http.server 8000
```

然後打開 http://localhost:8000 。
