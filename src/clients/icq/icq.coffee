oscar = require('oscar')
{forEachPortion} = require('./parser')
_ = require('_')

module.exports = (icqConfig) ->
  throw "You need to provide both login and password for icq account" unless icqConfig?.login? and icqConfig?.password?
  install: (transit) ->
    transit.client @

  _onError: (sender) ->
    (err) ->
      @icq.notifyTyping sender, oscar.TYPING_NOTIFY.TEXT_ENTERED
      @icq.sendIM(sender, "error: #{err}") if err

  start: ->
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
      #TODO: make transit engine know about error
      if (error)
        console.error "Cannot connect to ICQ server"
        console.error error
      else
        @icq.getOfflineMsgs()

  receive: (@callback) ->

  sendBack: (userId, data, cb) ->
    @icq.sendIM userId, data, cb
