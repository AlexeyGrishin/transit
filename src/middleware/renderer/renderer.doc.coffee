# Adds **render** method to the [response](response.doc.html) object which could be used instead of **sendBack**.
# Could be customized with set of renderers, each renderer is function like following:
# ```
# function wrapAngular(data, next) {
#   next("<" + data + ">");
# }
# ```
t = require('../../transit')
transit = t()

transit.use t.commandLine()

# First convert json to string
transit.use t.render t.render.json(),
  # Then split by portions - no more than 15 characters for portion.
  # That could be useful (using bigger numbers of course) for IMs with limited message size
  t.render.splitByPortions(50),
  # Then wrap each portion with html
  t.render.wrapHtml()


transit.receive (req, res) ->
# Try to run and type something to get this json in several messages
  res.render {
    message: "Hello",
    type: "greeting",
    mime: "application/json"
  }

transit.start()