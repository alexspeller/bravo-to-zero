class Api::ArchiveRequestsController < ApiController
  def create
    if current_user.is_syncing?
      render_sync_busy
    else
      if current_user.is_fake?
        FakeArchiveWorker.perform_async current_user.id, params[:ids]
      else
        ArchiveWorker.perform_async current_user.id, params[:ids]
      end
      head :ok
    end
  end
end