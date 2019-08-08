class BulkGmailWorker
  attr_reader :user, :completed_count, :total_count, :auth

  include Sidekiq::Worker


  def start_bulk_action
    @completed_count  = 0
    @total_count      = 0

    user.with_lock do
      if user.is_syncing?
        logger.info "User is already syncing, only one action at a time"
        return
      end
      user.is_syncing = true
      user.save!
    end


    logger.info "Starting bulk action #{self.class.name} for #{user.email}"
    push_progress 0
    get_auth
    query_total

    logger.info "Total count for #{user.email} is #{total_count}"

    get_next_page
    push_progress 'complete'
    logger.info "Completed bulk action for #{user.email}"

  rescue Exception => e
    logger.error "Error running archive worker for #{user.email}:\n#{e.class}\n#{e.message}\n#{e.backtrace.join "\n"}"
  ensure
    user.is_syncing = false
    user.save!
  end

  def get_auth
    @auth = $google_api_client.authorization.dup
    @auth.update_token! refresh_token: user.refresh_token
    @auth.fetch_access_token!
  end

  def get_next_page page = nil
    params              = {userId: 'me', labelIds: 'INBOX', maxResults: 50}
    params[:pageToken]  = page if page.present?

    page = $google_api_client.execute(api_method: $gmail_api.users.messages.list,
        parameters: params,
        authorization: auth)
    if page.success?
      perform_action_for_page page
    else
      logger.error "Error fetching page for #{user.email}:\n#{page.error_message}"
    end
  end


  def perform_action_for_page page
    logger.info "Getting page of messages for #{user.email}"

    if messages_for_page(page).count == 0
      logger.info "Page was empty"
      return
    end

    batch = Google::APIClient::BatchRequest.new do |result|
      if result.success?
        perform_message_action result
      else
        logger.error "Failed batch action for #{user.email}:\n#{result.error_message}"
      end
      @completed_count += 1
    end

    messages_for_page(page).each do |message|
      batch.add request_message_action(message)
    end

    $google_api_client.execute(batch, authorization: auth)

    logger.info "Percentage complete: #{percentage_complete}"
    push_progress percentage_complete

    page_complete page

    if next_page_for_page(page)
      get_next_page next_page_for_page(page)
    end

  end

  def percentage_complete
    ((completed_count / total_count.to_f) * 100).round
  rescue ZeroDivisionError
    0
  end


  def page_complete *args
    # noop
  end

  def push_progress percentage
    user.push 'progress', type: push_type,
      percentage: percentage
  end

end