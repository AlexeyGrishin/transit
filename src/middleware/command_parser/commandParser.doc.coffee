t = require('transit')
transit = t()
transit.use t.commandLine()
transit.use t.commandParser()
# This middleware allows register user handlers on commands using patterns like the following:

# * simple command without arguments
transit.receive 'hello', (req, res) ->
  res.sendBack "Hi!"

# * command with named arguments. Arguments are space separated.
#   If you need to provide argument with space inside just wrap it in quotes, like this:
#   ``add2 6 "8 9"``
transit.receive 'add2 {first} {second}', (req, res) ->
  res.sendBack summarize [req.attrs.first, req.attrs.second]

# * command with variable arguments count.
#   there shall be only one variable argument in the pattern
transit.receive 'addN {{numbers}}', (req, res) ->
  res.sendBack summarize req.attrs.numbers

transit.receive 'stop', (req, res) ->
  res.sendBack ":("
  process.exit()

transit.start()

summarize = (numbers) ->
  numbers.map((n)->parseInt(n)).reduce (a,b) -> a + b

