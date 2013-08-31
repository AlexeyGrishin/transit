_ = require('underscore')
Request = require('./core/request')
Response = require('./core/response')
{EventEmitter} = require('events')


class Transit extends EventEmitter
  constructor: ->
    @_handlers = []
    @_chain = []

  use: (middleware) ->
    if not _.isFunction middleware
      middleware = middleware.install(@)
    @_chain.push middleware if _.isFunction middleware

  client: (client) ->
    @_client = -> client
    undefined

  _client: ->
    throw "Please install client"

  start: (options) ->
    @_client().receive @_onRequest.bind(@)
    @_client().start options

  _onRequest: (userId, data, doneCb) ->
    chain = @_chain.slice()
    chain.push (req, res, next) =>
      if req.command
        @emit req.command, req, res
        next()
      else
        handler = req.handler ? @_defaultHandler()
        throw "There is no handler defined" unless handler
        handler req, res
    chain.push (req, res, next) =>
      doneCb(res.error)
      next()

    context =
      req: new Request(userId, data, @_handlers)
      res: new Response ((message) =>
          @sendBack userId, message, (err) =>
            @_onError(err) if err
          doNext()), -> doNext()

    doNext = =>
      nextStep = chain.shift()
      return if not nextStep
      process.nextTick =>
        try
          nextStep(context.req.toJSON(), context.res.toJSON(), doNext)
        catch e
          @_onError(e)
          context.res.attr("error", e)
          doNext()
    doNext()

  _onError: (error) ->
    console.error error ? "Unknown error"
    console.error error?.stack if error?.stack

  sendBack: (userId, data, cb) ->
    @_client().sendBack(userId, data, cb)

  extendRequest: (properties...) ->
    Request.define properties...

  extendResponse: (properties...) ->
    Response.define properties...

  receive: (pattern, handler) ->
    if _.isFunction(pattern)
      handler = pattern
      pattern = null
    @_handlers.push {pattern:pattern,handler:handler}

  _defaultHandler: ->
    _.findWhere(@_handlers, {pattern:null})?.handler

module.exports = ->
  new Transit()

module.exports.commandLine = require('./clients/command_line/commandLine')
module.exports.icq = require('./clients/icq/icq')

module.exports.doNotWaitForResponse = require('./middleware/do_not_wait_for_response/doNotWaitForResponse')
module.exports.commandParser = require('./middleware/command_parser/commandParser')
module.exports.render = require('./middleware/renderer/renderer')
module.exports.html2txt = require('./middleware/html2txt/html2txt')
module.exports.sessions = require('./middleware/sessions/session_manager')
