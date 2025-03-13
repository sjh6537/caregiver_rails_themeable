class Coupon < ActiveRecord::Base
  before_save :randomize_file_name

  has_many :user_coupons, dependent: :destroy, class_name: 'User::Coupon'
  belongs_to :shop

  has_attached_file :image,
                    styles: { default: '300x300!' },
                    default_style: :default,
                    default_url: '',
                    path: ':rails_root/images/coupons/:id/image/:filename',
                    url: '/coupons/:id/image/:filename',
                    use_timestamp: false

  has_attached_file :full_image,
                    styles: { default: '600x300!' },
                    default_style: :default,
                    default_url: '',
                    path: ':rails_root/images/coupons/:id/full_image/:filename',
                    url: '/coupons/:id/full_image/:filename',
                    use_timestamp: false

  do_not_validate_attachment_file_type :image
  do_not_validate_attachment_file_type :full_image

  def randomize_file_name
    if image_updated_at_changed? && !image_file_name.nil?
      extension = File.extname(image_file_name).downcase
      image.instance_write(:file_name, "#{Time.now.strftime('%Y%m%d%H%M%S')}#{rand(1000)}#{extension}")
    end

    return unless full_image_updated_at_changed? && !full_image_file_name.nil?

    extension = File.extname(full_image_file_name).downcase
    full_image.instance_write(:file_name, "#{Time.now.strftime('%Y%m%d%H%M%S')}#{rand(1000)}#{extension}")
  end

  def use_date
    text = nil
    unless period_start.nil?
      text = period_start.strftime('%Y年 %m月 %d日 00:00')
      unless period_end.nil?
        text += ' - '
        text += period_end.strftime('%Y年 %m月 %d日 00:00')
      end
    end
    text
  end
end
