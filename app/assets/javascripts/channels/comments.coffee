App.comments = App.cable.subscriptions.create "ws://localhost:28080",
  collection: -> $("[data-channel='comments']")

  connected: ->
    # FIXME: While we wait for cable subscriptions to always be finalized before sending messages
    setTimeout =>
      @followCurrentMessage()
      @installPageChangeCallback()
    , 1000

  received: (data) ->
    @collection().append(data.comment) unless @userIsCurrentUser(data.comment)

  userIsCurrentUser: (comment) ->
    $(comment).attr('data-user-id') is $('meta[name=current-user]').attr('id')

  followCurrentMessage: ->
    if messageId = @collection().data('message-id')
      @perform 'follow', message_id: messageId
    else
      @perform 'unfollow'

  installPageChangeCallback: ->
    unless @installedPageChangeCallback
      @installedPageChangeCallback = true
      $(document).on 'page:change', -> App.comments.followCurrentMessage()
