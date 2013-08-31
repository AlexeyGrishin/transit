require('./util').populate()
sinon = require('sinon')
require('jasmine-sinon')
Transit = () ->
  transit = require('../src/transit')()
  transit._onError = ()->   # TODO: find another way to hide error messages
  transit

describe "transit without any other plugins and server", ->
  it "shall throw exception on start", ->
    transit = Transit()
    expect( -> transit.start()).toThrow()

transit = null
server = null
describe "transit without any other plugins and some server", ->

  beforeEach ->
    transit = Transit()
    server = serverMock("!install", "sendBack", "!receive", "start")
    transit.use(server)

  it "shall call install for server", ->
    expect(server.install).toHaveBeenCalledWith(transit)

  it "shall provide callback to the server and start on start", ->
    transit.start()
    expect(server.receive).toHaveBeenCalled()
    expect(typeof server.receive.args[0][0]).toEqual("function")

  it "shall call to the server in case of sendBack is called", ->
    cb = sinon.spy()
    transit.sendBack(11, "test", cb)
    expect(server.sendBack).toHaveBeenCalledWith(11, "test", cb)

  it "shall allow subscribing on commands", ->
    transit.receive "command", ->

  it "shall allow subscribe default handler", ->
    transit.receive ->

  describe "on custom command from server", ->
    beforeEach ->
      transit.start()
      @defHandler = sinon.spy (req, res) ->
        res.done()
      transit.receive (args...) => @defHandler(args...)

    it "shall not call to user handler", (done) ->
      server.callback 3, command: "exit", =>
        expect(@defHandler).not.toHaveBeenCalled()
        done()

    it "shall call event's listener instead", (done) ->
      eventHandler = sinon.spy()
      transit.on "exit", eventHandler
      server.callback 3, command: "exit", =>
        expect(eventHandler).toHaveBeenCalled()
        done()

  describe "on data from server", ->
    describe "", ->
      beforeEach ->
        transit.start()
        @defHandler = sinon.spy (req, res) ->
          res.done()
        transit.receive (args...) => @defHandler(args...)

      it "shall call the default handler on data from server", (done) ->
        server.callback 1, "message", =>
          expect(@defHandler).toHaveBeenCalled()
          done()

      it "shall provide request and response objects to the handler", (done) ->
        server.callback 1, "message", =>
          expect(@defHandler.args[0].length).toEqual(2)
          done()

      it "shall include transfered data into request object", (done)  ->
        server.callback 1, "message", =>
          req = @defHandler.args[0][0]
          expect(req.data).toEqual("message")
          done()

      it "shall not call specific handler", (done) ->
        specHandler = sinon.spy()
        transit.receive specHandler
        server.callback 1, "message", =>
          expect(specHandler).not.toHaveBeenCalled()
          done()

      it "shall send data back to server", (done) ->
        @defHandler = (req, res) =>
          res.sendBack "response"
        server.callback 99, "message", =>
          expect(server.sendBack).toHaveBeenCalledWith(99, "response")
          done()

    it "shall send error back to server", (done) ->
      transit.start()
      defHandler = sinon.stub()
      defHandler.throws("Error!")
      transit.receive defHandler
      server.callback 1, "message", (err) =>
        expect(err).toEqual name:"Error!"
        done()

expectNoError = (done) ->
  (err) ->
    expect(err).toBeUndefined()
    done()

describe "custom middleware as function", ->

  beforeEach ->
    transit = Transit()
    server = serverStub()
    transit.use(server)
    transit.start()

  it "could be installed with 'use' call", ->
    transit.use ->

  it "shall be called before any handler", (done) ->
    handler = sinon.spy (req, res) =>
      expect(middleware).toHaveBeenCalled()
      res.done()
    middleware = sinon.spy (req, res, next) =>
      expect(handler).not.toHaveBeenCalled()
      next()
    transit.use middleware
    transit.receive handler
    server.callback 5, "test", expectNoError(done)


  it "may define handler to be called", (done) ->
    defHandler = sinon.spy (req, res) ->
      expect("default handler shall not be called").toBeUndefined()
      done()
    newHandler = sinon.spy (req, res) ->
      res.done()
    middleware = (req, res, next) ->
      req.attr "handler", newHandler
      next()
    transit.use middleware
    transit.receive defHandler
    server.callback 5, "test", =>
      expect(newHandler).toHaveBeenCalled()
      done()

  it "cannot change request object just accessing its properties", (done) ->
    middleware = (req, res, next) ->
      req.somefield = 55
      next()
    transit.use middleware
    transit.receive (req, res) ->
      expect(req.somefield).toBeUndefined()
      done()
    server.callback 5, "test", expectNoError(done)

  it "cannot specify unknown property for request object ", (done) ->
    middleware = (req, res, next) ->
      req.attr("somefield", 55)
      next()
    transit.use middleware
    transit.receive (req, res) ->
      res.done()
    server.callback 3, "test", (err) ->
      expect(err).toBeDefined()
      done()


  it "may extend the request with new field", (done) ->
    middleware =
      install: (transit) ->
        transit.extendRequest "somefield"
        (req, res, next) ->
          req.attr("somefield", "somevalue")
          next()
    transit.use middleware
    transit.receive (req, res) ->
      expect(req.somefield).toEqual("somevalue")
      done()
    server.callback 5, "test", expectNoError(done)