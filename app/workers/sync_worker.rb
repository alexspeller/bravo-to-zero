class SyncWorker < BulkGmailWorker
  def perform user_id
    @user = User.find user_id

    user.messages.delete_all
    start_bulk_action
  end

  def push_type
    'Syncing your messages with Google'
  end

  def query_total
    result = get_label 'INBOX'

    @total_count = result.data.messages_total
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
      labels: message.data.label_ids.map{|l| get_label_name(l) }
  rescue
    logger.error "Could not cache message #{message.data.id} for user #{user.email}"
  end

  def messages_for_page page
    page.data.messages
  end

  def next_page_for_page page
    page.next_page_token
  end

  def get_label label
    params      = {userId: 'me', id: label}

    $google_api_client.execute(api_method: $gmail_api.users.labels.get,
      parameters: params,
      authorization: auth)
  end

  def get_label_name label
    @cached_names ||= {}

    return @cached_names[label] if @cached_names[label]

    @cached_names[label] = get_label(label).data.name
  end

  def find_header header_name, message
    message.data.payload.headers.find{|h| h.name.strip.downcase == header_name.downcase }.value
  end
end