class ArchiveWorker < BulkGmailWorker
  include Sidekiq::Worker

  def perform user_id, query
    @user = User.find user_id
    @query = query

    start_bulk_action
  end

  def request_message_action message
    {
      api_method: $gmail_api.users.messages.modify,
      parameters: {
        userId: 'me',
        id: message.id
      },
      body_object: {
        removeLabelIds: ['INBOX']
      }
    }
  end

  def perform_message_action message
    user.messages.find_by(google_id: message.data.id).try :destroy
  end
end
