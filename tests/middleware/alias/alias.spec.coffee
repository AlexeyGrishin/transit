util = require('../../util')
common = require('../common')
sinon = require('sinon')
require('jasmine-sinon')
aliasCtor = require('../../../src/middleware/alias/alias')

alias = null

describe "alias middleware", ->

  common.shallPassCommonMiddlewareTests(aliasCtor)

  beforeEach ->
    alias = aliasCtor()

  defineAndTest = (setupAlias, testAlias, cb) ->
    common.withRequest alias, setupAlias, (alias, req, res) ->
      common.withRequest alias, testAlias, (alias, req, res) ->
        cb alias, req.toJSON(), res.toJSON()


  it "shall allow to create aliases for simple commands", (done) ->
    defineAndTest "alias \"hi\" \"hello\"", "hi", (alias, req, res) ->
      expect(req.data).toEqual("hello")
      done()

  it "shall allow to create aliases without parameters for parametrized commands", (done) ->
    defineAndTest "alias order66 \"kill jedies\"", "order66", (alias, req, res) ->
      expect(req.data).toEqual("kill jedies")
      done()

  it "shal allow to map alias parameter to real command parameter", (done) ->
    defineAndTest "alias \"transit {train}\" \"express {train}\"", "transit orient", (alias, req, res) ->
      expect(req.data).toEqual("express orient")
      done()

  it "shall allow to map part of parameters", (done) ->
    defineAndTest "alias \"assign {bugId}\" \"update {bugId} status=ASSIGNED\"", "assign 5", (alias, req, res) ->
      expect(req.data).toEqual("update 5 status=ASSIGNED")
      done()

  it "shall add new records to request.handlers", (done) ->
    common.withRequest alias, "alias \"test {me}\" \"test user={me}\"", (alias, req, res) ->
      expect(req.toJSON().handlers[0].pattern).toEqual("test {me}")
      done()





