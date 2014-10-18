raise "Missing BRAVO_GOOGLE_CLIENT_ID" unless ENV["BRAVO_GOOGLE_CLIENT_ID"].present?
raise "Missing BRAVO_GOOGLE_CLIENT_SECRET" unless ENV["BRAVO_GOOGLE_CLIENT_SECRET"].present?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["BRAVO_GOOGLE_CLIENT_ID"], ENV["BRAVO_GOOGLE_CLIENT_SECRET"],
    scope: "email,profile,gmail.readonly,gmail.modify",
    prompt: 'consent'
end

$google_api_client = Google::APIClient.new(
  application_name: 'Bravo',
  application_version: '1.0.0'
)

auth = Signet::OAuth2::Client.new

auth.client_id = ENV["BRAVO_GOOGLE_CLIENT_ID"]
auth.client_secret = ENV["BRAVO_GOOGLE_CLIENT_SECRET"]
auth.authorization_uri = 'https://accounts.google.com/o/oauth2/auth'
auth.token_credential_uri = 'https://accounts.google.com/o/oauth2/token'
auth.scope = 'https://mail.google.com/'

$google_api_client.authorization = auth

$gmail_api = $google_api_client.discovered_api('gmail', 'v1')