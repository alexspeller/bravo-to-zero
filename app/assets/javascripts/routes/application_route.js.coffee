App.ApplicationRoute = Em.Route.extend
  model: ->
    ajax.request('/api/session')

  afterModel: (model) ->
    App.CSRF_TOKEN = model.session.csrf_token

  setupController: (controller, context) ->
    @_super controller, context
    if context.session.user
      window.pusher = new Pusher context.session.pusher_key,
        encrypted:    true
        authEndpoint: '/api/pusher/auth'

      window.pushChannel = pusher.subscribe "private-user_#{context.session.user.id}"
      pushChannel.bind 'progress', (data) =>
        console.log "Push event", data
        Em.run =>
          @controllerFor('index').progress data



  actions:
    logOut: ->
      ajax.request('/api/session', method: 'DELETE').then ->
        location.reload()