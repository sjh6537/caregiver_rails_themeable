class ApplicationAdminController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_breadcrumb
  before_action :set_webtitle
  layout :resolve_admin_layout

  private

  def set_breadcrumb
    @title = nil
    @title_sub = nil
  end

  def set_webtitle
    @webtitle = APP_CONFIG[:site_name]
  end

  def resolve_admin_layout
    return "admin" if lookup_context.exists?("admin", "layouts", false)

    "application"
  end
end
