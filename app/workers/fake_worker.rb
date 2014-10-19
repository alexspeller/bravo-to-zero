class FakeWorker
  attr_reader :user, :completed_count, :total_count

  include Sidekiq::Worker

  def start_bulk_action
    @completed_count  = 0
    @total_count      = 0

    user.with_lock do
      if user.is_syncing?
        logger.info "User is already syncing, only one action at a time"
        return
      end
      user.is_syncing = true
      user.save!
    end


    logger.info "Starting bulk action #{self.class.name} for #{user.email}"
    push_progress 0

    query_total

    logger.info "Total count for #{user.email} is #{total_count}"

    do_action

    push_progress 'complete'
    logger.info "Completed bulk action for #{user.email}"

  rescue Exception => e
    require 'pry'; binding.pry; 1
    logger.error "Error running archive worker for #{user.email}:\n#{e.class}\n#{e.message}\n#{e.backtrace.join "\n"}"
  ensure
    user.is_syncing = false
    user.save!
  end

  def percentage_complete
    ((completed_count / total_count.to_f) * 100).round
  rescue ZeroDivisionError
    0
  end


  def push_progress percentage
    user.push 'progress', type: push_type,
      percentage: percentage
  end
end