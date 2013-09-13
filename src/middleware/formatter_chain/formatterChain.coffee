isRegular = (f) -> f.length >= 3
isWithoutOptions = (f) -> f.length == 2
isSimplified = (f) -> f.length <= 1

normalize = (r) ->
  if isWithoutOptions(r)
    (data, options, next) -> r(data, next)
  else if isSimplified(r)
    (data, options, next) -> next(r(data))
  else
    r

module.exports = (formatters...) ->
  (data, options, cb) ->
    return cb(new Error("Invalid usage of formatters chain - register it with 'formatOutput' instead of 'use'")) if data._isPrivate
    formattersToProcess = formatters.slice().map normalize
    formattersToProcess.push (data) ->
      cb null, data
    sendFurther = (data, idx) ->
      format = formattersToProcess[idx]
      format data, options, ((data) -> sendFurther data, idx+1)
    sendFurther(data, 0)

module.exports.wrapHtml = require('../format_wrap_html/formatWrapHtml')
module.exports.json = require('../format_json/formatJson')
module.exports.splitByPortions = require('../format_split_by_portions/formatSplitByPortions')