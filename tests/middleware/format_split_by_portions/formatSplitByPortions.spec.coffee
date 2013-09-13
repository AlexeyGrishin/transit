formatSplit = require('../../../src/middleware/format_split_by_portions/formatSplitByPortions')
sinon = require('sinon')

describe 'formatSplitByPortions', ->


  beforeEach ->
    @cb = sinon.spy()
    @expectHaveBeenCalledWith = (args...) =>
      expect(@cb.callCount).toEqual(args.length)
      args.forEach (a, i) => expect(@cb.args[i]).toEqual(a)

  it "shall do not split data on portions when it is longer than limit", ->
    formatSplit(10) "abcd\n1234", @cb
    @expectHaveBeenCalledWith ["abcd\n1234"]

  it "shall split data on portions when it is longer than limit", ->
    formatSplit(5) "abcd\n1234", @cb
    @expectHaveBeenCalledWith ["abcd"], ["1234"]

  it "shall count CRs as well", ->
    formatSplit(3) "_\n_\n_\n_", @cb
    @expectHaveBeenCalledWith ["_\n_"], ["_\n_"]

  it "shall include several lines in portion if it still smaller than limit", ->
    formatSplit(10) "abcd\n1234\n987654321\n4", @cb
    @expectHaveBeenCalledWith ["abcd\n1234"], ["987654321"], ["4"]

  it "shall throw exception if some line is larger than limit", ->
    expect( -> formatSplit(3) "a\nab\nabc\anabcd").toThrow()
