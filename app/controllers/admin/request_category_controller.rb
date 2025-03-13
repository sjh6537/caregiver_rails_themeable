module Admin
  class RequestCategoryController < ApplicationAdminController
    # before_action :set_category, only: [:switch]

    def index
      @title_sub = I18n.t(:Table, scope: 'Title')
      @categories = RequestCategory.all
    end

    def switch
      id = params[:id]
      @category = RequestCategory.find_by_id(id)
      @category&.update(is_show: !@category.is_show)
      respond_to do |format|
        format.html { redirect_to admin_request_category_index_path }
      end
    end

    def new
      @title_sub = I18n.t(:New, scope: 'Title')
      @category = RequestCategory.new
      respond_to(&:html)
    end

    def create
      @title_sub = I18n.t(:New, scope: 'Title')
      @category = RequestCategory.new(category_params)
      respond_to do |format|
        if @category.save
          add_log(ACTION_NEW, LOG_ADMIN, current_admin.id, LOG_REQUEST_CATEGORY, @category.id)
          format.html do
            redirect_to admin_request_category_index_path,
                        notice: I18n.t(:Created, scope: 'Notice', name: @category.text.to_s)
          end
        else
          format.html { render action: 'new', alert: I18n.t(:Created_Fail, scope: 'Notice', name: @category.text.to_s) }
        end
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:request_category).permit!
    end

    def set_breadcrumb
      @title = I18n.t(:REQUEST_CATEGORY_TABLE, scope: 'Title')
      @title_sub = nil
    end
  end
end
