class ApplicationWebController < ApplicationController
  before_action :set_user_based_on_environment

  private

  def set_user_based_on_environment
	if Rails.env.production?
	  authenticate_user! # 在 production 環境下驗證用戶
	else
	  set_current_user # 在 development 環境下設置預設用戶
	end
  end

  def set_current_user
	@current_user = User.find(1) # 設置預設用戶
  end
end
