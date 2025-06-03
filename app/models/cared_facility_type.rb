class CaredFacilityType < ApplicationRecord
  has_many :cared_facilities

  validates :name, presence: true
end
