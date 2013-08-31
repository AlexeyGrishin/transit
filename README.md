transit
=======

Express-like framework for im bots 

Example:
```
t = require('transit')
transit = t()

# Use command line server
transit.use t.commandLine()
# Use simple commands parser
transit.use t.commandParser()
# Server does not wait for response from user hander
transit.use t.doNotWaitForResponse()

# Define user handler for 'hello' command.
# Use __sendBack__ to send data to server. It could be called any amount of times.
transit.receive 'hello', (req, res) ->
  res.sendBack "Hello #{req.user}"

# Define user handler for 'echo' command. All command arguments (space-separated) will be available in 'params' field.
transit.receive 'echo {{params}}', (req, res) ->
  res.sendBack req.attrs.params.join(" ")

# Define default user handler. It is called in case command is not matched
transit.receive (req, res) ->
  res.sendBack "I do not know what is <#{req.data}> :("

transit.start()
```