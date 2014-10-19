class OmniauthController < ApplicationController

  def callback
    email = request.env['omniauth.auth']['info']['email']

    user = User.where(email: email).first_or_initialize

    user.name       = request.env['omniauth.auth']['info']['name']
    user.image_url  = request.env['omniauth.auth']['info']['image']

    if (refresh_token = request.env['omniauth.auth']['credentials']['refresh_token'])
      user.refresh_token = refresh_token
    end

    session[:google_credentials] = request.env['omniauth.auth']['credentials']
    user_credentials.code = params[:code]
    user_credentials.fetch_access_token!
    session[:google_credentials] = user_credentials.fetch_access_token!
    user.save!
    session[:user_id] = user.id

    SyncWorker.perform_async(user.id)

    redirect_to root_url
  end

  def fake
    user = User.create!(
      name:       Faker::Name.name,
      email:      Faker::Internet.email,
      image_url:  "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg?sz=50",
      is_fake:    true
    )

    session[:user_id] = user.id

    FakeSyncWorker.perform_async(user.id)

    redirect_to root_url
  end

end
