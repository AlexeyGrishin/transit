util = require('../util')
util.populate()

module.exports =

  withRequest: (middleware, data, test) ->
    middleware = @instantiate(middleware)
    if typeof data == "function"
      test = data
      data = ""
    request = requestStub(data, [])
    response = responseStub()
    middleware request.toJSON(), response.toJSON(), ->
      test(middleware, request, response)

  checkPass: (middleware, data, done) ->
    middleware requestStub(data,[]).toJSON(), responseStub().toJSON(), ->
      done()

  instantiate: (middleware) ->
    if middleware.length < 2
      # it is constructor
      middleware = middleware.apply(middleware)
    if typeof middleware == 'object'
      # need to call install
      middleware = middleware.install util.transit
    middleware

  shallPassCommonMiddlewareTests: (middleware) ->
    middleware = @instantiate(middleware)
    checkPass = @checkPass

    it "shall pass short simple message further", (done) ->
      checkPass middleware, "hello", done

    it "shall pass empty message further", (done) ->
      checkPass middleware, "", done

    it "shall pass command further", (done) ->
      checkPass middleware, command:"bye", done
