class Api::SessionsController < ApiController
  skip_before_filter :require_user, only: :show

  def show
    session = Session.new form_authenticity_token, current_user
    respond_with :api, session
  end

  def destroy
    reset_session
    head :ok
  end
end