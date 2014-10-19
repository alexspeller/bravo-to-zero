Ember.Table.EmberTableComponent.reopen
  findRow: (content) ->
    # fix bug setting ember table selection
    @get('bodyContent').findBy('content', content)