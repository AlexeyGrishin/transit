_ = require('underscore')
Request = require('./core/request')
Response = require('./core/response')
{EventEmitter} = require('events')
callbackWrap = require('./core/callbackWrapper')


class Transit extends EventEmitter
  constructor: ->
    @_handlers = []
    @_chain = []
    @_formatters = {}
    @_defaultFormattingMethod = (data, options, cb) -> cb(null, data)

  use: (middleware) ->
    middlewareObject = => middleware.install(@) if not _.isFunction middleware
    middlewareInstallingFunction = => middleware(@) if _.isFunction(middleware) and middleware.length <= 1
    middleware = middlewareObject() ? middlewareInstallingFunction() ? middleware
    @_chain.push middleware if _.isFunction middleware

  client: (client) ->
    @_client = -> client
    undefined

  formatOutput: (method, formatter) ->
    if _.isFunction method
      formatter = method
      method = "_default"
      @_defaultFormattingMethod = formatter
    @_formatters[method] = formatter
    @extendResponse method
    @sendBack[method] = (userId, data, options, cb) =>
      @_send userId, data, formatter, options, cb

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
      res: new Response callbackWrap((message) =>
          @sendBack userId, message, (err) =>
            @_onError(err) if err
          doNext()), -> doNext()

    defineRenderer = (name, method) ->
      context.res.attr name, callbackWrap((data, options) =>
        @_send userId, data, method, options, (err) =>
          @_onError(err) if err
        doNext()
      )

    for name, method of @_formatters
      defineRenderer name, method

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
    @_send userId, data, @_defaultFormattingMethod, options, cb

  _send: (userId, data, formattingFunction, options, cb = ->) ->
    if _.isFunction(options)
      cb = options
      options = null
    formattingFunction data, options, (error, dataToFormat) =>
      return cb(error) if error
      @_sendDataBack userId, dataToFormat, cb

  _sendDataBack: (userId, data, cb) ->
    @_client().sendBack(userId, data, cb)

  extendRequest: (properties...) ->
    Request.define properties...

  extendResponse: (properties...) ->
    Response.define properties...

  receive: (pattern, optionsOrHandler, handler) ->
    options = {}
    if _.isFunction(handler)
      # receive patternAsStr, options, handler
      options = optionsOrHandler
    else if _.isFunction(pattern)
      # receive handler
      handler = pattern
      pattern = null
    else if _.isObject(pattern)
      # receive patternAsObj, handler
      options = pattern
      {pattern} = pattern
      handler = optionsOrHandler
    else
      # receive patternAsStr, handler
      handler = optionsOrHandler
    throw new Error("Handler shall be a function, but it is #{JSON.stringify(handler)}") unless _.isFunction(handler)
    handlerDef = _.extend _.clone(options), {pattern, handler}
    @_handlers.push handlerDef

  _defaultHandler: ->
    _.findWhere(@_handlers, {pattern:null})?.handler

module.exports = ->
  new Transit()

module.exports.commandLine = require('./clients/command_line/commandLine')
module.exports.icq = require('./clients/icq/icq')

module.exports.doNotWaitForResponse = require('./middleware/do_not_wait_for_response/doNotWaitForResponse')
module.exports.commandParser = require('./middleware/command_parser/commandParser')
module.exports.chain = require('./middleware/formatter_chain/formatterChain')
module.exports.html2txt = require('./middleware/html2txt/html2txt')
module.exports.sessions = require('./middleware/sessions/session_manager')
module.exports.echo = require('./middleware/echo/echo')
module.exports.autohelp = require('./middleware/autohelp/autohelp')
module.exports.alias = require('./middleware/alias/alias')
