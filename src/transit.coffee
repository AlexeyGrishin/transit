_ = require('underscore')
Request = require('./core/request')
Response = require('./core/response')
{EventEmitter} = require('events')


class Transit extends EventEmitter
  constructor: ->
    @_handlers = []
    @_chain = []
    @_renderers = {}
    @_defaultRenderingMethod = (data, options, cb) -> cb(null, data)

  use: (middleware) ->
    middlewareObject = => middleware.install(@) if not _.isFunction middleware
    middlewareInstallingFunction = => middleware(@) if _.isFunction(middleware) and middleware.length <= 1
    middleware = middlewareObject() ? middlewareInstallingFunction() ? middleware
    @_chain.push middleware if _.isFunction middleware

  client: (client) ->
    @_client = -> client
    undefined

  #TODO: rename 'client' to 'input' and 'renderer' to 'output'
  renderer: (method, renderer) ->
    if _.isFunction method
      renderer = method
      method = "_default"
      @_defaultRenderingMethod = renderer
    @_renderers[method] = renderer
    @extendResponse method
    @sendBack[method] = (userId, data, options, cb) =>
      @_send userId, data, renderer, options, cb

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

    for name, method of @_renderers
      context.res.attr name, (data, options) =>
        @_send userId, data, method, options, (err) =>
          @_onError(err) if err
        doNext()

    doNext = (error) =>
      @_onError(error) if error
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

  sendBack: (userId, data, options, cb = ->) ->
    @_send userId, data, @_defaultRenderingMethod, options, cb

  _send: (userId, data, renderingFunction, options, cb = ->) ->
    if _.isFunction(options)
      cb = options
      options = null
    renderingFunction data, options, (error, dataToRender) =>
      return cb(error) if error
      @_sendDataBack userId, dataToRender, cb

  _sendDataBack: (userId, data, cb) ->
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
module.exports.chain = require('./middleware/renderer_chain/rendererChain')
module.exports.html2txt = require('./middleware/html2txt/html2txt')
module.exports.sessions = require('./middleware/sessions/session_manager')
module.exports.echo = require('./middleware/echo/echo')
module.exports.autohelp = require('./middleware/autohelp/autohelp')
