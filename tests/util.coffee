sinon = require('sinon')

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

  populate: ->
    global.serverStub = @serverStub
    global.serverMock = @serverMock