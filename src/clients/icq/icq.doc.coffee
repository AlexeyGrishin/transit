# ICQ client receives messages from other ICQ users and allows to respond them.
# This is the main scenario the **transit** was created for.
transit = require('../../transit')
app = transit()

# Here we create session object. Session object will be associated with icq contact who writes to us.
# Session object is available as ``req.session`` in the handler
class IcqSession
  constructor: (@userId) ->
    console.log "#{@userId} connected"
  getName: -> @name ? "Unknown user #{@userId}"
  setName: (@name) ->
  close: ->
    console.log "#{@userId} disconnected"

# Add icq client. Use icq number as login.
app.use transit.icq {login: "__ICQ_NUMBER__", password: "__PASSWORD__"}
# [Convert html to text](html2txt.html)
app.use transit.html2txt()
# [Parse commands](commandParser.doc.html)
app.use transit.commandParser()
# Use sessions storage (in memory)
app.use transit.sessions sessionClass: IcqSession
# When send something back [split by 500 characters](renderSplitByPortions.html) and [wrap each portion with html](renderWrapHtml.html)
app.use transit.render transit.render.splitByPortions(500), transit.render.wrapHtml()

# After start connect to your bot and type him messages like:
# ```
# > hello
#   Hello Unknown user 555
#
# > callme Big Boss
#   I'll remember that, Big
#
# > callme "Big Boss"
#   I'll remember that, Big Boss
#
# > hello
#   Hello Big Boss
#
# > bottles 2
#   I have 2 bottles of beer. Let's drink one!
#   I have 1 bottles of beer. Let's drink one!
# ```

app.receive 'hello', (req, res) ->
  res.render("Hello #{req.session.getName()}")

app.receive 'callme {name}', (req, res) ->
  req.session.setName(req.attrs.name)
  res.render "I'll remember that, #{req.attrs.name}"

app.receive 'bottles {count}', (req, res) ->
  res.render ([req.attrs.count..1].map (n) -> "I have #{n} bottles of beer. Let's drink one!").join("\n")

app.start()