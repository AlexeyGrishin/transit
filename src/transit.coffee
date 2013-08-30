_ = require('underscore')
Request = require('./transit/request')
Response = require('./transit/response')

class Transit
  constructor: ->
    @_handlers = []
    @_chain = []

  use: (middleware) ->
    if not _.isFunction middleware
      middleware = middleware.install(@)
    @_chain.push middleware if _.isFunction middleware

  server: (server) ->
    @_server = -> server
    undefined

  _server: ->
    throw "Please install server"

  start: (options) ->
    @_server().receive @_onRequest.bind(@)
    @_server().start options

  _onRequest: (userId, data, doneCb) ->
    chain = @_chain.slice()
    chain.push (req, res) =>
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

    doNext = (req, res) =>
      context.req = req if req
      context.res = res if res
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
    @_server().sendBack(userId, data, cb)

  extendRequest: (properties...) ->
    Request.define properties

  extendResponse: (properties...) ->
    Response.define properties

  on: (pattern, handler) ->
    if _.isFunction(pattern)
      handler = pattern
      pattern = null
    @_handlers.push {pattern:pattern,handler:handler}

  _defaultHandler: ->
    _.findWhere(@_handlers, {pattern:null})?.handler

module.exports = ->
  new Transit()