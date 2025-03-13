module Admin
  class ShopsController < ApplicationAdminController
    include ApplicationHelper
    before_action :set_shop, only: %i[show edit update destroy]

    def index
      @title_sub = I18n.t(:Table, scope: 'Title')
      @shops = Shop.all
    end

    def new
      @title_sub = I18n.t(:New, scope: 'Title')
      @shop = Shop.new
      respond_to(&:html)
    end

    def create
      @title_sub = I18n.t(:New, scope: 'Title')
      @shop = Shop.new(shop_params)
      respond_to do |format|
        if @shop.save
          add_log(ACTION_NEW, LOG_ADMIN, current_admin.id, LOG_SHOP, @shop.id)
          format.html do
            redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Created, scope: 'Notice', name: @shop.name.to_s)
          end
        else
          format.html { render action: 'new', alert: I18n.t(:Created_Fail, scope: 'Notice', name: @shop.name.to_s) }
        end
      end
    end

    def show
      @title_sub = I18n.t(:Information, scope: 'Title')
      respond_to(&:html)
    end

    def edit
      @title_sub = I18n.t(:Edit, scope: 'Title')
    end

    def update
      @title_sub = I18n.t(:Edit, scope: 'Title')
      respond_to do |format|
        if @shop.update(shop_params)
          add_log(ACTION_EDIT, LOG_ADMIN, current_admin.id, LOG_SHOP, @shop.id)
          format.html do
            redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Updated, scope: 'Notice', name: @shop.name.to_s)
          end
        else
          format.html { render action: 'edit', alert: I18n.t(:Updated_Fail, scope: 'Notice', name: @shop.name.to_s) }
        end
      end
    end

    def destroy
      respond_to do |format|
        add_log(ACTION_DEL, LOG_ADMIN, current_admin.id, LOG_SHOP, @shop.id)
        if @shop.destroy
          format.html { redirect_to admin_shops_path, notice: I18n.t(:Deleted, scope: 'Notice', name: @shop.name.to_s) }
        else
          format.html do
            redirect_back fallback_location: '/', alert: I18n.t(:Deleted_Fail, scope: 'Notice', name: @shop.name.to_s)
          end
        end
      end
    end

    def import_file
      uploaded_file = params[:file]
      file_content = uploaded_file.read

      map_hash = Hash.from_xml(file_content)
      map_hash['kml']['Document']['Folder'].each do |folder|
        if folder.try(:[] , 'Placemark') != nil
          if folder['Placemark'].count { |key, _val| key == 'name' } >= 1

            parser_place_mark(folder['Placemark'])
          else
            folder['Placemark'].collect do |place_mark|
              parser_place_mark(place_mark)
            end
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to admin_shops_path, notice: '匯入成功' }
      end
    end

    private

    def set_shop
      @shop = Shop.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shop_params
      params.require(:shop).permit!
    end

    def set_breadcrumb
      @title = I18n.t(:SHOPS_TABLE, scope: 'Title')
      @title_sub = nil
    end

    def parser_place_mark(place_hash)
      map_id = ''
      name = nil
      address = nil
      service = nil
      phone = nil
      price = nil
      opening = nil
      pictures = []
      if place_hash.try(:[], 'ExtendedData').nil?
        puts "no id for #{place_hash['name']}"
      else

        name = place_hash['name'].chomp unless place_hash['name'].nil?
        place_hash['ExtendedData']['Data'].try(:each) do |data|
          if data['name'] == 'ID'
            return if data['value'].nil?

            map_id = data['value'].chomp.gsub("\n", '<br>')
            map_id = map_id[0..0] + map_id[2..9] if map_id[1..1] == '.'
          elsif data['name'].include? '住址'
            address = data['value'].chomp.gsub("\n", '<br>') unless data['value'].nil?
          elsif data['name'].include? '服務'
            service = data['value'].chomp.gsub("\n", '<br>') unless data['value'].nil?
          elsif data['name'].include? '電話'
            phone = data['value'].chomp.gsub("\n", '<br>') unless data['value'].nil?
          elsif data['name'].include? '價位'
            price = data['value'].chomp.gsub("\n", '<br>') unless data['value'].nil?
          elsif data['name'].include? '時間'
            opening = data['value'].chomp.gsub("\n", '<br>') unless data['value'].nil?
          elsif data['name'] == 'gx_media_links'
            pictures = data['value'].split
          end
        end

        # puts "#{map_id} #{name} , #{address} , #{service}, #{phone}, #{price}, #{opening}"
        # puts pictures.size
        # pictures.each do |p|
        #  puts p
        # end

        addr_postal = map_id[0..2].to_i
        addr_city = get_postal_city(addr_postal.to_i)
        category = map_id[3..4].to_i

        latitude = nil
        longitude = nil
        if place_hash.try(:[], 'Point') != nil
          point = place_hash['Point']['coordinates'].split(',')
          longitude = point[0].to_f
          latitude = point[1].to_f
        end

        shops = Shop.where('map_id == ?', map_id)
        if shops.count.zero?
          shop = Shop.new(is_show: true, map_id: map_id, name: name, phone: phone, address: address, price: price,
                          service: service, opening: opening, addr_city: addr_city, addr_postal: addr_postal, category: category, latitude: latitude, longitude: longitude)
          shop.save
        else
          shop = shops.first
          shop.update(is_show: true, name: name, phone: phone, address: address, price: price, service: service,
                      opening: opening, addr_city: addr_city, addr_postal: addr_postal, category: category, latitude: latitude, longitude: longitude)
          shop.pictures.destroy_all
        end
        pictures.each do |url|
          shop.pictures.create(url: url)
        end

      end
    end
  end
end
