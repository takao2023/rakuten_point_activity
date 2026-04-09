require 'rails_helper'

RSpec.describe "Dashboards", type: :system do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  it "renders the dashboard with glassmorphism design and essential elements" do
    visit root_path
    
    # グラデーション付きメッセージの確認
    expect(page).to have_content("おはようございます！")
    
    # グラスカードの存在確認（CSSセレクタ）
    expect(page).to have_selector(".glass-card")
    
    # 今日の達成度が 0% であることの確認 (初期状態)
    expect(page.find("#achievement_percentage")).to have_content("0%")
    
    # ボトムナビゲーションの存在確認
    within ".bottom-nav" do
      expect(page).to have_link("ホーム")
      expect(page).to have_link("ポイ活")
    end
  end

  it "updates the UI after clicking complete task using Turbo Stream", js: true do
    # テスト活動データの作成（本来はFactoryで行うべきですが、簡略化のためその場で作成）
    activity = PointActivity.find_or_create_by!(point_activity_title: "テスト楽天活動")
    user.point_activity_targets.create!(point_activity: activity, target_point: 10)
    
    visit root_path
    
    # 完了ボタンを押し、Turboによる更新を確認
    click_button "完了する", match: :first
    
    # Turbo Streamによる更新待ち（完了！の表示を期待）
    expect(page).to have_content("完了！")
    
    # 連続達成記録が更新されることを確認
    expect(page.find("#streak_count")).to have_content("1")
  end
end
