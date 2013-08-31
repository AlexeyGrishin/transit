module.exports = () ->
  (data, next) ->
    data = JSON.stringify(data, null, 4) if typeof data == 'object'
    next(data)