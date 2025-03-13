class Shop < ActiveRecord::Base
  include ApplicationHelper

  validates :map_id, presence: true, uniqueness: true

  has_many :coupons, dependent: :destroy
  has_many :pictures, dependent: :destroy, class_name: 'ShopPicture', foreign_key: 'shop_id'

  def city
    get_city(addr_city)
  end

  def postal
    get_postal(addr_postal)
  end

  def all_address
    city.to_s + postal.to_s + address.to_s
  end

  def show_text
    if is_show == true
      '顯示'
    else
      '不顯示'
    end
  end

  def category_name
    SHOP_CATEGORY_CODE.map do |c|
      return c[:name] if category == c[:code]
    end
    'others'
  end

  def category_text
    SHOP_CATEGORY_CODE.map do |c|
      return c[:category] if category == c[:code]
    end
    '其他'
  end

  def map_icon
    SHOP_CATEGORY_CODE.map do |c|
      return c[:icon] if category == c[:code]
    end
    SHOP_CATEGORY_CODE[0][:icon]
  end

  def html_font
    SHOP_CATEGORY_CODE.map do |c|
      return c[:heml_font] if category == c[:code]
    end
    SHOP_CATEGORY_CODE[0][:heml_font]
  end

  def category_name
    SHOP_CATEGORY_CODE.map do |c|
      return c[:name] if category == c[:code]
    end
    SHOP_CATEGORY_CODE[0][:name]
  end

  def html_index_list(index)
    html = ''
    html += "<li class=\"list-item\" data-id=\"#{index}\">"
    html += "<div class=\"avatar avatar-sm rounded-circle bg-#{category_name} \">#{html_font}</div>"
    html += '<div class=" ml-2">'
    html += "<a class=\"tx-15 mb-1 font-weight-medium shop-click\" href=\"#\" data-id=\"#{index}\" >#{name}</a><h7 class=\"mb-0 text-muted tx-13\"> #{service}</h7>"
    html += "<p class=\"mb-0 text-primary tx-17\">#{phone} ▪️ #{address}</p>"
    html += '</div>'
    "#{html}</li>"
  end
end
