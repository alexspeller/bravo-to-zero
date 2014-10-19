class ArchiveWorker < BulkGmailWorker
  include Sidekiq::Worker

  attr_reader :ids, :id_groups

  def perform user_id, ids
    @user = User.find user_id
    @ids = ids
    @id_groups = ids.in_groups_of(10,false)
    logger.info "Archiving for #{user.email} #{ids.join ', '}"
    return if ids.empty?
    start_bulk_action
  end

  def push_type
    'Archiving your messages'
  end

  def query_total
    @total_count = ids.length
  end

  def get_next_page page=0
    @current_page = page
    page = id_groups[page]
    perform_action_for_page page
  end

  def messages_for_page page
    page
  end

  def next_page_for_page page
    next_page = @current_page + 1
    if id_groups[next_page]
      next_page
    end
  end



  def request_message_action id
    {
      api_method: $gmail_api.users.messages.get,
      parameters: {
        userId: 'me',
        id: id,
        format: 'metadata'
      }
    }
  end

  def page_complete page
    user.push 'messages-archived', ids: page
  end
  # def request_message_action id
  #   logger.info "Request message action for #{id}"
  #   {
  #     api_method: $gmail_api.users.messages.modify,
  #     parameters: {
  #       userId: 'me',
  #       id: id
  #     },
  #     body_object: {
  #       removeLabelIds: ['INBOX']
  #     }
  #   }
  # end

  def perform_message_action message
    user.messages.find_by(google_id: message.data.id).try :destroy
  end
end
