class Api::SyncsController < ApiController
  def create
    if current_user.is_syncing?
      render_sync_busy
    else
      if current_user.is_fake?
        FakeSyncWorker.perform_async(current_user.id)
      else
        SyncWorker.perform_async(current_user.id)
      end
      head :ok
    end
  end
end