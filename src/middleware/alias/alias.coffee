parser = require('../command_parser/parser')
_ = require('underscore')
{EventEmitter} = require('events')

class Aliases extends EventEmitter
  constructor: (aliases = [], @options = {define: "alias"}) ->
    @aliases = aliases.map @_compile

  define: (alias, replacement) ->
    @aliases = _.reject @aliases, (a) -> a.pattern == alias
    @aliases.push @_compile pattern:alias, replacement:replacement if replacement
    @emit "change", @aliases.map (a) -> {pattern: a.pattern, replacement: a.replacement}

  _compile: (aliasDef) ->
    aliasDef.parsedPattern = parser.parsePattern aliasDef.pattern
    aliasDef

  addToHandlers: (request) ->
    request.attr "handlers", request.handlers.slice().concat @aliases.map (a) -> pattern:a.pattern, handler: -> throw "Alias handler shall not be called"

  process: (request) ->
    @processCommand(request)
    @addToHandlers(request)

  processCommand: (request) ->
    return if not request.data
    parsedCommand = parser.parseCommand(request.data)
    if parsedCommand.cmd is @options.define
      @define parsedCommand.args[0], parsedCommand.args[1]
      # To prevent further processing
      request.attr "data", null
      request.attr "command", "alias-defined"
    else
      @replace request, parsedCommand

  replace: (request, {cmd, args}) ->
    @aliases.forEach (a) =>
      matched = a.parsedPattern.match cmd, args
      if matched
        newCmd = parser.processArgs a.replacement, (arg) ->
          _.each matched.args, (value, name) ->
            arg = arg.replace new RegExp("\\{#{name}\\}", "gi"), value
          arg
        request.attr "data", newCmd
        @processCommand request


memLoad = -> []
memSave = ->

GLOBAL = "global"

module.exports = (load = memLoad, save = memSave) ->
  global = null
  if load.length <= 1
    oldLoad = load
    load = (name, cb) ->
      cb(oldLoad(name))

  getAliases = (req, cb) ->
    return cb(global) if global
    aliasesId = GLOBAL
    load aliasesId, (aliases) ->
      global = new Aliases(aliases)
      global.on "change", (aliases) ->
        save aliasesId, aliases
      cb(global)

  (req, res, next) ->
    return next() if not req.data
    getAliases req, (aliases) ->
      aliases.process req
    next()
