class ApiController < ApplicationController
  respond_to :json

  before_filter :require_user

  private

  def require_user
    head :unauthorized unless current_user.present?
  end

  def render_sync_busy
    render json: {error: "There is an action in progress already. Please wait for that to finish first"}, status: :locked
  end
end