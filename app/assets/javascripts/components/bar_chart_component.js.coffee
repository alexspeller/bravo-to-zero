App.BarChartComponent = Em.Component.extend
  tagName: 'svg'
  attributeBindings: ['height']
  height: 200

  data: prop 'columns.[]', ->
    console.log 'data'
    [
      key: "Email Count"
      values: @get('columns').map (group) ->
        label: group.key
        value: group.value
    ]

  _dataChanged: (->
    Em.run.once @, 'redraw'
  ).observes 'data.[]'

  redraw: ->
    d3.select(@get 'element').datum(@get 'data').call @chart

  didInsertElement: ->
    nv.addGraph =>
      @chart = nv.models.discreteBarChart()
        .x (d) -> d.label
        .y (d) -> d.value
        .staggerLabels true
        .tooltips true
        .showXAxis false
        .transitionDuration 350
        .tooltipContent (key, x, y, e, graph) ->
          "<h3>#{Handlebars.Utils.escapeExpression x}</h3>
           <p>#{y} emails</p>"

      @chart.yAxis
        .tickFormat d3.format('d')

      @chart.discretebar.dispatch.on 'elementClick', (el) =>
        @sendAction 'action', @get('columns')[el.pointIndex]

      nv.utils.windowResize @chart.update

      @redraw()
