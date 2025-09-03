class Admin::FitnessDeviceUsagesController < ApplicationAdminController
  before_action :set_usage_record, only: %i[show update destroy]
  before_action :set_breadcrumb, only: %i[index show]

  def index
    @usage_records = build_query
    @avg_duration = calculate_average_duration(@usage_records)
  end

  def show
  end

  def update
    if params.dig(:fitness_device_usage, :action) == 'end_usage' && @usage_record.in_use?
      if @usage_record.end_usage!
        redirect_to admin_fitness_device_usage_path(@usage_record),
                    notice: '成功結束設備使用'
      else
        redirect_to admin_fitness_device_usage_path(@usage_record),
                    alert: '結束使用失敗'
      end
    else
      redirect_to admin_fitness_device_usage_path(@usage_record),
                  alert: '無效的操作'
    end
  end

  def destroy
    device_name = @usage_record.fitness_device.name
    user_name = @usage_record.user.name

    if @usage_record.destroy
      redirect_to admin_fitness_device_usages_path,
                  notice: "成功刪除 #{user_name} 的 #{device_name} 使用記錄"
    else
      redirect_to admin_fitness_device_usages_path,
                  alert: '刪除使用記錄失敗'
    end
  end

  protected

  def available_communities
    if current_admin.super_admin?
      Community.ordered
    else
      Community.where(id: current_admin.community_id).ordered
    end
  end
  helper_method :available_communities

  def available_devices
    devices = FitnessDevice.joins(:community)

    if params[:community_id].present?
      devices = devices.where(community_id: params[:community_id])
    elsif !current_admin.super_admin?
      devices = devices.where(community_id: current_admin.community_id)
    end

    devices.includes(:fitness_device_type).ordered
  end
  helper_method :available_devices

  private

  def set_usage_record
    @usage_record = FitnessDeviceUsage.find(params[:id])

    # 檢查權限
    return if current_admin.super_admin? || @usage_record.fitness_device.community_id == current_admin.community_id

    redirect_to admin_fitness_device_usages_path, alert: '您沒有權限查看此記錄'
  end

  def build_query
    usages = FitnessDeviceUsage.includes(:user, fitness_device: %i[community fitness_device_type])

    # 社區權限過濾
    unless current_admin.super_admin?
      usages = usages.joins(fitness_device: :community)
                     .where(fitness_devices: { community_id: current_admin.community_id })
    end

    # 社區篩選
    if params[:community_id].present?
      usages = usages.joins(fitness_device: :community)
                     .where(fitness_devices: { community_id: params[:community_id] })
    end

    # 設備篩選
    usages = usages.where(fitness_device_id: params[:device_id]) if params[:device_id].present?

    # 狀態篩選
    usages = usages.where(status: params[:status]) if params[:status].present?

    # 日期篩選
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        usages = usages.where(start_time: date.beginning_of_day..date.end_of_day)
      rescue ArgumentError
        # 忽略無效日期
      end
    end

    # 排序和分頁
    usages = usages.order(start_time: :desc)

    # 如果有 Kaminari gem，使用分頁
    if defined?(Kaminari) && usages.respond_to?(:page)
      usages.page(params[:page]).per(20)
    else
      usages.limit(100)
    end
  end

  def calculate_average_duration(usages)
    completed_usages = usages.where(status: :completed).where.not(duration_minutes: nil)

    if completed_usages.any?
      completed_usages.average(:duration_minutes)
    else
      0
    end
  end

  def set_breadcrumb
    @title = '健身設備管理'
    @title_sub = '使用記錄'
  end
end
