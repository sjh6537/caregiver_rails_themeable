class Admin::CommunityThemesController < ApplicationAdminController
  before_action :set_available_communities
  before_action :set_target_community
  before_action :set_breadcrumb

  def edit; end

  def update
    requested_purges = requested_purges_from_params

    if @community.update(community_theme_params.except(:id))
      purge_requested_assets!(requested_purges)
      redirect_to edit_admin_community_theme_path(community_id: @community.id), notice: "社群主題設定已更新"
    else
      flash.now[:alert] = @community.errors.full_messages.to_sentence.presence || "社群主題設定更新失敗"
      render :edit, status: :unprocessable_entity
    end
  end

  def reset_palette
    if @community.update(theme_settings: Community::DEFAULT_THEME_SETTINGS)
      redirect_to edit_admin_community_theme_path(community_id: @community.id), notice: "已重設為預設色盤"
    else
      redirect_to edit_admin_community_theme_path(community_id: @community.id), alert: "重設預設色盤失敗"
    end
  end

  def export_json
    payload = {
      version: 1,
      community: {
        id: @community.id,
        sn: @community.sn,
        name: @community.name
      },
      host: @community.host,
      theme_key: @community.theme_key,
      layout_preset: @community.layout_preset,
      theme_settings: @community.theme_settings_hash
    }

    send_data(
      JSON.pretty_generate(payload),
      filename: "community_theme_#{@community.sn.presence || @community.id}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.json",
      type: "application/json; charset=utf-8",
      disposition: "attachment"
    )
  end

  def import_json
    payload, parse_error = parse_theme_payload_from_params
    if parse_error.present?
      redirect_to edit_admin_community_theme_path(community_id: @community.id), alert: parse_error
      return
    end

    update_attrs = build_import_attributes(payload)
    if update_attrs.blank?
      redirect_to edit_admin_community_theme_path(community_id: @community.id), alert: "匯入內容沒有可更新的主題欄位"
      return
    end

    if @community.update(update_attrs)
      redirect_to edit_admin_community_theme_path(community_id: @community.id), notice: "主題 JSON 已匯入"
    else
      redirect_to edit_admin_community_theme_path(community_id: @community.id),
                  alert: @community.errors.full_messages.to_sentence.presence || "主題 JSON 匯入失敗"
    end
  end

  private

  def set_available_communities
    @communities = if current_admin.super_admin?
                     Community.enabled.sorted
                   elsif current_admin.community_id.present?
                     Community.where(id: current_admin.community_id).sorted
                   else
                     Community.none
                   end
  end

  def set_target_community
    @community =
      if current_admin.super_admin?
        resolve_super_admin_community
      else
        current_admin.community
      end

    return if @community.present?

    redirect_to admin_root_path, alert: "目前沒有可編輯的社群設定"
    nil
  end

  def resolve_super_admin_community
    candidate_id = params[:community_id].presence || params.dig(:community, :id).presence
    return @communities.find_by(id: candidate_id) if candidate_id.present?

    @communities.first
  end

  def community_theme_params
    params.require(:community).permit(
      :id,
      :host,
      :theme_key,
      :layout_preset,
      :theme_logo,
      :theme_cover_image,
      :theme_background_image,
      theme_settings: Community::DEFAULT_THEME_SETTINGS.keys
    )
  end

  def theme_import_params
    params.fetch(:theme_import, ActionController::Parameters.new).permit(:json_text, :file)
  end

  def parse_theme_payload_from_params
    import_params = theme_import_params
    raw_json =
      if import_params[:file].present?
        import_params[:file].read.to_s
      else
        import_params[:json_text].to_s
      end

    raw_json = raw_json.to_s.strip
    return [nil, "請上傳 JSON 檔案或貼上 JSON 內容"] if raw_json.blank?

    parsed = JSON.parse(raw_json)
    unless parsed.is_a?(Hash)
      return [nil, "JSON 格式錯誤：根節點必須是物件"]
    end

    payload = parsed["community_theme"].is_a?(Hash) ? parsed["community_theme"] : parsed
    [payload, nil]
  rescue JSON::ParserError => e
    [nil, "JSON 解析失敗：#{e.message}"]
  end

  def build_import_attributes(payload)
    source = payload.respond_to?(:to_h) ? payload.to_h : {}
    source = source.stringify_keys
    attrs = {}

    attrs[:theme_key] = source["theme_key"] if source["theme_key"].present?
    attrs[:layout_preset] = source["layout_preset"] if source["layout_preset"].present?
    attrs[:host] = source["host"].to_s.strip.presence if source.key?("host")

    imported_settings = imported_theme_settings(source)
    attrs[:theme_settings] = imported_settings if imported_settings.present?

    attrs.compact
  end

  def imported_theme_settings(source)
    settings_source =
      if source["theme_settings"].is_a?(Hash)
        source["theme_settings"]
      elsif source["colors"].is_a?(Hash)
        source["colors"]
      else
        source.slice(*Community::DEFAULT_THEME_SETTINGS.keys)
      end

    return nil unless settings_source.is_a?(Hash)

    normalized = normalize_hex_color_settings(settings_source)
    return nil if normalized.blank?

    @community.theme_settings_hash.merge(normalized)
  end

  def normalize_hex_color_settings(settings_hash)
    settings_hash
      .to_h
      .stringify_keys
      .slice(*Community::DEFAULT_THEME_SETTINGS.keys)
      .each_with_object({}) do |(key, value), result|
        color = value.to_s.strip
        result[key] = color if valid_hex_color?(color)
      end
  end

  def valid_hex_color?(value)
    value.match?(/\A#(?:\h{3}|\h{6}|\h{8})\z/)
  end

  def requested_purges_from_params
    community_params = params[:community] || {}

    {
      theme_logo: community_params[:remove_theme_logo] == "1",
      theme_cover_image: community_params[:remove_theme_cover_image] == "1",
      theme_background_image: community_params[:remove_theme_background_image] == "1"
    }
  end

  def purge_requested_assets!(requested_purges)
    @community.theme_logo.purge if requested_purges[:theme_logo] && @community.theme_logo.attached?
    @community.theme_cover_image.purge if requested_purges[:theme_cover_image] && @community.theme_cover_image.attached?
    @community.theme_background_image.purge if requested_purges[:theme_background_image] && @community.theme_background_image.attached?
  end

  def set_breadcrumb
    @title = "社群主題"
    @title_sub = @community&.name
  end
end
