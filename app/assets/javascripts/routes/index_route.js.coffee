App.IndexRoute = Em.Route.extend
  model: ->
    if @modelFor('application').session.user
      ajax.request('/api/messages.json')

  actions:
    refreshData: ->
      ajax.request('/api/messages.json').then (result) =>
        @controller.set 'model', result
