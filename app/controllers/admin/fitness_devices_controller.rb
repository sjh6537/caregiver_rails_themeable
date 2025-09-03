class Admin::FitnessDevicesController < ApplicationAdminController
  before_action :set_fitness_device, only: %i[edit update destroy usage_history bind_user unbind_user]

  def index
    @title_sub = '設備管理'
    @fitness_devices = if current_admin.super_admin?
                         FitnessDevice.includes(:fitness_device_type, :user, :community)
                       else
                         FitnessDevice.where(community_id: current_admin.community_id)
                                      .includes(:fitness_device_type, :user, :community)
                       end
    @fitness_devices = @fitness_devices.order(:name)
  end

  def new
    @title_sub = '新增設備'
    @fitness_device = FitnessDevice.new
    @fitness_device.community_id = current_admin.community_id unless current_admin.super_admin?
    @fitness_device_types = FitnessDeviceType.order(:name)
    @communities = get_available_communities
  end

  def create
    @fitness_device = FitnessDevice.new(fitness_device_params)
    @fitness_device.community_id = current_admin.community_id unless current_admin.super_admin?

    respond_to do |format|
      if @fitness_device.save
        format.html { redirect_to admin_fitness_devices_path, notice: '設備建立成功' }
      else
        @title_sub = '新增設備'
        @fitness_device_types = FitnessDeviceType.order(:name)
        @communities = get_available_communities
        format.html { render :new }
      end
    end
  end

  def edit
    @title_sub = '編輯設備'
    @fitness_device_types = FitnessDeviceType.order(:name)
    @communities = get_available_communities
    @users = User.where(community_id: @fitness_device.community_id).order(:name)
  end

  def update
    respond_to do |format|
      if @fitness_device.update(fitness_device_params)
        format.html { redirect_to admin_fitness_devices_path, notice: '設備更新成功' }
      else
        @title_sub = '編輯設備'
        @fitness_device_types = FitnessDeviceType.order(:name)
        @communities = get_available_communities
        @users = User.where(community_id: @fitness_device.community_id).order(:name)
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @fitness_device.fitness_device_usages.any?
      redirect_to admin_fitness_devices_path, alert: '此設備已有使用記錄，無法刪除'
    else
      @fitness_device.destroy
      redirect_to admin_fitness_devices_path, notice: '設備刪除成功'
    end
  end

  def usage_history
    @title_sub = "#{@fitness_device.name} - 使用記錄"
    @usage_records = @fitness_device.fitness_device_usages
                                    .includes(:user)
                                    .order(created_at: :desc)
                                    .limit(20)
                                    .offset(((params[:page]&.to_i || 1) - 1) * 20)
  end

  def bind_user
    user = User.find(params[:user_id])

    if user.community_id != @fitness_device.community_id
      render json: { error: '使用者與設備不在同一社區' }, status: :unprocessable_entity
      return
    end

    begin
      @fitness_device.update!(user_id: user.id)
      render json: {
        success: true,
        message: "成功綁定使用者 #{user.name}",
        current_user: user.name
      }
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def unbind_user
    @fitness_device.update!(user_id: nil)
    render json: {
      success: true,
      message: '成功解除使用者綁定'
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # AJAX 方法：根據社區取得使用者列表
  def get_users_by_community
    community_id = params[:community_id]
    users = User.where(community_id: community_id)
                .select(:id, :name, :email, :line_name, :id_card)
                .order(:name)

    render json: {
      users: users.map do |user|
        {
          id: user.id,
          name: user.name,
          email: user.email,
          line_name: user.line_name,
          id_card: user.id_card,
          display_text: "#{user.name} (#{user.line_name}) - #{user.id_card}"
        }
      end
    }
  end

  private

  def set_fitness_device
    @fitness_device = if current_admin.super_admin?
                        FitnessDevice.find(params[:id])
                      else
                        FitnessDevice.where(community_id: current_admin.community_id)
                                     .find(params[:id])
                      end
  end

  def fitness_device_params
    params.require(:fitness_device).permit(:name, :brand, :model, :serial_number,
                                           :mac_address, :ip_address, :location,
                                           :status, :img_path, :notes, :sort_order,
                                           :enabled, :fitness_device_type_id,
                                           :community_id, :device_id)
  end

  def get_available_communities
    if current_admin.super_admin?
      Community.order(:name)
    else
      Community.where(id: current_admin.community_id)
    end
  end

  def set_breadcrumb
    @title = '健身設備管理'
  end
end
