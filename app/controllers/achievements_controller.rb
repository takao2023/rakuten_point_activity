class AchievementsController < ApplicationController
  def index
    @achievements = Achievement.all
    @earned_achievement_ids = current_user.user_achievements.pluck(:achievement_id)
    
    # バッジのデザイン設定（名前とアイコンの対応）
    @badge_assets = {
      'ポイ活ビギナー' => { icon: 'bi-box-seam', color: '#ff9800' },
      '三日坊主卒業' => { icon: 'bi-calendar-check', color: '#4caf50' },
      'ポイ活の達人' => { icon: 'bi-award', color: '#2196f3' }
    }
  end
end
