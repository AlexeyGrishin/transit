# This is client middleware example.
# Client middleware receives some data from end-user, transfers it to the transit and allows transit send something back.
# Also client middleware can send some custom commands. By default transit does not understand any command, but some
# middlewares may process them. Commands are not passed to user handlers.
readline = require('readline')
rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

userId = 1

# Each client middleware shall provide constructor function which may accept some options
module.exports = (options = {}) ->

  # When *transit.use* is called with object the *transit* calls *install* method of that object
  install: (transit) ->
    # ... and client middleware shall register itself as a client
    transit.client @

  # The provided callback shall be called when external client sends a message to server
  # Its signature is ``function(userId, data, callback)`` where
  # - userId - is any value or object which identifies the client. **transit** does not interpret it somehow.
  # - data - could be string - in this case it is interpreted as data that shall be processed by server handlers.
  #          or it could be an object with special command
  # - callback - to be called in case of error or _when data/command processing is started_
  receive: (@callback) ->

  # This method shall start listening to the external clients and call provided callback
  start: ->
    console.log "Command line client supports special commands to emulate IM interaction:\n" +
      "  :uid {id} - changes the current user's ID (ICQ number for example)\n" +
      "  :exit - emulates user goes offline\n"
    rl.on 'line', (line) =>
      line = line.trim()
      if line.indexOf(":uid") == 0
        userId = line.split(" ")[1]
        console.log "User id changed to " + userId
        rl.prompt()
      else if line == ':exit'
        # This is example of sending command - the object is passed as ``data`` argument.
        @callback userId, command: "exit", (err) ->
          rl.prompt()
      else
        # This is just a text from client - send it to transit
        @callback userId, line, (err) ->
          # This callback is called _after server started processing the request_ or _in case of error_.
          # The response from server could be sent before or after this callback.
          console.error err if err
          console.log "OK" if options.ack
          rl.prompt()
    rl.prompt()

  # This method is used to send data back to client
  sendBack: (userId, data, cb) ->
    console.log userId + ": " + data
    cb()