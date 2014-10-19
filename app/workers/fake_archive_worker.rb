class FakeArchiveWorker < FakeWorker
  attr_reader :ids, :id_groups

  def perform user_id, ids
    @user = User.find user_id
    @ids = ids
    @id_groups = ids.in_groups_of(10,false)
    logger.info "Fake Archiving for #{user.email} #{ids.join ', '}"
    return if ids.empty?
    start_bulk_action
  end


  def push_type
    'Archiving your messages'
  end

  def query_total
    @total_count = ids.length
  end


  def do_action
    id_groups.each do |group|
      Message.delete group
      user.push 'messages-archived', ids: group
      @completed_count += group.length
      push_progress percentage_complete
    end
  end
end