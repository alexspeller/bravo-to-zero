class SyncsController < ApplicationController
  def create
    SyncWorker.perform_async(current_user.id)
    head :ok
  end
end