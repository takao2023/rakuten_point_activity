class Category < ApplicationRecord
  has_many :point_activities, dependent: :destroy
  
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
