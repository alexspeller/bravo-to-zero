class BulkGmailWorker
  attr_reader :user, :completed_count, :total_count, :query, :auth, :current_page

  include Sidekiq::Worker


  def start_bulk_action
    @completed_count  = 0
    @total_count      = 0
    @current_page     = 1

    logger.info "Starting bulk action #{self.class.name} for #{user.email} with query #{query}"

    get_auth
    query_total

    get_next_page

    logger.info "Completed bulk action for #{user.email}"
  end

  def get_auth
    @auth = $google_api_client.authorization.dup
    @auth.update_token! refresh_token: user.refresh_token
    @auth.fetch_access_token!
  end

  def query_total
    params      = {userId: 'me', id: 'INBOX'}
    params[:q]  = query if query.present?

    result = $google_api_client.execute(api_method: $gmail_api.users.labels.get,
      parameters: params,
      authorization: auth)

    @total_count = result.data.messages_total
  end

  def get_next_page page = nil
    params              = {userId: 'me', labelIds: 'INBOX', maxResults: 10}
    params[:q]          = query if query.present?
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
    logger.info "Getting page #{current_page} of messages for #{user.email}"

    if page.data.messages.count == 0
      require 'pry'; binding.pry; 1
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

    page.data.messages.each do |message|
      batch.add request_message_action(message)
    end

    $google_api_client.execute(batch, authorization: auth)

    logger.info "Percentage complete: #{percentage_complete}"

    if page.next_page_token
      sleep 1 # Sleep is due to api rate limiting
      get_next_page page.next_page_token
    end

  end

  def percentage_complete
    ((completed_count / total_count.to_f) * 100).round
  rescue ZeroDivisionError
    0
  end


end