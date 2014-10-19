
App.IndexController = Em.Controller.extend
  filterKey: 'from'

  filterKeyTitle: prop 'filterKey', ->
    switch @get('filterKey')
      when 'fromEmail' then "From (Email address only)"
      when 'fromDomain' then "From (Domain only)"
      else
        @get('filterKey').capitalize()

  groupFunc: prop 'filterKey', ->
    switch @get('filterKey')
      when 'from'
        (message) -> message.from
      when 'fromEmail'
        (message) ->
          # sometimes the email is "raw" so fallback to full email
          message.from.match(/<(.+)>/)?[1] or message.from
      when 'fromDomain'
        (message) ->
          email = message.from.match(/<(.+)>/)?[1] or message.from
          email.match(/@(.+)($|\S|>)/)?[1] || "Unknown domain"
      when 'subject'
        (message) -> message.subject
      when 'to'
        (message) -> message.to
      when 'date'
        # prevent allocating these moments for every record
        oneYear = moment().subtract 1, 'year'
        sixMonths = moment().subtract 6, 'months'
        oneMonth = moment().subtract 1, 'months'
        oneWeek = moment().subtract 1, 'week'
        oneDay = moment().startOf 'day'

        (message) ->
          # cache the moment of a messages date, it won't change
          message.moment ||= moment message.date
          date = message.moment
          if date < oneYear
            'More than a year ago'
          else if date < sixMonths
            'Between 1 year and 6 months ago'
          else if date < oneMonth
            'Between 6 months and 1 month ago'
          else if date < oneWeek
            'Between 1 month and 1 week ago'
          else if date < oneDay
            'Between 1 week ago and yesterday'
          else
            'Today'

  groups: prop 'model.[]', 'groupFunc', ->
    groups = {}
    groupFunc = @get 'groupFunc'

    @get('model').forEach (message) ->
      value = groupFunc message
      groups[value] ||= 0
      groups[value]++

    Em.keys(groups).map (key) ->
      val = groups[key]

      key:      key
      value:    val
    .sort (a, b) ->
      b.value - a.value

  filterValue: prop 'filterKey', 'selectedGroup', ->
    return unless @get('filterKey') and @get('selectedGroup')
    @get('selectedGroup').key



  groupColumns: prop ->
    key = Ember.Table.ColumnDefinition.create
      headerCellName: "Key"
      defaultColumnWidth: 212
      getCellContent: (row) ->
        row.content.key
    value = Ember.Table.ColumnDefinition.create
      headerCellName: "Value"
      defaultColumnWidth: 50
      getCellContent: (row) ->
        row.content.value
    [key, value]

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
        moment(row.content.date).calendar()
    snippet = Ember.Table.ColumnDefinition.create
      defaultColumnWidth: 250
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

  tableMessages: prop 'groupFunc', 'filterValue', 'model.[]', ->
    [groupFunc, value] = [@get('groupFunc'), @get('filterValue')]
    return [] unless groupFunc and value
    @get('model').filter (message) ->
      groupFunc(message) is value
    .sort (a, b) ->
      b.date - a.date

  progress: (data) ->
    @setProperties
      progressPercentage: data.percentage,
      progressType:       data.type

    if data.percentage is 'complete'
      @set 'progressComplete', true
      @set 'progressPercentage', 100
      @send 'refreshData'
      Em.run.later =>
        @setProperties
          progressPercentage: null
          progressType:       null
          progressComplete:   null
      , 500

  archived: (messageIds) ->
    messagesToRemove = @get('model').filter (message) ->
      ~messageIds.indexOf message.id

    tableLength = @get('tableMessages.length')
    @get('model').removeObjects messagesToRemove
    if tableLength > 0 and @get('tableMessages.length') is 0
      @set 'selectedGroup', null

  isFilteringByfrom:        Em.computed.equal 'filterKey', 'from'
  isFilteringByfromEmail:   Em.computed.equal 'filterKey', 'fromEmail'
  isFilteringByfromDomain:  Em.computed.equal 'filterKey', 'fromDomain'
  isFilteringBysubject:     Em.computed.equal 'filterKey', 'subject'
  isFilteringByto:          Em.computed.equal 'filterKey', 'to'
  isFilteringBydate:        Em.computed.equal 'filterKey', 'date'

  progressStyle: prop 'progressPercentage', ->
    "width: #{@get 'progressPercentage'}%; min-width: 20px;"

  actions:
    chartClicked: (groupRow) ->
      @set 'selectedGroup', groupRow

    setFilter: (key) ->
      @set 'filterKey', key
      @set 'selectedGroup', null
