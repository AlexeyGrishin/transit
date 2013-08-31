common = require('../common')
renderer = require('../../../src/middleware/renderer/renderer')

describe "renderer", ->

  common.shallPassCommonMiddlewareTests(renderer)

  describe "without renderer functions", ->
    beforeEach ->
      @renderer = common.instantiate(renderer())

    it "shall add 'render' method to the response", ->
      common.withRequest @renderer, (renderer, req, res) ->
       expect(res.attr("render")).toBeDefined()

    it "shall work like 'sendBack' if no one renderer provided", ->
      common.withRequest @renderer, (renderer, req, res) ->
        res.attr("render")("hoora!")
        expect(res.attr("sendBack")).toHaveBeenCalledWith("hoora!")

  render = (text, expected, renderers...) ->
    rendererInstance = common.instantiate(renderer(renderers...))
    common.withRequest rendererInstance, (_, req, res) ->
      res.attr("render")(text)
      expect(res.attr("sendBack")).toHaveBeenCalledWith(expected)

  it "shall accept rendering functions with callback", ->
    render "good", "good_1", (data, next) -> next(data + "_1")

  it "shall accept rendering functions without callback", ->
    render "good", "good_2", (data) -> data + "_2"

  it "shall call rendering functions one by one", ->
    render "good", "good_2_1", ((d) -> d+"_2"), ((d) -> d+"_1")
