class Api::MessagesController < ApiController
  def index
    messages = current_user.messages.map do |message|
      {
        id:       id_for(message),
        from:     message.from,
        to:       message.to,
        subject:  message.subject,
        date:     message.date,
        snippet:  message.snippet
      }
    end
    render json: Yajl::Encoder.encode(messages)
  end

  private

  def id_for message
    if current_user.is_fake?
      message.id
    else
      message.google_id
    end
  end
end