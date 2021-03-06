class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: :is_production?, host:'vast-depths-1206.herokuapp.com'

  def is_production?
    Rails.env.production?
  end

  private

  def user_credentials
    @authorization ||= (
    auth = $google_api_client.authorization.dup
    auth.update_token!(session[:google_credentials])
    auth
    )
  end

  def current_user
    return nil unless session[:user_id].present?
    User.find session[:user_id]
  end
  helper_method :current_user

end
