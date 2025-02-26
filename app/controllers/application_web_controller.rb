class ApplicationWebController < ApplicationController
	#before_action :authenticate_user!
	before_action :set_current_user

	def set_current_user
			@current_user = User.find(1)
			#@profile = @current_user.profile
	end

end
