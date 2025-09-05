class Admin::FitnessDevicesController < ApplicationAdminController
  before_action :set_fitness_device, only: %i[edit update destroy usage_history bind_user unbind_user]

  def index
    @title_sub = t(:FITNESS_DEVICES_TABLE, scope: 'Title')
    @fitness_devices = if current_admin.super_admin?
                         FitnessDevice.includes(:fitness_device_type, :user, :community)
                       else
                         FitnessDevice.where(community_id: current_admin.community_id)
                                      .includes(:fitness_device_type, :user, :community)
                       end
    @fitness_devices = @fitness_devices.order(:name)
  end

  def new
    @title_sub = t(:NEW_FITNESS_DEVICE, scope: 'Title')
    @fitness_device = FitnessDevice.new
    @fitness_device.community_id = current_admin.community_id unless current_admin.super_admin?
    @fitness_device.status = 'normal' # 設定預設狀態為正常
    @fitness_device.enabled = true # 設定預設為啟用
    @fitness_device.sort_order = 0 # 設定預設排序為 0
    @fitness_device_types = FitnessDeviceType.order(:name)
    @communities = get_available_communities
  end

  def create
    @fitness_device = FitnessDevice.new(fitness_device_params)
    @fitness_device.community_id = current_admin.community_id unless current_admin.super_admin?

    respond_to do |format|
      if @fitness_device.save
        format.html do
          redirect_to admin_fitness_devices_path, notice: t(:Created, scope: 'Notice', name: @fitness_device.name)
        end
      else
        @title_sub = t(:NEW_FITNESS_DEVICE, scope: 'Title')
        @fitness_device_types = FitnessDeviceType.order(:name)
        @communities = get_available_communities
        format.html { render :new }
      end
    end
  end

  def edit
    @title_sub = t(:EDIT_FITNESS_DEVICE, scope: 'Title')
    @fitness_device_types = FitnessDeviceType.order(:name)
    @communities = get_available_communities
    @users = User.where(community_id: @fitness_device.community_id).order(:name)
  end

  def update
    respond_to do |format|
      if @fitness_device.update(fitness_device_params)
        format.html do
          redirect_to admin_fitness_devices_path, notice: t(:Updated, scope: 'Notice', name: @fitness_device.name)
        end
      else
        @title_sub = t(:EDIT_FITNESS_DEVICE, scope: 'Title')
        @fitness_device_types = FitnessDeviceType.order(:name)
        @communities = get_available_communities
        @users = User.where(community_id: @fitness_device.community_id).order(:name)
        format.html { render :edit }
      end
    end
  end

  def destroy
    name = @fitness_device.name
    @fitness_device.destroy
    redirect_to admin_fitness_devices_path, notice: t(:Deleted_With_Usage_Records, scope: 'Notice', name: name)
  end

  def usage_history
    @title_sub = "#{@fitness_device.name} - #{t(:Usage_History, scope: 'Table')}"
    @usage_records = @fitness_device.fitness_device_usages
                                    .includes(:user)
                                    .order(created_at: :desc)
                                    .limit(20)
                                    .offset(((params[:page]&.to_i || 1) - 1) * 20)
  rescue ActiveRecord::RecordNotFound, NoMethodError
    redirect_to admin_fitness_devices_path, alert: t(:Device_Not_Found, scope: 'Notice')
  end

  def bind_user
    user = User.find(params[:user_id])

    if user.community_id != @fitness_device.community_id
      render json: { error: t(:User_Device_Different_Community, scope: 'Notice') }, status: :unprocessable_entity
      return
    end

    begin
      ActiveRecord::Base.transaction do
        @fitness_device.update!(user_id: user.id)

        # 建立一筆使用記錄，標記為使用中，記錄開始時間
        FitnessDeviceUsage.create!(
          fitness_device: @fitness_device,
          user: user,
          start_time: Time.current,
          status: :in_use
        )
      end

      render json: {
        success: true,
        message: t(:Bind_User_Success, scope: 'Notice', user_name: user.name),
        current_user: user.name
      }
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def unbind_user
    # 使用 model 中的封裝方法來處理解除綁定與寫入使用記錄結束時間
    @fitness_device.unbind_user!
    render json: {
      success: true,
      message: t(:Unbind_User_Success, scope: 'Notice')
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # AJAX 方法：根據社區取得使用者列表
  def get_users_by_community
    community_id = params[:community_id]
    users = User.where(community_id: community_id)
                .where.not(name: [nil, ''])
                .select(:id, :name, :email, :id_card)
                .order(:name)

    render json: {
      users: users.map do |user|
        {
          id: user.id,
          name: user.name,
          email: user.email,
          id_card: user.id_card,
          display_text: "#{user.name} - #{user.id_card}"
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
    @title = t(:Fitness_Management, scope: 'Sidebar.Item')
  end
end
