# -*- encoding : utf-8 -*-
class Admin::SessionsController < Devise::SessionsController
	layout 'admin_login'

	def new
		@webtitle = APP_CONFIG[:site_name]
		self.resource = resource_class.new(sign_in_params)
		clean_up_passwords(resource)
	end

end
