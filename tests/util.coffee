sinon = require('sinon')
Request = require('../src/core/request')
Response = require('../src/core/response')

module.exports =
  clientStub: -> {
  install: (transit) ->
    transit.client(@)

  start: (options) ->

  receive: (@callback) ->

  sendBack: (userId, data, cb) ->
  }

  clientMock: (methods...) ->
    stub = clientStub()
    for m in methods
      if m[0] == "!"
        m = m.substring(1)
        stub[m] = sinon.stub(stub, m, stub[m])
      else
        stub[m] = sinon.stub(stub, m)
    stub

  requestStub: (data, handlers = []) ->
    new Request(5, data, handlers)

  transit:
    formatOutput: (method, arg) ->
    extendResponse: (props...) ->
      Response.define props...
    extendRequest: (props...) ->
      Request.define props...

  responseStub: () ->
    new Response sinon.spy(), sinon.spy()

  populate: ->
    global.clientStub = @clientStub
    global.clientMock = @clientMock
    global.requestStub = @requestStub
    global.responseStub = @responseStub