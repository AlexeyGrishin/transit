oscar = require('oscar')
_ = require('underscore')

module.exports = (icqConfig) ->
  throw "You need to provide both login and password for icq account" unless icqConfig?.login? and icqConfig?.password?
  icqConfig.msgDelay = icqConfig.msgDelay ? 500
  install: (transit) ->
    transit.client @

  _onError: (sender) ->
    (err) ->
      @icq.notifyTyping sender, oscar.TYPING_NOTIFY.TEXT_ENTERED
      @icq.sendIM(sender, "error: #{err}") if err

  start: ->
    @_delayedTo = null
    @_delayedMessages = []
    @icq = new oscar.OscarConnection({
      connection: {
        username: icqConfig.login + "",
        password: icqConfig.password + "",
        host: oscar.SERVER_ICQ
      }
    });

    @icq.on 'im', (text, sender, flags, ts) =>
      @icq.notifyTyping sender.name, oscar.TYPING_NOTIFY.START
      @callback sender.name, text, @_onError(sender).bind(@)
    @icq.on 'contactoffline', (sender) =>
      @callback sender.name, command:"exit", @_onError(sender).bind(@)

    @icq.connect (error) =>
      if (error)
        @callback null, error:error, ->
        console.error "Cannot connect to ICQ server"
        console.error error
      else
        @icq.getOfflineMsgs()

  receive: (@callback) ->

  _delayed: (action) ->
    @_delayedMessages.push action
    if @_delayedTo == null
      @_doDelayed()

  _doDelayed: () ->
    msg = @_delayedMessages.shift()
    if msg
      msg()
      @_delayedTo = setTimeout @_doDelayed.bind(@), icqConfig.msgDelay
    else
      @_delayedTo = null

  sendBack: (userId, data, cb) ->
    @_delayed =>
      @icq.sendIM userId, data, cb
