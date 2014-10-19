class SyncWorker < BulkGmailWorker
  def perform user_id
    @user = User.find user_id

    user.messages.delete_all
    start_bulk_action
  end

  def push_type
    'Syncing your messages with Google'
  end


  def request_message_action message
    {
      api_method: $gmail_api.users.messages.get,
      parameters: {
        userId: 'me',
        id: message.id,
        format: 'metadata'
      }
    }
  end

  def perform_message_action message
    cached_message = user.messages.where(google_id: message.data.id).first_or_initialize
    cached_message.update_attributes! snippet:    message.data.snippet,
      from:       find_header('From', message),
      to:         find_header('To', message),
      subject:    find_header('Subject', message),
      date:       find_header('Date', message),
      thread_id:  message.data.thread_id,
      history_id: message.data.history_id,
      labels: message.data.label_ids
  rescue
    logger.error "Could not cache message #{message.data.id} for user #{user.email}"
  end

  def find_header header_name, message
    message.data.payload.headers.find{|h| h.name.strip.downcase == header_name.downcase }.value
  end
end