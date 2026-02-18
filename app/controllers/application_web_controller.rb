class ApplicationWebController < ApplicationController
  before_action :set_current_user
  layout :resolve_web_layout

  private

  def set_user_based_on_environment
    if Rails.env.production?
      authenticate_user! # 在 production 環境下驗證用戶
    else
      set_current_user # 在 development 環境下設置預設用戶
    end
  end

  def set_current_user
    # 驗證前將sn存入session
    set_community_by_token

    authenticate_user!
    # @current_user = User.find(1) # 設置預設用戶
  end

  def resolve_web_layout
    requested_layout = current_layout_preset
    return requested_layout if lookup_context.exists?(requested_layout, "layouts", false)

    "valex"
  end
end
