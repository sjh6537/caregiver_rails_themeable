module ApplicationHelper
  def get_postal_selection(city_code)
    html_text = ''
    POSTAL_CODE.map do |p|
      if p[:city] == city_code
        tmp_text = "<option value=#{p[:code]} descrition=\"#{p[:name]}\">#{p[:name]}</option>"
        html_text += tmp_text
      end
    end
    html_text.html_safe
  end

  def get_city(code)
    city = CITY_CODE.select { |c| c[:code] == code }.first
    return city[:city] unless city.nil?

    nil
  end

  def get_postal_city(postal_code)
    postal = POSTAL_CODE.select { |c| c[:code] == postal_code }.first
    return postal[:city] unless postal.nil?

    nil
  end

  def get_postal(code)
    postal = POSTAL_CODE.select { |c| c[:code] == code }.first
    return postal[:name] unless postal.nil?

    nil
  end

  def create_current_list
  end

  def append_user(account, id_card)
  end

  def request_category_all
    RequestCategory.where(is_show: true)
  end

  def request_category_text(id)
    if RequestCategory.find_by_id(id).nil?
      '其他'
    else
      RequestCategory.find_by_id(id).text
    end
  end

  # 計算時間差距的輔助方法
  def time_distance_in_words(from_time, to_time = Time.current)
    return '' if from_time.nil?

    distance_in_minutes = ((to_time - from_time) / 1.minute).round

    case distance_in_minutes
    when 0..1
      '1分鐘內'
    when 2..44
      "#{distance_in_minutes}分鐘"
    when 45..89
      '約1小時'
    when 90..1439
      "約#{(distance_in_minutes.to_f / 60).round}小時"
    when 1440..2519
      '約1天'
    when 2520..43_199
      "約#{(distance_in_minutes.to_f / 1440).round}天"
    when 43_200..86_399
      '約1個月'
    when 86_400..525_599
      "約#{(distance_in_minutes.to_f / 43_200).round}個月"
    else
      "約#{(distance_in_minutes.to_f / 525_600).round}年"
    end
  end

end
