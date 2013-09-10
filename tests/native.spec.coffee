require('./util').populate()
sinon = require('sinon')
require('jasmine-sinon')
Transit = () ->
  transit = require('../src/transit')()
  transit._onError = ()->   # TODO: find another way to hide error messages
  transit

describe "transit without any other plugins and client", ->
  it "shall throw exception on start", ->
    transit = Transit()
    expect( -> transit.start()).toThrow()

transit = null
client = null
describe "transit without any other plugins and some client", ->

  beforeEach ->
    transit = Transit()
    client = clientMock("!install", "sendBack", "!receive", "start")
    transit.use(client)

  it "shall call install for client", ->
    expect(client.install).toHaveBeenCalledWith(transit)

  it "shall provide callback to the client and start on start", ->
    transit.start()
    expect(client.receive).toHaveBeenCalled()
    expect(typeof client.receive.args[0][0]).toEqual("function")

  it "shall call to the client in case of sendBack is called", ->
    cb = sinon.spy()
    transit.sendBack(11, "test", cb)
    expect(client.sendBack).toHaveBeenCalledWith(11, "test", cb)

  it "shall allow subscribing on commands", ->
    transit.receive "command", ->

  it "shall allow subscribe default handler", ->
    transit.receive ->

  describe "on custom command from client", ->
    beforeEach ->
      transit.start()
      @defHandler = sinon.spy (req, res) ->
        res.done()
      transit.receive (args...) => @defHandler(args...)

    it "shall not call to user handler", (done) ->
      client.callback 3, command: "exit", =>
        expect(@defHandler).not.toHaveBeenCalled()
        done()

    it "shall call event's listener instead", (done) ->
      eventHandler = sinon.spy()
      transit.on "exit", eventHandler
      client.callback 3, command: "exit", =>
        expect(eventHandler).toHaveBeenCalled()
        done()

  describe "on data from client", ->
    describe "", ->
      beforeEach ->
        transit.start()
        @defHandler = sinon.spy (req, res) ->
          res.done()
        transit.receive (args...) => @defHandler(args...)

      it "shall call the default handler on data from client", (done) ->
        client.callback 1, "message", =>
          expect(@defHandler).toHaveBeenCalled()
          done()

      it "shall provide request and response objects to the handler", (done) ->
        client.callback 1, "message", =>
          expect(@defHandler.args[0].length).toEqual(2)
          done()

      it "shall include transfered data into request object", (done)  ->
        client.callback 1, "message", =>
          req = @defHandler.args[0][0]
          expect(req.data).toEqual("message")
          done()

      it "shall not call specific handler", (done) ->
        specHandler = sinon.spy()
        transit.receive specHandler
        client.callback 1, "message", =>
          expect(specHandler).not.toHaveBeenCalled()
          done()

      it "shall send data back to client", (done) ->
        @defHandler = (req, res) =>
          res.sendBack "response"
        client.callback 99, "message", =>
          expect(client.sendBack).toHaveBeenCalledWith(99, "response")
          done()

    it "shall send error back to client", (done) ->
      transit.start()
      defHandler = sinon.stub()
      defHandler.throws("Error!")
      transit.receive defHandler
      client.callback 1, "message", (err) =>
        expect(err).toEqual name:"Error!"
        done()

expectNoError = (done) ->
  (err) ->
    expect(err).toBeUndefined()
    done()


describe "rendering middleware", ->

  beforeEach ->
    transit = Transit()
    client = clientMock("!install", "sendBack", "!receive", "start")
    transit.use(client)
    @renderer1 = sinon.spy (dataToRender) ->
    @ejsRenderer = sinon.spy (dataToRender, options) ->
    @renderer1Installer = (transit) =>
      transit.renderer "render1", @renderer1
      null
    @ejsRendererInstaller= (transit) =>
      transit.renderer "ejs", @ejsRenderer
      null


  it "could be registered as used by default", ->
    transit.use @renderer1Installer
    transit.use "render1"
    transit.sendBack 11, "hello"
    expect(@renderer1).toHaveBeenCalled()
    expect(@renderer1.args[0][0]).toEqual("hello")

  it "could be called by name", ->
    transit.use @renderer1Installer
    transit.use "Render1"
    transit.use @ejsRendererInstaller
    transit.sendBack.ejs 11, "hello"
    expect(@renderer1).not.toHaveBeenCalled()
    expect(@ejsRenderer).toHaveBeenCalled()
    expect(@ejsRenderer.args[0][0]).toEqual("hello")

  it "shall accept provided options", ->
    transit.use @ejsRendererInstaller
    transit.sendBack.ejs 11, "hello", {flag:true}
    expect(@ejsRenderer).toHaveBeenCalled()
    expect(@ejsRenderer.args[0][0]).toEqual("hello")
    expect(@ejsRenderer.args[0][1]).toEqual {flag:true}

  it "shall be possible to use rendering method in response", (done) ->
    transit.use @ejsRendererInstaller
    transit.receive (req, res) ->
      res.ejs "Answer"
    transit.start()
    client.callback 1, "Hello", () =>
      expect(@ejsRenderer).toHaveBeenCalled()
      done()

describe "custom middleware as object", ->

  it "could be installed with 'use' call with calling 'install' method", ->
    obj = {install: sinon.spy((transit) ->)}
    transit = Transit()
    transit.use obj
    expect(obj.install).toHaveBeenCalledWith(transit)

describe "custom middleware installing function (with arity = 1)", ->

  it "shall be called when transfer to use", ->
    installingFunction = sinon.spy()
    transit = Transit()
    transit.use installingFunction
    expect(installingFunction).toHaveBeenCalledWith(transit)

describe "custom middleware as function", ->

  beforeEach ->
    transit = Transit()
    client = clientStub()
    transit.use(client)
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
    client.callback 5, "test", expectNoError(done)


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
    client.callback 5, "test", =>
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
    client.callback 5, "test", expectNoError(done)

  it "cannot specify unknown property for request object ", (done) ->
    middleware = (req, res, next) ->
      req.attr("somefield9", 55)
      next()
    transit.use middleware
    transit.receive (req, res) ->
      res.done()
    client.callback 3, "test", (err) ->
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
    client.callback 5, "test", expectNoError(done)