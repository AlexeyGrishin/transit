# This middleware registers new command ('help' by default) which shwos the list of all
# possible commands.
_ = require('underscore')

module.exports = (options = {}) ->
  options = _.defaults(options, {
# Greeting is shown before the list of commands
    greeting: "Here are the commands you may use",
# Name of command which will show the help
    command: "help",
# If true then help will be also shown on any unknown command
    showOnUnknown: true}
  )
  install: (transit) ->
    handler = (req, res) ->
      help = [options.greeting + ": "].concat(req.handlers.map((h) -> h.pattern).filter(_.identity)).join("\n - ")
      res.sendBack help
    transit.receive options.command, handler
    transit.receive handler if options.showOnUnknown
