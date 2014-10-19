raise "BRAVO_PUSHER_APP_ID missing config" unless ENV['BRAVO_PUSHER_APP_ID'].present?
raise "BRAVO_PUSHER_KEY missing config" unless ENV['BRAVO_PUSHER_KEY'].present?
raise "BRAVO_PUSHER_SECRET missing config" unless ENV['BRAVO_PUSHER_SECRET'].present?


Pusher.url = "https://#{ENV['BRAVO_PUSHER_KEY']}:#{ENV['BRAVO_PUSHER_SECRET']}@api.pusherapp.com/apps/#{ENV['BRAVO_PUSHER_APP_ID']}"
Pusher.logger = Rails.logger


