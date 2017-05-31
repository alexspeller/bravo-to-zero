# Bravo to Zero

Inbox Zero is great in theory, but it's easy to let it slip and suddenly there are hundreds of emails in your inbox and it takes forever to archive them.

Bravo to Zero makes it easy to get back to zero, by showing you groups of emails that you can archive in bulk. Try it now with your real Google Mail account, or with dummy data.

![Screenshot](https://raw.githubusercontent.com/alexspeller/bravo-to-zero/master/app/assets/images/screenshot.png)

## Requirements

You can install this app on your own heroku instance or locally if you like. The requirements are:

* Ruby 2.1.3
* Postgres
* Redis
* Google api tokens
* A pusher account


## Setup

You will need to to setup accounts with google and pusher. Create a new pusher app and put the details in the `BRAVO_PUSHER_APP_ID`, `BRAVO_PUSHER_KEY`, and `BRAVO_PUSHER_SECRET` environment variables.

You will also need to setup your google api access. Go to the [Google API console](https://console.developers.google.com) and create a project. Add the Contacts API, Google+ API and Gmail API. Create a new set of credentials, and ensure the redirect URIs are correct for your application.
