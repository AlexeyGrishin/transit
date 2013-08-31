parser = require('./parser')

parsedCache = null

prepareCache = (handlers) ->
  return if parsedCache != null
  parsedCache = {}
  handlers.filter((h)->h.pattern).forEach (h) =>
    parsed = parser.parsePattern h.pattern, h.handler
    parsedCache[parsed.cmd] = parsed

module.exports = (parserObject = parser) ->
  throw "You forgot to call constructor of commandParser middleware" if parserObject.user
  install: (transit) ->
    transit.extendRequest "attrs"
    (req, res, next) ->
      return next() if not req.data
      prepareCache req.handlers
      parsedData = parser.parseCommand(req.data)
      if parsedCache[parsedData.cmd]
        {cb, args} = parsedCache[parsedData.cmd].collectArgs(parsedData.args)
        req.attr("handler", cb)
        req.attr("attrs", args)
      next()