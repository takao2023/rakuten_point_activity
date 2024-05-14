class PointActivityTarget < ApplicationRecord
  belongs_to :user
  belongs_to :get_point, optional: true
  belongs_to :point_activity
end
