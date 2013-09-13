transit
=======
[![Build Status](https://travis-ci.org/AlexeyGrishin/transit.png)](https://travis-ci.org/AlexeyGrishin/transit)

Express-like framework for im bots.

Documentation: [here](http://AlexeyGrishin.github.io/transit)

Example:
```
transit = require('transit')
app = transit()

# Use command line client
app.use transit.commandLine()
# Use simple commands parser
app.use transit.commandParser()
# Make client does not wait for response from user handler
app.use transit.doNotWaitForResponse()

# Define named custom formatter. Formatter is called before sending data back to client.
# In most cases you would like to set up a chain of formatting functions.
app.formatOutput "braces", (data, options, cb) -> cb(null, "(#{data})")

# Define user handler for 'hello' command.
# Use __sendBack__ to send data to client. It could be called any amount of times.
app.receive 'hello', (req, res) ->
  res.sendBack "Hello #{req.user}"

# Define user handler for 'echo' command. All command arguments (space-separated) will be available in 'params' field.
# Here you can see usage of custom formatter __braces__ defined above.
app.receive 'echo {{params}}', (req, res) ->
  res.braces req.attrs.params.join(" ")

# Define default user handler. It is called in case command is not matched
app.receive (req, res) ->
  res.sendBack "I do not know what is <#{req.data}> :("

app.use transit.autohelp {showOnUnknown: false}

# Defines event handler. Events are emitted in special cases like user goes offline (__exit__ event).
# To emulate that type ':exit' in command line.
app.on 'exit', (req, res) ->
  console.log "User #{req.user} left"

# Starts listening to the client
app.start()
```

Example for ICQ
```
# ICQ client receives messages from other ICQ users and allows to respond them.
# This is the main scenario the **transit** was created for.
transit = require('transit')
app = transit()

# Here we create session object. Session object will be associated with icq contact who writes to us.
# Session object is available as ``req.session`` in the handler
class IcqSession
  constructor: (@userId) ->
    console.log "#{@userId} connected"
  getName: -> @name ? "Unknown user #{@userId}"
  setName: (@name) ->
  close: ->
    console.log "#{@userId} disconnected"

# Add icq client. Use icq number as login.
app.use transit.icq {login: "__ICQ_NUMBER__", password: "__PASSWORD__"}
# Convert html to text
app.use transit.html2txt()
# Parse commands
app.use transit.commandParser()
# Use sessions storage (in memory)
app.use transit.sessions sessionClass: IcqSession
# When send something back split by 500 characters and wrap each portion with html
app.formatOutput transit.chain transit.chain.splitByPortions(500), transit.chain.wrapHtml()
# Show help if user made a mistake or types __help__ command.
app.use transit.autohelp()

# After start connect to your bot and type him messages like:
# ```
# > hello
#   Hello Unknown user 555
#
# > callme Big Boss
#   I'll remember that, Big
#
# > callme "Big Boss"
#   I'll remember that, Big Boss
#
# > hello
#   Hello Big Boss
#
# > bottles 2
#   I have 2 bottles of beer. Let's drink one!
#   I have 1 bottles of beer. Let's drink one!
# ```

app.receive 'hello', (req, res) ->
  res.sendBack("Hello #{req.session.getName()}")

app.receive 'callme {name}', (req, res) ->
  req.session.setName(req.attrs.name)
  res.sendBack "I'll remember that, #{req.attrs.name}"

app.receive 'bottles {count}', (req, res) ->
  res.sendBack ([req.attrs.count..1].map (n) -> "I have #{n} bottles of beer. Let's drink one!").join("\n")

app.start()
```