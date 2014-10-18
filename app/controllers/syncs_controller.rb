class GmailSyncer
  attr_reader :user

  def perform user_id
    @user = User.find user_id
    @total_cached_messages = 0
    query_message_count

    get_next_page
  end

  def query_message_count
    result = $google_api_client.execute(api_method: $gmail_api.users.labels.get,
      parameters: {userId: 'me', id: 'INBOX'},
      authorization: auth)

    @total_count = result.data.messages_total
  end

  def get_next_page params={}
    params.reverse_merge!(userId: 'me', labelIds: 'INBOX')

    page = $google_api_client.execute(api_method: $gmail_api.users.messages.list,
        parameters: params,
        authorization: auth)

    cache_messages_for_page page
  end

  def percentage_complete
    ((@total_cached_messages / @total_count.to_f) * 100).round
  end

  def cache_messages_for_page page
    logger.info "Getting a new page of messages"

    batch = Google::APIClient::BatchRequest.new do |message|
      cached_message = user.messages.where(google_id: message.data.id).first_or_initialize
      begin
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
      @total_cached_messages += 1

    end

    page.data.messages.each do |message|
      batch.add(api_method: $gmail_api.users.messages.get,
        parameters: {userId: 'me', id: message.id, format: 'metadata'})
    end

    $google_api_client.execute(batch, authorization: auth)

    logger.info "Percentage complete: #{percentage_complete}"

    if page.next_page_token
      get_next_page pageToken: page.next_page_token
    end
  end

  def find_header header_name, message
    message.data.payload.headers.find{|h| h.name.strip.downcase == header_name.downcase }.value
  end


  def auth
    return @auth if @auth
    @auth = $google_api_client.authorization.dup
    @auth.update_token! refresh_token: user.refresh_token
    @auth.fetch_access_token!
    @auth
  end

  def logger
    Rails.logger
  end
end

class SyncsController < ApplicationController
  def create

    GmailSyncer.new.perform(current_user.id)
    redirect_to root_url

  end
end