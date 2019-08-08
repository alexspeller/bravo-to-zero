Ember.Table.EmberTableComponent.reopen
  findRow: (content) ->
    # fix bug setting ember table selection
    @get('bodyContent').findBy('content', content)

  doubleClick: ->
    row = this.getRowForEvent(event);
    return if !row
    window.open(row.get('url'))




