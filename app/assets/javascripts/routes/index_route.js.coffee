App.IndexRoute = Em.Route.extend
  model: ->
    if @modelFor('application').session.user
      ajax.request('/api/messages.json')

  reportError: (error) ->
    msg = error?.jqXHR?.responseJSON?.error || "Request failed"
    alert msg

  actions:
    refreshData: ->
      ajax.request('/api/messages.json').then (result) =>
        @controller.set 'model', result
    sync: ->
      ajax.request '/api/syncs',
        method: 'POST'
      .then ->
        console.log 'Sync request sent'
      , (error) =>
        @reportError error

    archiveAll: ->
      messages = @controller.get('tableMessages')

      if messages.length > 0 and confirm "
        Are you sure you want to archive #{messages.length} messages?
        \nThere is no undo, but messages will be *archived*, not deleted permanently!
      "
        ajax.request '/api/archive_requests',
          method: 'POST'
          data:
            ids: messages.mapBy('id')
        .then ->
          console.log 'archive request sent',
        , (error) =>
          @reportError error

