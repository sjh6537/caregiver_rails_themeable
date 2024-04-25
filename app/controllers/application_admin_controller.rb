class ApplicationAdminController < ApplicationController
	before_action :authenticate_admin!
	before_action :set_breadcrumb
    before_action :set_webtitle
  
    private

    def set_breadcrumb
        @title = nil
        @title_sub = nil
    end

    def set_webtitle
        @webtitle = APP_CONFIG[:site_name]
    end
end
