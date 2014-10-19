class Api::ArchiveRequestsController < ApiController
  def create
    query = "from:#{params[:email]}"
    ArchiveWorker.perform_async current_user.id, query
    head :ok
  end
end