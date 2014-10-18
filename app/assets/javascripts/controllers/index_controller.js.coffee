App.IndexController = Em.Controller.extend
  crossfilter: prop 'model', ->
    crossfilter(this.get('model'))

  messagesByFrom: prop 'crossfilter', ->
    @get('crossfilter').dimension (message) ->
      message.from

  messageCountByFrom: prop 'messagesByFrom', ->
    @get('messagesByFrom').group()

  messagesBySubject: prop 'crossfilter', ->
    @get('crossfilter').dimension (message) ->
      message.from

  messageCountByFrom: prop 'messagesByFrom', ->
    @get('messagesByFrom').group()

  messagesParsedByFrom: prop 'crossfilter', ->
    @get('crossfilter').dimension (message) ->
      match = message.from.match(/<(.+)>$/)
      if match and match[1]
        match[1]
      else
        message.from

  messageParsedCountByFrom: prop 'messagesParsedByFrom', ->
    @get('messagesParsedByFrom').group()

  topMessagesByFrom: prop 'messageCountByFrom', ->
    @get('messageCountByFrom').top(10)

  topMessagesByFromParsed: prop 'messageParsedCountByFrom', ->
    @get('messageParsedCountByFrom').top(10)

  groupCounts: prop 'messageCountByFrom', ->
    from:       @get('messageCountByFrom').all().length
    fromParsed: @get('messageParsedCountByFrom').all().length
