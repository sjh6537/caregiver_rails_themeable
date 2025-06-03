class CaredFacilityEventType < ApplicationRecord
  has_many :cared_facility_events

  validates :name, presence: true
end
