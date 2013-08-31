_ = require('underscore')

class Private
  constructor: (@_knownProperties = {})->
    if _.isArray @_knownProperties
      props = @_knownProperties
      @_knownProperties = {}
      props.forEach (p) => @define(p)
    @_data = {}

  define: (property, defValue) ->
    Private.define @_knownProperties, property
    unless _.isUndefined defValue
      @_data[property] = defValue

  @define: (properties, property) ->
    properties[property] = "defined"

  attr: (name, value) ->
    throw "There is no property with name '#{name}'" unless @_knownProperties[name]
    if _.isUndefined value
      @_data[name]
    else
      @_data[name] = value
      @

  toJSON: ->
    json = _.clone @_data
    json.attr = (name, value) =>
      @attr(name, value)
      json[name] = @attr(name)
    json


module.exports = Private