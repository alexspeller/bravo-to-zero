class OmniauthController < ApplicationController

  def callback
    session[:google_credentials] = request.env['omniauth.auth']['credentials']
    user_credentials.code = params[:code]
    user_credentials.fetch_access_token!
    session[:google_credentials] = user_credentials.fetch_access_token!
    session[:google_user_info] = request.env['omniauth.auth']['info']
    redirect_to root_url
  end

end
