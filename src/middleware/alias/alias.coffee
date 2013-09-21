parser = require('../command_parser/parser')
_ = require('underscore')
{EventEmitter} = require('events')

#TODO: persistence for aliases
class Aliases extends EventEmitter
  constructor: (aliases = [], @options = {define: "alias"}) ->
    @aliases = aliases.map @_compile

  define: (alias, replacement) ->
    @aliases.push @_compile pattern:alias, replacement:replacement
    @emit "change", @aliases.map (a) -> {pattern: a.pattern, replacement: a.replacement}

  _compile: (aliasDef) ->
    aliasDef.parsedPattern = parser.parsePattern aliasDef.pattern
    aliasDef

  addToHandlers: (request) ->
    request.attr "handlers", request.handlers.concat @aliases.map (a) -> pattern:a.pattern, handler: -> throw "Alias handler shall not be called"

  process: (request) ->
    return if not request.data
    parsedCommand = parser.parseCommand(request.data)
    if parsedCommand.cmd is @options.define
      @define parsedCommand.args[0], parsedCommand.args[1]
    else
      @replace request, parsedCommand
    @addToHandlers(request)

  replace: (request, {cmd, args}) ->
    @aliases.forEach (a) ->
      matched = a.parsedPattern.match cmd, args
      if matched
        newCmd = a.replacement
        _.each matched.args, (value, name) ->
          newCmd = newCmd.replace new RegExp("{#{name}}", "gi"), value
        request.attr "data", newCmd


memLoad = -> []
memSave = ->

module.exports = (load = memLoad, save = memSave) ->
  global = null
  if load.length <= 1
    oldLoad = load
    load = (name, cb) ->
      cb(oldLoad(name))
  getAliases = (req, cb) ->
    return cb(global) if global
    load "global", (aliases) ->
      global = new Aliases(aliases)
      global.on "change", (aliases) ->
        save aliases
      cb(global)

  (req, res, next) ->
    return next() if not req.data
    getAliases req, (aliases) ->
      aliases.process req
    next()
