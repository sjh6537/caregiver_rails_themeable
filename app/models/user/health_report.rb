module User
  class HealthReport < ActiveRecord::Base
    belongs_to :user
  end
end
