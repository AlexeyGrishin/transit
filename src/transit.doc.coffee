# **transit** is a express-like framework for im bots. It allows to process the commands received by ICQ (or other IM service)
# then interpret them and respond somehow to the user. Also it may send some messages to the users in background,
# not only as response to the request.
#
# In general it works the following way:
# ```
#          'hello'   Middleware   (req, res)                 sendBack 'hi!'
# Client -----------> Middleware -----------> User handler ---------------\
#                      Middleware                                         |
#                                                                         |
#             '<b>HI!</b>'            Formatter                           |
# Client <---------------------------- Formatter <------------------------/
#                                       Formatter
#
# ```
# ## Transit application initialization
# __transit__ app is initialized the similar way as express app:
#
transit = require('transit')
app = transit()
#
# ## Clients
# **Client** provides interface between end user and __transit__ - receives messages and allows to send response back.
#
# **Client** shall be registered with __use__ method call. There shall be an object with several methods defined:
app.use {
# _install_ is called by __transit__
  install: (transit) ->
    transit.client @
# The provided callback shall be called when external client sends a message to server
# Its signature is ``function(userId, data, callback)``
  receive: (@callback) ->
# _start_ method shall start listening to the external clients and call provided callback
  start: ->
# _sendBack_ method is used to send data back to client
  sendBack: (userId, data, cb) ->
}
#
# [Learn more](commandLine.html) on example of command line client
#
# There are 2 builtin clients:
#
# 1. [Command line client](commandLine.doc.html)
# 2. [ICQ client](icq.doc.html)
#
# ## Middleware
# **Middleware** is called on each request before your application logic. It could be used to perform some preliminary
# actions, extract something, and so on.
#
# **Middleware** shall be registered with __use__ method call. There are 2 ways to define middleware
#
# ##### function middleware
# It accepts **Request** object, **Response** object and **next** callback. **next** callback shall be called anyway, otherwise
# message will not be processed.
app.use (req, res, next) ->
# The following properties are available in request by default:
#
# - _user_ - user id (ICQ number, for example)
# - _command_ - special command sent by client. For example 'exit' is sent when user logs out
# - _data_ - string message from end-user. May be undefined in case of command.
# - _handlers_ - list of user handlers. Use it if you'd like to write your own command parser
# - _handler_ - is user handler that will be called to process this message
  console.log req.user
  console.log req.command
  console.log req.data
  console.log req.handlers
  console.log req.handler
# - _session_ - user's session object. Exists only when __sessions__ middleware is included.
  console.log req.session
# You may change properties of request or response objects, but not by direct assignment - instead you need to call
# 'attr' method
  req.data = "[" + req.data + "]"         # WRONG
  req.attr("data", "[" + req.data + "]")  # Right
# With **Response** object you may send something back to user. You do not need to specify user id
  res.sendBack "Data received, processing..."
# Do not forget to call the next()!
  next()

# ##### object middleware
#
# You need to define 'install' method which shall return middleware function. Install method accepts __transit__ application
# instance.
app.use {
  install: (transit) ->
# You may use it to add new properties to request/response. Without this extension you'll get error if you call 'attr' with
# unknown attrbute name
    transit.extendRequest "myRequestProperty"
    (req, res, next) ->
      req.attr "myRequestProperty", "dummy"
      next()
}
#
# ## User handler
#
# **User handler** is what your application do on specific command.
#
# Initially you may define global handler which is called on each command.
app.receive (req, res) ->
  res.sendBack "Echoed: #{req.data}"
# Note that for user handler you do not have 'next' callback. Instead you need to call one of the **Response** object methods -
# __sendBack__ if you'd like to send something to client or __done__ if not.
#
# If you set up special middleware for command parsing then you may provide user handlers for specific commands.
#
# There is a builtin middleware for that purposes - [command parser](commandParser.doc.html)
#
app.use transit.commandParser
app.receive 'hello', (req, res) -> res.sendBack 'hi'
app.receive 'iam {name}', (req, res) -> res.sendBack "hi #{req.name}"
app.receive 'wishes {{list}}', (req, res) -> res.sendBack "your wish list has #{req.list.length} items"
#
# [Learn more](commandParser.doc.html)
#
# ## Formatter
#
# Before sending data back to client you may want to format it somehow. You may define formatters for that purpose:
niceFormat = (data, options, callback) ->
  braces = options?.braces ? "[]"
  formattedData = braces[0] + data + braces[1]
  callback null, formattedData

app.formatOutput niceFormat
# Then it will be used when you call __sendBack__
app.sendBack 11, "hi!", ->
app.receive (req, res) ->
  res.sendBack req.data, braces: "<>"

# Or you may define several formatters with their own names and call them by name
app.formatOutput "niceFormat", niceFormat

app.sendBack.niceFormat 11, "hi!", ->
app.receive (req, res) ->
  res.niceFormat req.data, braces: "<>"

# [Learn more](formatterChain.doc.html)
# ## Builtin middlewares/formatters
# [Command parser](commandParser.doc.html)
app.use transit.commandParser()
# [Do not wait for response](doNotWaitForResponse.doc.html)
app.use transit.doNotWaitForResponse()
# [Echoes all messages](echo.html)
app.use transit.echo()
# [Converts html to txt](html2txt.html)
app.use transit.html2txt()
# Introduces sessions (TBD, see [example of usage](icq.doc.html#section-2) )
app.use transit.sessions()
# [Shows help on commands](autohelp.html)
app.use transit.autohelp()
# [Allows to compose a chain of formatters](formatterChain.doc.html)
app.use transit.chain()
# ## Examples
# 1. [for ICQ](icq.doc.html), but it requires real ICQ account to use.
# 2. [for command line client](commandLine.doc.html)