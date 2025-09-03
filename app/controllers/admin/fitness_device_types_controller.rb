class Admin::FitnessDeviceTypesController < ApplicationAdminController
  before_action :set_fitness_device_type, only: %i[show edit update destroy]
  before_action :set_breadcrumb

  def index
    @title_sub = '設備類型管理'
    @fitness_device_types = FitnessDeviceType.order(:sort_order, :id)
  end

  def new
    @title_sub = '新增設備類型'
    @fitness_device_type = FitnessDeviceType.new
  end

  def create
    @fitness_device_type = FitnessDeviceType.new(fitness_device_type_params)

    respond_to do |format|
      if @fitness_device_type.save
        format.html { redirect_to admin_fitness_device_types_path, notice: '設備類型建立成功' }
      else
        @title_sub = '新增設備類型'
        format.html { render :new }
      end
    end
  end

  def edit
    @title_sub = '編輯設備類型'
  end

  def show
    @title_sub = '查看設備類型'
  end

  def update
    respond_to do |format|
      if @fitness_device_type.update(fitness_device_type_params)
        format.html { redirect_to admin_fitness_device_types_path, notice: '設備類型更新成功' }
      else
        @title_sub = '編輯設備類型'
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @fitness_device_type.fitness_devices.any?
      redirect_to admin_fitness_device_types_path, alert: '此設備類型已有設備使用，無法刪除'
    else
      @fitness_device_type.destroy
      redirect_to admin_fitness_device_types_path, notice: '設備類型刪除成功'
    end
  end

  private

  def set_fitness_device_type
    @fitness_device_type = FitnessDeviceType.find(params[:id])
  end

  def fitness_device_type_params
    params.require(:fitness_device_type).permit(:name, :description, :icon, :icon_color, :enabled, :sort_order, :notes)
  end

  def set_breadcrumb
    @title = '健身設備管理'
  end
end
