# This middleware just removes html tags from input data.
#
# That could be useful for icq because some clients send messages in html.
#
# **Request extensions**
#
# None
#
# **Response extention**
#
# None
#
html2text = (html) ->
  html.replace(/<(?:.|)*?>/gm, '').replace(/\r/gm, '').replace(/&quot;/gi, '"') if html

module.exports = () ->
  (req, res, next) ->
    req.attr "data", html2text(req.data)
    next()