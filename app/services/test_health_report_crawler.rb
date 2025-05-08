class TestHealthReportCrawler < HealthReportCrawler
  # 覆寫原始 fetch_and_process_health_data 方法，提供更多詳細資訊，方便測試
  def fetch_and_process_health_data
    # 取得所有使用者的身分證字號
    user_infos = @community.users.pluck(:id_card)
    # 除去空值
    raw_string = user_infos.reject(&:blank?)

    # 顯示處理的使用者資料
    users_info = {
      total_users: user_infos.size,
      valid_users: raw_string.size
    }

    # 將所有的使用者身分證字號加密
    all_ids = raw_string.join(',')
    encrypted_id = aes_cbc_encrypt(all_ids)

    # 從Asus的server爬所有使用者的量測資料
    current_date = Time.now
    date_string = current_date.strftime('%Y-%m-%d')
    start_time = "#{date_string} 00:00:00"
    end_time = "#{date_string} 23:59:59"

    begin
      vital_signs = get_vital_signs(encrypted_id, start_time, end_time)
      # 解密回來的資料
      user_info = aes_cbc_decrypt(vital_signs['data'])
      data_dict = extract_data(user_info)

      # 從爬回來的使用者身份證字號, 檢查是否有新的量測資料
      all_result = []
      fetched_data = {
        user_count: data_dict.keys.size,
        users: []
      }

      data_dict.keys.each do |id_card|
        # 檢查使用者是否存在
        user = @community.users.find_by(id_card: id_card)

        unless user
          # 記錄找不到的使用者
          fetched_data[:users] << { id_card: id_card, status: '使用者不存在' }
          next
        end

        data_dict_post = Marshal.load(Marshal.dump(data_dict[id_card])) # 深度複製
        pop_timestamp(data_dict_post) if defined?(pop_timestamp)

        # 檢查使用者是否有新的量測資料
        last_record = user.health_records.order('measure_time DESC').first

        if last_record && last_record.measure_time >= data_dict[id_card]['measure_time']
          fetched_data[:users] << {
            id_card: id_card,
            user_id: user.id,
            status: '資料已存在',
            last_record_time: last_record.measure_time,
            new_data_time: Time.at(data_dict[id_card]['measure_time'])
          }
          next
        end

        # 將新的量測資料加入到 all_result 陣列中
        all_result << {
          user_id: id_card,
          data: data_dict_post
        }

        fetched_data[:users] << {
          id_card: id_card,
          user_id: user.id,
          status: '發現新資料',
          last_record_time: last_record&.measure_time,
          new_data_time: Time.at(data_dict[id_card]['measure_time'])
        }
      end

      # 如果沒有新資料，回傳測試結果
      unless all_result.any?
        return {
          status: '無新資料',
          users_info: users_info,
          fetched_data: fetched_data
        }
      end

      # 將新的量測資料送回稻相顧資料庫(並推播)
      saved_reports = []
      errors = []

      all_result.each do |result|
        user = @community.users.find_by(id_card: result[:user_id])
        next unless user

        begin
          # 將資料轉換為 HealthRecord 物件
          report = UserHealthReport.new(
            user_id: user.id,
            measure_time: Time.at(result[:data]['measure_time']),
            bmi: result[:data]['BW']['bmi'],
            weight: result[:data]['BW']['bw'],
            heart_rate: result[:data]['BP']['hb'].to_i,
            blood_pressure1: result[:data]['BP']['sbp'].to_i,
            blood_pressure2: result[:data]['BP']['dbp'].to_i,
            blood_sugar: result[:data]['BS']['bs'].to_i,
            blood_oxygen: result[:data]['OX']['oxygen'].to_i,
            temperature: result[:data]['TP']['temperature'],
            hemoglobin: result[:data]['OX']['hb'],
            hematocrit: result[:data]['BS']['hct'],
            uric_acid: result[:data]['UA']['ua'],
            total_cholesterol: result[:data]['TC']['tc']
          )

          # 儲存健康紀錄
          if report.save
            log("健康紀錄已儲存，使用者 ID：#{user.id}")
            # 推播通知發送給用戶
            message_push(user.account, format_health_report(report))
            saved_reports << {
              user_id: user.id,
              id_card: result[:user_id],
              report_id: report.id,
              measure_time: report.measure_time
            }
          else
            error_message = "健康紀錄儲存失敗，使用者 ID：#{user.id}，錯誤：#{report.errors.full_messages.join(', ')}"
            log(error_message, :error)
            errors << {
              user_id: user.id,
              id_card: result[:user_id],
              errors: report.errors.full_messages
            }
          end
        rescue StandardError => e
          log("處理使用者 #{user.id} 資料時發生錯誤: #{e.message}", :error)
          errors << {
            user_id: user.id,
            id_card: result[:user_id],
            error: e.message
          }
        end
      end

      {
        status: '成功處理資料',
        users_info: users_info,
        fetched_data: fetched_data,
        processed: all_result.size,
        saved_reports: saved_reports,
        errors: errors
      }
    rescue StandardError => e
      {
        status: '處理資料過程中發生錯誤',
        error_message: e.message,
        error_backtrace: e.backtrace.take(10)
      }
    end
  end
end
