class ArchiveRequest
  attr_reader :user, :query

  def perform user_id, query
    @user = User.find user_id
    @query = query

    archive_page
  end

  def archive_page params={}
    params.reverse_merge! userId: 'me', labelIds: 'INBOX', q: query, maxResults: 10

    page = $google_api_client.execute(api_method: $gmail_api.users.messages.list,
        parameters: params,
        authorization: auth)

    archive_messages_for_page page

  end

  def archive_messages_for_page page
    logger.info "Getting a new page of messages"

    batch = Google::APIClient::BatchRequest.new do |message|
      unless message.data.id
        require 'pry'; binding.pry; 1
      end
      cached_message = user.messages.find_by google_id: message.data.id
      cached_message.try :destroy
    end

    page.data.messages.each do |message|
      batch.add api_method: $gmail_api.users.messages.modify,
        parameters: {userId: 'me', id: message.id},
        body_object: {
          removeLabelIds: ['INBOX']
        }
    end

    $google_api_client.execute(batch, authorization: auth)

    if page.next_page_token
      sleep 1
      archive_page pageToken: page.next_page_token
    end
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


class Api::ArchiveRequestsController < ApiController
  def create
    query = "from:#{params[:email]}"
    ArchiveRequest.new.perform(current_user.id, query)
    head :ok
  end
end