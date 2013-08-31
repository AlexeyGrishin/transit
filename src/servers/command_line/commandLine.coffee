readline = require('readline')
rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

userId = 1

module.exports = (options = {}) ->
  install: (transit) ->
    transit.server @
  start: ->
    rl.on 'line', (line) =>
      line = line.trim()
      if line.indexOf(":uid") == 0
        userId = line.split(" ")[1]
        console.log "User id changed to " + userId
        rl.prompt()
      else if line == ':exit'
        @callback userId, command: "exit", (err) ->
          rl.prompt()
      else
        @callback userId, line, (err) ->
          console.error err if err
          console.log "OK" if options.ack
          rl.prompt()
    rl.prompt()
  receive: (@callback) ->
  sendBack: (userId, data, cb) ->
    console.log userId + ": " + data
    cb()