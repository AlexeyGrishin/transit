parser = require('../command_parser/parser')
_ = require('underscore')
{EventEmitter} = require('events')

class Aliases extends EventEmitter
  constructor: (aliases = [], @options = {
      define: "alias",
      autohelp: "registers alias of the existent command"
    }) ->
      @aliases = aliases.map @_compile

  define: (pattern, replacement, autohelp) ->
    @aliases = _.reject @aliases, (a) -> a.pattern == pattern
    alias = {pattern, replacement}
    alias.autohelp = autohelp if autohelp
    @aliases.push @_compile alias if replacement
    @emit "change", @aliases.map (a) -> _.omit(a, "parsedPattern")

  _compile: (aliasDef) ->
    aliasDef.parsedPattern = parser.parsePattern aliasDef.pattern
    aliasDef

  _handler: -> throw new Error("Alias handler shall never be called")

  addToHandlers: (request) ->
    aliases = @aliases.map (a) => pattern:a.pattern, autohelp: a.autohelp, handler: -> @_handler
    self = [{pattern: "alias {newCommand} {existentCommand} {description}", autohelp: @options.autohelp, handler: @_handler}]
    request.attr "handlers", request.handlers.slice().concat(self).concat(aliases)

  process: (request) ->
    @processCommand(request)
    @addToHandlers(request)

  processCommand: (request) ->
    return if not request.data
    parsedCommand = parser.parseCommand(request.data)
    if parsedCommand.cmd is @options.define
      @define parsedCommand.args...
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
