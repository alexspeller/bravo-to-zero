App.IndexController = Em.Controller.extend
  crossfilter: prop 'model', ->
    crossfilter(this.get('model'))

  messagesByFrom: prop 'crossfilter', ->
    @get('crossfilter').dimension (message) ->
      message.from

  messageCountByFrom: prop 'messagesByFrom', ->
    @get('messagesByFrom').group()

  topMessagesByFrom: prop 'messageCountByFrom', ->
    @get('messageCountByFrom').top(100)

  columns: prop ->
    from = Ember.Table.ColumnDefinition.create
      headerCellName: "From"
      getCellContent: (row) ->
        row.content.from
    to = Ember.Table.ColumnDefinition.create
      headerCellName: "To"
      getCellContent: (row) ->
        row.content.to
    subject = Ember.Table.ColumnDefinition.create
      headerCellName: "Subject"
      getCellContent: (row) ->
        row.content.subject
    date = Ember.Table.ColumnDefinition.create
      headerCellName: "Date"
      getCellContent: (row) ->
        row.content.date
    snippet = Ember.Table.ColumnDefinition.create
      headerCellName: "Preview"
      getCellContent: (row) ->
        row.content.snippet
    [
      from
      to
      subject
      date
      snippet
    ]
  actions:
    showMessagesFrom: (email) ->
      @set 'fromFilter', email
      @get('messagesByFrom').filter email
      @set 'tableMessages', @get('messagesByFrom').top Infinity
    archiveAll: ->
      ajax.request '/api/archive_requests',
        method: 'POST'
        data:
          email: @get('fromFilter')
      .then ->
        alert 'archived'
    sync: ->
      ajax.request '/syncs',
        method: 'POST'
      .then ->
        alert 'synced'