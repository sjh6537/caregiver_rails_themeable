class CommunityProfile < ApplicationRecord
  # Associations
  belongs_to :community, optional: false
end
