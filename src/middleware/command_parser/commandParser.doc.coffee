# This middleware allows register user handlers on commands using patterns like the following:
#
# **Request extensions**
#
# None
#
# **Response extention**
#
# None
#
# ** Example **
transit = require('transit')
app = transit()
app.use transit.commandLine()
app.use transit.commandParser()
app.use transit.autohelp()

# * simple command without arguments
app.receive 'hello', (req, res) ->
  res.sendBack "Hi!"

# * command with named arguments. Arguments are space separated.
#   If you need to provide argument with space inside just wrap it in quotes, like this:
#   ``add2 6 "8 9"``
app.receive 'add2 {first} {second}', (req, res) ->
  res.sendBack summarize [req.attrs.first, req.attrs.second]

# * command with variable arguments count.
#   there shall be only one variable argument in the pattern
app.receive 'addN {{numbers}}', (req, res) ->
  res.sendBack summarize req.attrs.numbers

app.receive 'stop', (req, res) ->
  res.sendBack ":("
  process.exit()

app.start()

summarize = (numbers) ->
  numbers.map((n)->parseInt(n)).reduce (a,b) -> a + b

