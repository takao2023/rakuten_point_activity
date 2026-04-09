class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # CSRFトークン検証をAPIとして扱うためスキップするか、フロントでヘッダに付与するか
  # Hotwire/Rails UJS が付与してくるためここではデフォルトで検証可能

  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: push_params[:endpoint]
    )
    
    subscription.p256dh = push_params[:keys][:p256dh]
    subscription.auth = push_params[:keys][:auth]
    
    if subscription.save
      render json: { message: 'Subscription successfully saved' }, status: :ok
    else
      render json: { error: 'Failed to save subscription' }, status: :unprocessable_entity
    end
  end

  private

  def push_params
    params.require(:subscription).permit(:endpoint, keys: [:p256dh, :auth])
  end
end
