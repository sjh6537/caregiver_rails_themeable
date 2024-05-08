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

end