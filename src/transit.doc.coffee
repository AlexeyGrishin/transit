# _Documentation is under construction_
# **transit** is a express-like framework for im bots
t = require('./transit')
transit = t()

# Use [command line client](commandLine.doc.html)
transit.use t.commandLine()
# Use [simple commands parser](commandParser.doc.html)
transit.use t.commandParser()
# client [does not wait for response from user hander](doNotWaitForResponse.doc.html)
transit.use t.doNotWaitForResponse()
# Use [renderer](renderer.doc.html)
transit.use t.renderer()

# Define user handler for 'hello' command.
# Use __sendBack__ to send data to client. It could be called any amount of times.
# See also [Request](request.doc.html) and [Response](response.doc.html) objects reference
transit.receive 'hello', (req, res) ->
  res.sendBack "Hello #{req.user}"

# Define user handler for 'echo' command. All command arguments (space-separated) will be available in 'params' field.
transit.receive 'echo {{params}}', (req, res) ->
  res.sendBack req.attrs.params.join(" ")

# Define default user handler. It is called in case command is not matched
transit.receive (req, res) ->
  res.sendBack "I do not know what is <#{req.data}> :("


transit.start()