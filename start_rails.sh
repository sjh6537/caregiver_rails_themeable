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

# 確保 log 目錄存在
mkdir -p log

# 檢查 Sidekiq 是否已啟動
if ! pgrep -f "sidekiq" > /dev/null
then
    echo "啟動 Sidekiq 工作者..."
    nohup bundle exec sidekiq -e production -C config/sidekiq.yml > log/sidekiq.log 2>&1 &
    sleep 2
    if pgrep -f "sidekiq" > /dev/null; then
        echo "Sidekiq 已在背景執行中"
    else
        echo "警告: Sidekiq 啟動可能失敗，請檢查日誌"
    fi
else
    echo "Sidekiq 已在執行中"
fi

# 檢查 Rails 伺服器是否已啟動
if ! pgrep -f "rails server" > /dev/null
then
    echo "啟動 Rails 伺服器..."
    bundle exec rails server -e production -d
    sleep 2
    if pgrep -f "rails server" > /dev/null; then
        echo "Rails 伺服器已在背景執行中"
    else
        echo "警告: Rails 伺服器啟動可能失敗，請檢查日誌"
    fi
else
    echo "Rails 伺服器已在執行中"
fi

echo "所有服務已成功啟動並在背景執行中"
