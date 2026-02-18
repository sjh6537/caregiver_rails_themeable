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
