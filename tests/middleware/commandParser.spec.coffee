util = require('../util')
sinon = require('sinon')
require('jasmine-sinon')
commandParserCtor = require('../../src/middleware/command_parser/commandParser')

describe "command parser middleware", ->

  beforeEach ->
    @mware = commandParserCtor().install util.transit
    @resJson = responseStub().toJSON()
    @handler = sinon.spy()

  it "shall find handler by first word (command)", (done) ->
    req = requestStub("join 5", [{pattern: "join {client}", handler: @handler}])
    @mware req.toJSON(), @resJson, =>
      expect(req.attr("handler")).toEqual(@handler)
      done()


  it "shall not set up any handler if there is no match", (done)->
    req = requestStub("leave", [{pattern: "join {client}", handler: @handler}])
    @mware req.toJSON(), @resJson, =>
      expect(req.attr("handler")).toBeUndefined()
      done()

  it "shall do nothing if request is a command", (done) ->
    req = requestStub(command: "exit", [{pattern: "join {client}", handler: @handler}])
    @mware req.toJSON(), @resJson, =>
      expect(req.attr("handler")).toBeUndefined()
      done()

