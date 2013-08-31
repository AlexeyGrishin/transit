html2txt = require('../../../src/middleware/html2txt/html2txt')
common = require('../common')

describe 'html2txt', ->

  common.shallPassCommonMiddlewareTests(html2txt)

  it "shall remove all html tags", (done) ->
    common.withRequest html2txt, "<p>Transit is <b>express</b>-like framework. <br/>Really.</p>", (m, req, res) ->
      expect(req.attr("data")).toEqual("Transit is express-like framework. Really.")
      done()

  it "shall restore quotes", (done) ->
    common.withRequest html2txt, "What is &quot;transit&quot;?", (m, req, res) ->
      expect(req.attr("data")).toEqual('What is "transit"?')
      done()
