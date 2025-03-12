# 稻相顧多社區版本 應用程式 (使用MYSQL)

這是一個基於 Ruby on Rails 開發的照護相關應用程式，整合了 LINE Bot 功能以及背景工作處理。

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

6. 啟動開發伺服器
```bash
rails s
```

7. 啟動 Sidekiq (在另一個終端)
```bash
bundle exec sidekiq
```

## 部署說明

正式環境使用提供的部署腳本執行以下步驟:

```bash
sh update.sh
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
