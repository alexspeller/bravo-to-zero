class UnarchiveWorker < BulkGmailWorker
  include Sidekiq::Worker

  attr_reader :ids, :id_groups

  def perform
    @ids = ["16aa38fddd2af7ca", "16aa25aa2b7e6193", "16a9eaa14de1eedb", "16a9e5d8897223ed", "16a9e191bccc5923", "16a9da03b55b124b", "16a9d6cc1d9db333", "16a9d6c73b0706c3", "16a9cf07f7407349", "16a9ceecb486a357", "16a9986abd699f22", "16a9294bef3575b6", "16a927a9afe68271", "16a8f4ced16a6113", "16a8f46707c13a7a", "16a8f306c92c09e8", "16a8ef7ff5f4278a", "16a8ecd65e741bd0", "16a8eab0cc27dae9", "16a8e800b12b144c", "16a8e21da30f4b43", "16a854046af05926", "16a73bd704ce4c3f", "16a73904978ad784", "16a737b2e1838ac4", "16a737876204202d", "16a711fd3afb5787", "16a7108b9c530acd", "16a70ce21bcc2ba7", "16a70cd98098e4e7", "16a70cbcecb4e8d8", "16a6fce1a1efffde", "16a54e2efa849834", "16a54da2410456de", "16a2d12fc6d767e6", "16a2cb315f8f02d2", "16a215fa0d7ac818", "16a1d37baf26b394"]
    @ids.concat ["16aa38fddd2af7ca", "16aa25aa2b7e6193", "16aa25aa2b7e6193", "16a9eaa14de1eedb", "16a9eaa14de1eedb", "16a9e5d8897223ed", "16a9e5d8897223ed", "16a9e191bccc5923", "16a9e191bccc5923", "16a9da03b55b124b", "16a9da03b55b124b", "16a9d6cc1d9db333", "16a9d6cc1d9db333", "16a9d6c73b0706c3", "16a9d6c73b0706c3", "16a9cf07f7407349", "16a9cf07f7407349", "16a9ceecb486a357", "16a9ceecb486a357", "16a9986abd699f22", "16a9294bef3575b6", "16a9294bef3575b6", "16a927a9afe68271", "16a927a9afe68271", "16a8f4ced16a6113", "16a8f4ced16a6113", "16a8f46707c13a7a", "16a8f46707c13a7a", "16a8f306c92c09e8", "16a8f306c92c09e8", "16a8ef7ff5f4278a", "16a8ef7ff5f4278a", "16a8ecd65e741bd0", "16a8ecd65e741bd0", "16a8eab0cc27dae9", "16a8eab0cc27dae9", "16a8e800b12b144c", "16a8e800b12b144c", "16a8e21da30f4b43", "16a854046af05926", "16a854046af05926", "16a73bd704ce4c3f", "16a73bd704ce4c3f", "16a73904978ad784", "16a73904978ad784", "16a737b2e1838ac4", "16a737b2e1838ac4", "16a737876204202d", "16a737876204202d", "16a711fd3afb5787", "16a711fd3afb5787", "16a7108b9c530acd", "16a7108b9c530acd", "16a70ce21bcc2ba7", "16a70ce21bcc2ba7", "16a70cd98098e4e7", "16a70cd98098e4e7", "16a70cbcecb4e8d8", "16a6fce1a1efffde", "16a6fce1a1efffde", "16a54e2efa849834", "16a54e2efa849834", "16a54da2410456de", "16a54da2410456de", "16a2d12fc6d767e6", "16a2d12fc6d767e6", "16a2cb315f8f02d2", "16a2cb315f8f02d2", "16a215fa0d7ac818", "16a215fa0d7ac818", "16a1d37baf26b394", "16a1d37baf26b394"]

    @user = User.find 1
    @id_groups = ids.in_groups_of(10,false)
    logger.info "Unarchiving for #{user.email} #{ids.join ', '}"
    return if ids.empty?
    start_bulk_action
  end

  def push_type
    'Unarchiving your messages'
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


  def page_complete page
    user.push 'messages-unarchived', ids: page
  end
  def request_message_action id
    logger.info "Request message action for #{id}"
    {
      api_method: $gmail_api.users.messages.modify,
      parameters: {
        userId: 'me',
        id: id
      },
      body_object: {
        addLabelIds: ['INBOX']
      }
    }
  end

  def perform_message_action message
    user.messages.find_by(google_id: message.data.id).try :destroy
  end
end
