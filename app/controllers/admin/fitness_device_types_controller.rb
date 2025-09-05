class Admin::FitnessDeviceTypesController < ApplicationAdminController
  before_action :set_fitness_device_type, only: %i[show edit update destroy]
  before_action :set_breadcrumb

  def index
    @title_sub = t(:FITNESS_DEVICE_TYPES_TABLE, scope: 'Title')
    @fitness_device_types = FitnessDeviceType.order(:sort_order, :id)
  end

  def new
    @title_sub = t(:NEW_FITNESS_DEVICE_TYPE, scope: 'Title')
    @fitness_device_type = FitnessDeviceType.new
  end

  def create
    @fitness_device_type = FitnessDeviceType.new(fitness_device_type_params)

    respond_to do |format|
      if @fitness_device_type.save
        format.html do
          redirect_to admin_fitness_device_types_path,
                      notice: t(:Created, scope: 'Notice', name: @fitness_device_type.name)
        end
      else
        @title_sub = t(:NEW_FITNESS_DEVICE_TYPE, scope: 'Title')
        format.html { render :new }
      end
    end
  end

  def edit
    @title_sub = t(:EDIT_FITNESS_DEVICE_TYPE, scope: 'Title')
  end

  def show
    @title_sub = t(:FITNESS_DEVICE_TYPE_INFO, scope: 'Title')
  end

  def update
    respond_to do |format|
      if @fitness_device_type.update(fitness_device_type_params)
        format.html do
          redirect_to admin_fitness_device_types_path,
                      notice: t(:Updated, scope: 'Notice', name: @fitness_device_type.name)
        end
      else
        @title_sub = t(:EDIT_FITNESS_DEVICE_TYPE, scope: 'Title')
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @fitness_device_type.fitness_devices.any?
      redirect_to admin_fitness_device_types_path, alert: t(:Cannot_Delete_Has_Devices, scope: 'Notice')
    else
      name = @fitness_device_type.name
      @fitness_device_type.destroy
      redirect_to admin_fitness_device_types_path, notice: t(:Deleted, scope: 'Notice', name: name)
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
    @title = t(:Fitness_Management, scope: 'Sidebar.Item')
  end
end
