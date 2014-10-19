class Api::SyncsController < ApiController
  def create
    if current_user.is_syncing?
      render_sync_busy
    else
      SyncWorker.perform_async(current_user.id)
      head :ok
    end
  end
end