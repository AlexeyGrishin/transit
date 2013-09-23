# This is example of command line client usage. Try to run it!
transit = require('transit')
app = transit()

# Use [command line client](commandLine.html).
app.use transit.commandLine()

# Allows to specify aliases with 'alias' command.
# Try to type ``alias aloha hello`` and ``alias "swap {1} {2}" "echo {2} {1}"``.
# To delete alias type same command but without target command, this way: ``alias aloha``
app.use transit.alias (
# First optional function shall load aliases from some storage and return them to callback.
  (name, cb) ->
    cb [
      {pattern: "hi", replacement: "hello"},
      {pattern: "jecho {param}", replacement: "echo {param} desu"}
    ]
), (
# Second optional function will be called when aliases are changed, so you may store them.
  (name, data) ->
    console.log "Aliases saved, now there is #{data.length} of them"
)
# __Note__ that this middleware shall be inserted __before__ commandParser().

# Use [simple commands parser](commandParser.doc.html).
app.use transit.commandParser()
# Make client [does not wait for response from user hander](doNotWaitForResponse.doc.html).
app.use transit.doNotWaitForResponse()

# Define named custom formatter. Formatter is called before sending data back to client.
# In most cases you would like to set up a [chain of formatting functions](formatterChain.doc.html).
app.formatOutput "braces", (data, options, cb) -> cb(null, "(#{data})")

# Define user handler for 'hello' command.
# Use __sendBack__ to send data to client. It could be called any amount of times.
app.receive 'hello', (req, res) ->
  res.sendBack "Hello #{req.user}"

# Define user handler for 'echo' command. All command arguments (space-separated) will be available in 'params' field.
# Here you can see usage of custom formatter __braces__ defined above.
app.receive 'echo {{params}}', (req, res) ->
  res.braces req.attrs.params.join(" ")

# Define default user handler. It is called in case command is not matched.
app.receive (req, res) ->
  res.sendBack "I do not know what is <#{req.data}> :("

# Defines the "help" command which lists all existent commands
app.use transit.autohelp {showOnUnknown: false}


# Defines event handler. Events are emitted in special cases like user goes offline (__exit__ event).
# To emulate that type ':exit' in command line.
app.on 'exit', (req, res) ->
  console.log "User #{req.user} left"

# Starts listening to the client.
app.start()
