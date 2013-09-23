# This middleware automatically calls to _res.done()_ before calling user handler, so you do not need to care about it.
#
# **Request extensions**
#
# None
#
# **Response extention**
#
# None
#
# ** Example **
transit = require('transit-im')
app = transit()

app.use transit.commandLine ack:true

# It does not accept any options
app.use transit.doNotWaitForResponse()

app.receive (req, res) ->
  # Note that we dod not call to _res.done()_ here
  console.log "Received #{req.data}"

app.start()