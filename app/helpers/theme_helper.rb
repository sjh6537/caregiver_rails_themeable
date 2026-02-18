module ThemeHelper
  def theme_css_variables
    if current_community.present?
      current_community.css_variables
    else
      Community::DEFAULT_THEME_SETTINGS.transform_keys do |key|
        "--community-color-#{key.tr('_', '-')}"
      end
    end
  end

  def community_logo_url
    return url_for(current_community.theme_logo) if current_community&.theme_logo&.attached?
    return current_community.logo if current_community&.respond_to?(:logo) && current_community.logo.present?

    nil
  end

  def community_cover_image_url
    return nil unless current_community&.theme_cover_image&.attached?

    url_for(current_community.theme_cover_image)
  end

  def community_background_image_url
    return nil unless current_community&.theme_background_image&.attached?

    url_for(current_community.theme_background_image)
  end
end
