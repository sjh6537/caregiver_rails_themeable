#!/bin/bash

# 顯示啟動資訊
echo "開始啟動 Rails 應用程式環境..."

# 檢查 Redis 是否已啟動，若未啟動則啟動它
if ! pgrep -x "redis-server" > /dev/null
then
    echo "啟動 Redis 伺服器..."
    service redis-server start || redis-server --daemonize yes
    sleep 2
    echo "Redis 伺服器已啟動"
else
    echo "Redis 伺服器已在執行中"
fi

# 啟動 Sidekiq
echo "啟動 Sidekiq 工作者..."
bundle exec sidekiq -e production -C config/sidekiq.yml -d
echo "Sidekiq 已在背景執行中"

# 啟動 Rails 伺服器
echo "啟動 Rails 伺服器..."
bundle exec rails server -e production -d

echo "系統已關閉"
