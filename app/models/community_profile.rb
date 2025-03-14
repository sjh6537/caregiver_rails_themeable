class CommunityProfile < ApplicationRecord
  # Associations
  belongs_to :community, optional: true
end
