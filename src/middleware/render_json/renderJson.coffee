# This renderer just stringifies data if it is object
module.exports = () ->
  (data) ->
    if typeof data == 'object'
      JSON.stringify(data, null, 4)
    else
      data
