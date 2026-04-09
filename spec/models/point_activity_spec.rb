require 'rails_helper'

RSpec.describe PointActivity, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      activity = PointActivity.new(point_activity_title: 'Test Activity')
      expect(activity).to be_valid
    end

    it 'is not valid without a title' do
      activity = PointActivity.new(point_activity_title: nil)
      expect(activity).to_not be_valid
    end
  end
end
