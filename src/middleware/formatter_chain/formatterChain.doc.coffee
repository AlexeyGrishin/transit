# Allows to make a chain of formatting functions and register it as transit's formatter, like this:
# ```
# app.formatOutput transit.chain uppercase, split, substituteName
# ```
transit = require('../../transit')
app = transit()
app.use transit.commandLine()
app.use transit.echo()

# Chain accepts 3 types of formatting functions:
#
# * Regular ones (have 3 arguments or more)
substituteName = (data, options, next) ->
  next(data.replace(/{name}/gi, options?.name ? "Unknown"))
# * Functions without options (have 2 arguments)
split = (data, next) ->
  data.split(" ").forEach next
# * Simplified functions (have 1 argument)
uppercase = (data) ->
  data.toUpperCase()

# In most cases it will be enight to use simplified syntax.
app.formatOutput transit.chain uppercase, split, substituteName

app.start()
app.sendBack 1, "hello, {name}!", {name: "Alex"}
# will output
# ```
# HELLO,
# Alex!
# ```
# There is a set of predefined formatting functions you may use:
#
# * [convert json to string](formatJson.html).
app.formatOutput "myFormat", transit.chain transit.chain.json(),
# * [split by portions](formatSplitByPortions.html) - no more than 50 characters for portion.
#    That could be useful (using bigger numbers of course) for IMs with limited message size.
  transit.chain.splitByPortions(50),
# * [wrap each portion with html](formatWrapHtml.html).
  transit.chain.wrapHtml()

# Do not forget you may specify a name for formatter and call it by it.
app.sendBack.myFormat 1, {
  message: "Hello",
  type: "greeting",
  mime: "application/json"
}