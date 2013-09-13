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
app.use transit.icq {login: "675819279", password: "chubaka1"}
# [Convert html to text](html2txt.html)
app.use transit.html2txt()
# [Parse commands](commandParser.doc.html)
app.use transit.commandParser()
# Use sessions storage (in memory)
app.use transit.sessions sessionClass: IcqSession
# When send something back [split by 500 characters](renderSplitByPortions.html) and [wrap each portion with html](renderWrapHtml.html)
app.renderer transit.chain transit.chain.splitByPortions(500), transit.chain.wrapHtml()
# [Show help](autohelp.html) if user made a mistake or types __help__ command.
app.use transit.autohelp()

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
  res.sendBack("Hello #{req.session.getName()}")

app.receive 'callme {name}', (req, res) ->
  req.session.setName(req.attrs.name)
  res.sendBack "I'll remember that, #{req.attrs.name}"

app.receive 'bottles {count}', (req, res) ->
  res.sendBack ([req.attrs.count..1].map (n) -> "I have #{n} bottles of beer. Let's drink one!").join("\n")

app.start()