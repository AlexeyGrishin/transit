# This middleware just returns back the incoming data.
# Could be useful for renderers debugging.
#
# Ignores all user handlers
module.exports = () ->
  (req, res, next) ->
    req.attr "handler", ->
    if req.data
      res.sendBack req.data
    else
      res.done()
    next()
