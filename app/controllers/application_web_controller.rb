class ApplicationWebController < ApplicationController
	before_action :authenticate_user!
	#before_action :set_current_user

	def set_current_user
			@current_user = User.find(5)
	end

end
