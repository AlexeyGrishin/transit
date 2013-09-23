# This middleware registers new command ('help' by default) which shows the list of all
# possible commands.
_ = require('underscore')

module.exports = (options = {}) ->
# Middleware accepts following options:
  options = _.defaults(options, {
# * Greeting is shown before the list of commands.
    greeting: "Here are the commands you may use",
# * Help string for the help command :)
    helpString: "shows this help"
# * Name of command which will show the help.
    command: "help",
# * Pattern property with description
    property: "autohelp"
# * If true then help will be also shown on any unknown command.
    showOnUnknown: true}
  )
  install: (transit) ->
    handler = (req, res) ->
      toDescription = (h) ->
        descr = [h.pattern]
        if h.autohelp
          descr.push " - "
          descr.push h[options.property]
        descr.join ""
      help = [options.greeting + ": "].concat(req.handlers.map(toDescription).filter(_.identity)).join("\n * ")
      res.sendBack help
    transit.receive options.command, autohelp: options.helpString, handler
    transit.receive handler if options.showOnUnknown
