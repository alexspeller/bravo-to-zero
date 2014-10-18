class Api::MessagesController < ApiController
  def index
    messages = current_user.messages.map do |message|
      {
        id:       message.google_id,
        from:     message.from,
        to:       message.to,
        subject:  message.subject,
        date:     message.date,
        snippet:  message.snippet
      }
    end
    render json: Yajl::Encoder.encode(messages)
  end
end