class Web::NoticeController < ApplicationWebController
  skip_before_action :set_current_user

  def error
    render :error, status: :ok
  end

  def not_found
    render :not_found, status: :not_found
  end
end
