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
    User.all.map do |user|
      next if user.id_card.nil?

      file = Rails.root.join('health/', "#{user.account}.#{user.id_card}")
      File.write(file, "#{user.account}.#{user.id_card}\r\n")
    end
  end

  def append_user(account, id_card)
    return if id_card.nil?

    file = Rails.root.join('health/', "#{account}.#{id_card}")
    File.write(file, "#{account}.#{id_card}\r\n")
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
end
