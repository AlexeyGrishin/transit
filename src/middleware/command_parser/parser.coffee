_ = require('underscore')

module.exports =
  parseCommand: (command) ->
    firstSpaceIdx = command.indexOf(' ')
    args = []
    if firstSpaceIdx > -1
      cmd = command.substring(0, firstSpaceIdx).trim()
      parts = command.substring(firstSpaceIdx).split(' ')
      inQuotes = false
      newArg = ''
      for part in parts
        if part.trim().length == 0 then continue
        if part[0] == '"'
          inQuotes = true
          part = part.substring(1)
        if part[part.length-1] == '"'
          inQuotes = false
          part = part.substring(0, part.length-1)
        if newArg.length > 0 then newArg += ' '
        newArg += part
        if not inQuotes
          args.push newArg
          newArg = ''
    else
      cmd = command
    return {cmd, args}


  processArgs: (commandPattern, argCallback) ->
    {cmd, args} = @parseCommand(commandPattern)
    [cmd].concat(args.map(argCallback).map (a) ->
      if a.indexOf(' ') >= 0
        '"' + a + '"'
      else
        a
    ).join(" ")



  parsePattern: (pattern, cb = ->) ->
    parts = pattern.split(' ')
    parsed =
      cmd: parts.shift()
      args: []
      restArg: null
      match: (cmd, args) ->
        return null if cmd != @cmd
        @collectArgs(args)

      collectArgs: (args) ->
        map = {}
        map[@restArg] = [] if @restArg
        for arg, index in args
          if @args[index]
            map[@args[index]] = arg
          else if @restArg
            map[@restArg].push arg
        args: map
        cb: cb

    for part in parts
      if part[0] == '{'
        part = part.substring(1, part.length - 1)
      if part[0] == '{'
        parsed.restArg = part.substring(1, part.length - 1)
      else
        parsed.args.push part

    parsed


  forEachPortion: (text, maxPortionLength, forPortion) ->
    lines = text.split("\n")
    lengths = lines.map (l) -> l.length
    throw "Cannot split text - there are lines larger than specified limit" if Math.max.apply(null, lengths) > maxPortionLength
    buffer = []
    sum = 0
    CRLF = 1
    for length, index in lengths
      if sum + length > maxPortionLength
        forPortion buffer.join("\n")
        buffer = []
        sum = 0
      buffer.push lines[index]
      sum += length + CRLF
    forPortion buffer.join("\n") if buffer.length
