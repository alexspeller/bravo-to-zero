App.IndexRoute = Em.Route.extend
  model: ->
    if @modelFor('application').session.user
      ajax.request('/api/messages.json')