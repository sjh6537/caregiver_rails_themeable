class Admin::SessionsController < Devise::SessionsController
  layout 'admin_login'

  def new
    @webtitle = APP_CONFIG[:site_name]
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'You have been logged out.'
  end
end
