class Api::ArchiveRequestsController < ApiController
  def create
    if current_user.is_syncing?
      render_sync_busy
    else
      query = "from:#{params[:email]}"
      ArchiveWorker.perform_async current_user.id, query
      head :ok
    end
  end
end