# 稻相顧多社區版本 應用程式 (使用MYSQL)

這是一個基於 Ruby on Rails 開發的照護相關應用程式，整合了 LINE Bot 功能以及背景工作處理。

## Themeable 多社群架構（Rails 7/8 相容）

本專案已移除舊版 `themes_on_rails`，改用 Rails 原生方式做主題切換：

- 設計文件：`docs/theme_design.md`

- `Community` 新增 `theme_key` / `layout_preset` / `theme_settings` / `host`
- `ApplicationController` 透過 `prepend_view_path` 依序套用：
  1. `app/themes/communities/<sn>/views`
  2. `app/themes/<theme_key>/views`
  3. 預設 fallback（`valex` 或 `admin`）
- `theme_settings` 會注入成 CSS Variables（`--community-color-*`）
- `Community` 支援 `theme_logo / theme_cover_image / theme_background_image`（ActiveStorage）

### 每個社群覆蓋單一 view 的做法

例如要覆蓋 `Web::DashboardController#index`：

```bash
app/themes/communities/demo/views/web/dashboard/index.html.erb
```

找不到時會自動 fallback 到 `app/themes/valex/views/web/dashboard/index.html.erb`。

### 後台主題可視化設定

管理員可在後台直接調整主題與圖檔：

- 路徑：`/community_theme/edit`
- 功能：`theme_key`、`layout_preset`、顏色（含即時預覽）、Logo/封面/背景圖上傳
- 工具：一鍵「重設為預設色盤」、主題 JSON 匯入/匯出
- 權限：
  - `super_admin` 可切換不同社群編輯
  - 一般管理員僅可編輯自己的社群

## Docker Compose 開發環境

本專案提供 `Dockerfile.dev` + `docker-compose.dev.yml`，可用同一套環境開發 Web 與 Sidekiq：

```bash
docker compose -f docker-compose.dev.yml up --build
```

啟動後：

- Web: `http://localhost:3000`
- MySQL: `localhost:3306`
- Redis: `localhost:6379`
- Sidekiq 使用同一份程式碼與 Gem 環境

停止：

```bash
docker compose -f docker-compose.dev.yml down
```

## GitHub Actions CI

已新增 workflow：`.github/workflows/ci.yml`，在 push / PR 時會自動執行：

1. 安裝 Ruby 與系統套件（mysql client dev）
2. `bin/rails db:create db:migrate`
3. `bin/rails zeitwerk:check`
4. 檢查 `test/**/*_test.rb` 是否存在（沒有測試會直接 fail）
5. `bin/rails test`

目前預設已附上一個 smoke test：`test/integration/health_check_test.rb`。

## 系統需求

* Ruby 版本: 3.2.3
* Rails 版本: 7.1.3+
* 資料庫: MySQL 5.5.8+
* Redis (用於 Sidekiq)

## 主要功能

* LINE Bot 整合
* 多方用戶登入 (使用 Devise)
* 背景工作處理 (使用 Sidekiq)
* 多主題支援

## 安裝與配置

### 系統依賴

確保系統已安裝:
- Ruby 3.2.3
- MySQL
- Redis

### 安裝步驟

1. 複製專案(分支 padifield)
```bash
git clone -b padifield [repository_url] --depth=1
cd caregiver_rails
```
2. 產生master.key與credentials.yml.enc
```bash
EDITOR=nano rails credentials:edit
```

3. 安裝 gem 依賴
```bash
bundle install
```

4. 資料庫設定
確保 config/database.yml 配置正確，預設配置為:
```yaml
default:
  adapter: mysql2
  encoding: utf8mb4
  pool: 5
  username: sa
  password: taiwan
  host: db
  port: 3306
```

5. 建立資料庫及執行遷移
```bash
rake db:create
rake db:migrate
```

6. 啟動開發伺服器(測試環境)
```bash
rails s
```

7. 啟動 Sidekiq (在另一個終端)
```bash
bundle exec sidekiq
```

## 開發環境（Docker）

此專案在 Docker 環境下執行，常見服務包含 web / db / nginx。

1. 啟動容器（在部署專案的 compose 目錄）
```bash
docker compose up -d
```

2. 檢查容器狀態
```bash
docker ps
```

3. 追蹤 web 容器日誌
```bash
docker logs -f padi_my_deploy-web-1
```

4. 進入 web 容器執行指令
```bash
docker exec -it padi_my_deploy-web-1 bash
```

## 正式環境設定(需加上 RAILS_ENV=production)
```bash
rails db:migrate RAILS_ENV=production
```

## 開發環境測試網址（macOS）

macOS 可使用 `lvh.me` 解析至本機並支援子網域：

- 會員端：`http://lvh.me:3000`
- 管理端：`http://admin.lvh.me:3000/login`

若使用其他 Port，請自行替換。

## LINE 登入與 ngrok

本專案使用 LINE Login（回呼路徑為 `/callback/`），開發時請用 ngrok 對外。

1. 啟動 ngrok（對外轉發 3000）
```bash
ngrok http 3000
```

2. 將 LINE Developers Console 的 Callback URL / LIFF Endpoint URL 指向 ngrok

例如：

- Callback URL：`https://<你的-ngrok-網域>/callback/`
- LIFF Endpoint URL：`https://<你的-ngrok-網域>/`

3. 測試登入

用 LINE App 開啟 LIFF URL 或直接造訪 `https://<你的-ngrok-網域>/login`。

## 部署說明

正式環境使用提供的部署腳本執行以下步驟:

```bash
sh update.sh
```

或者登入 web 容器後手動執行:
```bash
sh start_rails.sh
```

此腳本會:
1. 執行資料庫遷移
2. 預編譯資產
3. 在背景啟動生產環境的 Rails 伺服器 (在 port 5000)

## 服務

* Web 伺服器: Puma
* 背景工作: Sidekiq
* 資料庫: MySQL
* 快取: Redis

## LINE 整合

此應用程式整合了 LINE Bot API，使用 oauth2 來處理 LINE Messageing token。

## 維護

關於日誌管理，系統會自動備份日誌，可在 log_backup 目錄中找到壓縮的日誌文件。
