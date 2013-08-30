transit = require('./transit')()
doNotWaitForResponse = require('./utils/doNotWaitForResponse')
commandLineServer = require('./servers/commandLine')
commandProcessor = require('./command_processors/commandParser')

transit.use commandLineServer
transit.use commandProcessor()
transit.use doNotWaitForResponse

transit.on 'hello', (req, res) ->
  res.sendBack "Hello #{req.user}"

transit.on 'echo {{params}}', (req, res) ->
  res.sendBack req.attrs.params.join(" ")


transit.start()