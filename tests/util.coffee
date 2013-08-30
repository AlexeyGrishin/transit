sinon = require('sinon')
Request = require('../src/transit/request')
Response = require('../src/transit/response')

module.exports =
  serverStub: -> {
  install: (transit) ->
    transit.server(@)

  start: (options) ->

  receive: (@callback) ->

  sendBack: (userId, data, cb) ->
  }

  serverMock: (methods...) ->
    stub = serverStub()
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
    extendRequest: (props...) ->
      Request.define props...

  responseStub: () ->
    new Response sinon.spy(), sinon.spy()

  populate: ->
    global.serverStub = @serverStub
    global.serverMock = @serverMock
    global.requestStub = @requestStub
    global.responseStub = @responseStub