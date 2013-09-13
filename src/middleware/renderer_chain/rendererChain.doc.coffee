# Allows to make a chain of rendering functions and register it as transit's renderer, like this:
# ```
# app.renderer transit.chain uppercase, split, substituteName
# ```
transit = require('../../transit')
app = transit()
app.use transit.commandLine()
app.use transit.echo()

# Chain accepts 3 types of rendering functions:
# 1. Regular ones (have 3 arguments or more)
substituteName = (data, options, next) ->
  next(data.replace(/{name}/gi, options?.name ? "Unknown"))

# 2. Functions without options (have 2 arguments)
split = (data, next) ->
  data.split(" ").forEach next

# 3. Simplified functions (have 1 argument)
uppercase = (data) ->
  data.toUpperCase()

# In most cases it will be enight to use simplified syntax.
app.renderer transit.chain uppercase, split, substituteName

app.start()
app.sendBack 1, "hello, {name}!", {name: "Alex"}
# will output
# ```
# HELLO,
# Alex!