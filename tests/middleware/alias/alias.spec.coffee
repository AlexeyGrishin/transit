util = require('../../util')
common = require('../common')
sinon = require('sinon')
require('jasmine-sinon')
aliasCtor = require('../../../src/middleware/alias/alias')

alias = null

describe "alias middleware", ->

  common.shallPassCommonMiddlewareTests(->aliasCtor())

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

  it "shall allow delete alias", (done) ->
    common.withRequest alias, "alias hi hello", ->
      common.withRequest alias, "alias hi", (alias, req, res) ->
        common.withRequest alias, "hi", (alias, req, res) ->
          expect(req.toJSON().data).toEqual("hi")
          done()

  it "shal allow to map alias parameter to real command parameter", (done) ->
    defineAndTest "alias \"transit {train}\" \"express {train}\"", "transit orient", (alias, req, res) ->
      expect(req.data).toEqual("express orient")
      done()

  it "shall allow to map part of parameters", (done) ->
    defineAndTest "alias \"assign {bugId}\" \"update {bugId} status=ASSIGNED\"", "assign 5", (alias, req, res) ->
      expect(req.data).toEqual("update 5 status=ASSIGNED")
      done()

  it "shall correctly map parameters with spaces", (done) ->
    defineAndTest 'alias "delegate {bugId} {user}" "update {bugId} assignee={user}"', 'delegate 5 "Luke Skywalker"', (alias, req, res) ->
      expect(req.data).toEqual('update 5 "assignee=Luke Skywalker"')
      done()

  it "shall correctly map parameters named with numbers", (done) ->
    defineAndTest 'alias "do {1}" "execute {1}"', "do 5", (alias, req, res) ->
      expect(req.data).toEqual("execute 5")
      done()

  it "shall exclude 'alias' data from further parsing", (done) ->
    common.withRequest alias, 'alias hi hello', (alias, req, res) ->
      expect(req.toJSON().data).toBeNull()
      expect(req.toJSON().command).toEqual 'alias-defined'
      done()

  it "shall process alias of alias to get real command", (done) ->
    common.withRequest alias, "alias b c", (alias, req, res) ->
      common.withRequest alias, "alias a b", (alias, req, res) ->
        common.withRequest alias, "a", (alias, req, res) ->
          expect(req.toJSON().data).toEqual("c")
          done()

  it "shall add new records to request.handlers", (done) ->
    common.withRequest alias, "alias \"test {me}\" \"test user={me}\"", (alias, req, res) ->
      expect(req.toJSON().handlers[0].pattern).toEqual("alias {newCommand} {existentCommand} {description}")
      expect(req.toJSON().handlers[1].pattern).toEqual("test {me}")
      done()

  it "shall provide documentation in handlers as well", (done) ->
    common.withRequest alias, "alias hi hello help", (alias, req, res) ->
      expect(req.toJSON().handlers[1].autohelp).toEqual("help")
      done()

  it "shall load aliases on first call and save aliases on change", (done) ->
    load = sinon.spy(-> [])
    save = sinon.spy()
    alias = aliasCtor load, save
    common.withRequest alias, "alias hi hello", (alias, req, res) ->
      expect(load).toHaveBeenCalled()
      expect(save).toHaveBeenCalledWith("global", [pattern: "hi", replacement: "hello"])
      done()




