class PagesController < ApplicationController
  # 未ログインでもアクセス可能
  def home
    # ログイン済みならダッシュボードへリダイレクト
    redirect_to dashboards_path and return if user_signed_in?
  end
end
