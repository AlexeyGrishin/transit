_ = require('underscore')
Private = require('./private')

KnownProperties = {'user', 'data', 'handlers', 'handler'}
class Request extends Private

  constructor: (user, data, handlers) ->
    super KnownProperties
    @attr("user", user)
    @attr("data", data)
    @attr("handlers", handlers)

  @define: (newProperties...) ->
    newProperties.forEach (property) -> Private.define KnownProperties, property

module.exports = Request