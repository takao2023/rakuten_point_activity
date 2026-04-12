class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    # LINE連携済みで、かつメールアドレスやパスワードの変更を伴わない場合はパスワードなしで更新を許可
    if resource.line_profile.present? && !email_or_password_changing?(params)
      resource.update_without_password(params)
    else
      # 通常通り現在のパスワードを要求
      super
    end
  end

  private

  def email_or_password_changing?(params)
    params[:email].present? && params[:email] != resource.email ||
      params[:password].present? ||
      params[:password_confirmation].present?
  end
end
