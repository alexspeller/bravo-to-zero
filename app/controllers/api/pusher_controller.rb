class Api::PusherController < ApiController
  skip_before_filter :verify_authenticity_token

  def auth
    unless current_user.present?
      render text: "Forbidden", status: 403
      return
    end

    match = params[:channel_name].match /\Aprivate-user_(\d+)\z/

    unless match && (match[1].to_i == current_user.id)
      render text: "Forbidden", status: '403'
      return
    end

    response = Pusher[params[:channel_name]].authenticate(params[:socket_id],
      user_id: current_user.id
    )

    render json: response
  end
end
