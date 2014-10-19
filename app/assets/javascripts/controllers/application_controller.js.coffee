App.ApplicationController = Em.ObjectController.extend
  isShowingVoteBanner: true
  actions:
    hideBanner: ->
      @set 'isShowingVoteBanner', false