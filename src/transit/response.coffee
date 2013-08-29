_ = require('underscore')
Private = require('./private')

KnownProperties = {'data', 'error', 'sendBack', 'done'}
class Response extends Private

  constructor: (sendBack, done) ->
    super KnownProperties
    @attr("sendBack", sendBack)
    @attr("done", done)

  @define: (newProperties...) ->
    newProperties.forEach (property) -> Private.define KnownProperties, property


module.exports = Response