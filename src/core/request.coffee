_ = require('underscore')
Private = require('./private')

KnownProperties = {'user', 'data', 'handlers', 'handler', 'command'}
class Request extends Private

  constructor: (user, data, handlers) ->
    super KnownProperties
    @attr("user", user)
    if _.isObject data
      @attr "command", data.command
    else
      @attr("data", data)
    @attr("handlers", handlers)

  @define: (newProperties...) ->
    newProperties.forEach (property) -> Private.define KnownProperties, property

module.exports = Request