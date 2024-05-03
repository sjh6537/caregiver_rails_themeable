class ApplicationWebController < ApplicationController
	before_action :authenticate_user!


end
