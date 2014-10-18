App.ApplicationRoute = Em.Route.extend
  model: ->
    ajax.request('/api/session')

  afterModel: (model) ->
    App.CSRF_TOKEN = model.session.csrf_token

  actions:
    logOut: ->
      ajax.request('/api/session', method: 'DELETE').then ->
        location.reload()