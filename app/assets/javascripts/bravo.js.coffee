#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./components
#= require_tree ./templates
#= require_tree ./routes
#= require ./router

window.App = Em.Application.create()

window.prop = Em.computed

Em.$.ajaxPrefilter (options, originalOptions, xhr) =>
  if App.CSRF_TOKEN
    xhr.setRequestHeader 'X-CSRF-Token', App.CSRF_TOKEN
