chain = require('../../../src/middleware/formatter_chain/formatterChain')
Transit = require('../../../src/transit')
sinon = require('sinon')
require('jasmine-sinon')

r2 = (suffix) ->
  (data, options, next) ->
    next(data + "_" + suffix)

regular = (data, options, next) ->
  next(data + "_1")

describe "formatters chain", ->

  beforeEach ->
    @cb = sinon.spy()

  it "shall be registerable as formatter", ->
    transit = Transit()
    transit.formatOutput "method", chain r2(1), r2(2)
    expect(transit.sendBack.method).toBeDefined()

  it "shall call formatting functions one by one in chain", ->
    formatter = chain r2(2), r2(1)
    formatter("test", null, @cb)
    expect(@cb).toHaveBeenCalledWith(null, "test_2_1")

  it "shall process formatting functions without options as well", ->
    formatter = chain (data, next) -> next(data + "_3")
    formatter("test", null, @cb)
    expect(@cb).toHaveBeenCalledWith(null, "test_3")

  it "shall process simplified formatting functions as well", ->
    formatter = chain (data) -> data + "_2"
    formatter("test", null, @cb)
    expect(@cb).toHaveBeenCalledWith(null, "test_2")