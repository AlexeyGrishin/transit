module.exports = (before = "<font face='courier'>", after = "</font>") ->
  (data, next) ->
    next(before + data + after)


