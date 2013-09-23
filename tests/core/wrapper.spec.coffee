wrap = require('../../src/core/callbackWrapper')
sinon = require('sinon')
require('jasmine-sinon')

describe "callback wrapper", ->

  beforeEach ->
    @func = sinon.spy (data) ->
    @callback = wrap(@func).asCallback

  it "shall call function for error", ->
    @callback "error"
    expect(@func).toHaveBeenCalledWith("error")

  it "shall call function for valid result", ->
    @callback null, "ok"
    expect(@func).toHaveBeenCalledWith("ok")
