class ApiController < ApplicationController
  respond_to :json

  before_filter :require_user

  private

  def require_user
    head :unauthorized unless current_user.present?
  end
end