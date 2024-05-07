class PointActivityGet < ApplicationRecord
  belongs_to :user
  belongs_to :target_point, optional: true
end
