chain = require('../../../src/middleware/renderer_chain/rendererChain')
Transit = require('../../../src/transit')
sinon = require('sinon')
require('jasmine-sinon')

r2 = (suffix) ->
  (data, options, next) ->
    next(data + "_" + suffix)

regular = (data, options, next) ->
  next(data + "_1")

describe "renderer chain", ->

  beforeEach ->
    @cb = sinon.spy()

  it "shall be registerable as renderer", ->
    transit = Transit()
    transit.renderer "method", chain r2(1), r2(2)
    expect(transit.sendBack.method).toBeDefined()

  it "shall call renderers one by one in chain", ->
    renderer = chain r2(2), r2(1)
    renderer("test", null, @cb)
    expect(@cb).toHaveBeenCalledWith(null, "test_2_1")

  it "shall process renderers without options as well", ->
    renderer = chain (data, next) -> next(data + "_3")
    renderer("test", null, @cb)
    expect(@cb).toHaveBeenCalledWith(null, "test_3")

  it "shall process simplified renderers as well", ->
    renderer = chain (data) -> data + "_2"
    renderer("test", null, @cb)
    expect(@cb).toHaveBeenCalledWith(null, "test_2")