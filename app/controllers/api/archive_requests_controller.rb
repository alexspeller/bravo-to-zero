class Api::ArchiveRequestsController < ApiController
  def create
    if current_user.is_syncing?
      render_sync_busy
    else
      ArchiveWorker.perform_async current_user.id, params[:ids]
      head :ok
    end
  end
end