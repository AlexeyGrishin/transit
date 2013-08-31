oscar = require('oscar')
{forEachPortion} = require('./parser')
_ = require('_')

html2text = (html) ->
  html.replace(/<(?:.|)*?>/gm, '').replace(/\r/gm, '')

#TODO: move out to special middleware
text2html = (text) ->
  "<font face='courier'>#{text}</font>"

module.exports = (icqConfig) ->
  throw "You need to provide both login and password for icq account" unless icqConfig?.login? and icqConfig?.password?
  install: (transit) ->
    transit.server @

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
      @callback sender.name, html2text(text), @_onError(sender).bind(@)
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

  #TODO: move to another middleware
  sendBack: (userId, data, cb) ->
    wait = 0
    errors = []
    forEachPortion data, 2000, (portion) =>
      wait++
      @icq.sendIM userId, text2html(portion), (err, data) ->
        errors.push err if err
        cb errors.join(",") if not --wait
