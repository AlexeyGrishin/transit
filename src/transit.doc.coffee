# _Documentation is under construction_
#
# **transit** is a express-like framework for im bots.
#
# **Example** with command line client (try it!)
#
# Example for ICQ client could be [found here](icq.doc.html), but it requires real ICQ account to use
transit = require('./transit')
app = transit()

# Use [command line client](commandLine.html)
app.use transit.commandLine()
# Use [simple commands parser](commandParser.doc.html)
app.use transit.commandParser()
# client [does not wait for response from user hander](doNotWaitForResponse.doc.html)
app.use transit.doNotWaitForResponse()
# Use [renderer](renderer.doc.html)
#app.use transit.renderer()
app.renderer "braces", (data, options, cb) -> cb(null, "(#{data})")

# Define user handler for 'hello' command.
# Use __sendBack__ to send data to client. It could be called any amount of times.
# See also [Request](request.doc.html) and [Response](response.doc.html) objects reference
app.receive 'hello', (req, res) ->
  res.braces "Hello #{req.user}"

# Define user handler for 'echo' command. All command arguments (space-separated) will be available in 'params' field.
app.receive 'echo {{params}}', (req, res) ->
  res.braces req.attrs.params.join(" ")

# Define default user handler. It is called in case command is not matched
app.receive (req, res) ->
  res.sendBack "I do not know what is <#{req.data}> :("


app.start()