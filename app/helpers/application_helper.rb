module ApplicationHelper

    def get_postal_selection(city_code)
        html_text = ""
        POSTAL_CODE.map do |p|
            if (p[:city]==city_code)
                tmp_text = "<option value=#{p[:code]} descrition=\"#{p[:name]}\">#{p[:name]}</option>"
                html_text += tmp_text
            end
        end
        html_text.html_safe
    end

    def get_city(code)
        CITY_CODE.select {|c| c[:code] == code}.first[:city]
    end

    def get_postal(code)
        POSTAL_CODE.select {|c| c[:code] == code}.first[:name]
    end

    def create_current_list
        User.all.map do |user|
            if !user.phone.nil?
                file = Rails.root.join('health/',"#{user.account}.#{user.phone}")
                File.open( file, "w") do |f|
                    f.write("#{user.account}.#{user.phone}\r\n")
                end
            end
        end
    end

    def append_user(account,phone)
        if !phone.nil?
            file = Rails.root.join('health/',"#{account}.#{phone}")
            File.open( file, "w") do |f|
                f.write("#{account}.#{phone}\r\n")
            end
        end
    end

    def request_category_all
        RequestCategory.where(is_show: true)
    end

    def request_category_text(id)
        if RequestCategory.find_by_id(id).nil?
            "其他"
        else
            RequestCategory.find_by_id(id).text
        end
    end

end