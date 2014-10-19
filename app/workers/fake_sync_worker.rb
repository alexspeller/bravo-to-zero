class FakeSyncWorker < FakeWorker
  def perform user_id
    @user = User.find user_id

    user.messages.delete_all
    start_bulk_action
  end

  def query_total
    @total_count = 500
  end

  def do_action

    common_emails = (0..20).map {Faker::Internet.email}
    common_names = (0..10).map {Faker::Name.name}
    (0...total_count).to_a.in_groups_of(10) do |group|
      group.each do |i|
        if rand < 0.5
          email = common_emails.sample
          name = common_names.sample
        else
          email = Faker::Internet.email
          name = Faker::Internet.name
        end

        from = "#{name} <#{email}>"

        to = "#{user.name} <#{user.email}>"

        date = Time.now - rand(365 * 2).days

        cached_message = user.messages.create! snippet:  Faker::Lorem.sentence,
          from:       from,
          to:         to,
          subject:    Faker::Company.bs,
          date:       date,
          google_id:  rand.to_s
      end
      @completed_count += group.length
      push_progress percentage_complete
    end
  end

  def push_type
    'Syncing your messages with Google'
  end
end