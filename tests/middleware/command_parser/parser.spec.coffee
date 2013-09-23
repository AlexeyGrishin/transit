parser = require('../../../src/middleware/command_parser/parser').parseCommand
parsePattern = require('../../../src/middleware/command_parser/parser').parsePattern
sinon = require('sinon')

describe "command parser", ->

  expectParse = (command) ->
    {cmd, args} = parser command
    toEqual: (expCmd, expArgs) ->
      expect(cmd).toEqual(expCmd)
      expect(args).toEqual(expArgs)

  it "shall parse command without arguments", ->
    expectParse("go").toEqual "go", []

  it "shall parse command with arg": ->
    expectParse("go ahead").toEqual "go", ["ahead"]

  it "shall parse command with quoted arg": ->
    expectParse('go "ahead"').toEqual "go", ["ahead"]

  it "shall parse command with 2 args": ->
    expectParse("go home now").toEqual "go", ["home", "now"]

  it "shall parse command with quoted arg with space": ->
    expectParse('go "home now"').toEqual "go", ["home now"]

  it "shall parse command with several args of different types": ->
    expectParse('one ring "to rule" "them all"').toEqual "one", ["ring", "to rule", "them all"]

describe "pattern parser", ->

  expectPattern = (pattern) ->
    parsed = parsePattern pattern
    toMatch: (cmd, args) ->
      result = parsed.match cmd, args
      expect(result).toBeTruthy()
      withArguments: (map) ->
        expect(result.args).toEqual(map)
    not:
      toMatch: (cmd, args) ->
        result = parsed.match cmd, args
        expect(result).toBeFalsy()

  it "shall match same command with args", ->
    expectPattern("go {direction} {speed}").
      toMatch("go", ["left", "quick"]).
      withArguments direction: "left", speed: "quick"

  it "shall not match another command", ->
    expectPattern("go {direction} {speed}")
      .not.toMatch("og", ["left", "fast"])

  it "shall correctly match wide argument", ->
    expectPattern("what {the} {{hell}}")
      .toMatch("what", ["is", "the", "main", "question"])
      .withArguments the: "is", hell: ["the", "main", "question"]


