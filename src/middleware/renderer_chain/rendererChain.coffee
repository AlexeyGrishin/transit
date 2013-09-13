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

module.exports = (renderers...) ->
  (data, options, cb) ->
    return cb(new Error("Invalid usage of rendering chain - register it with 'renderer' instead of 'use'")) if data._isPrivate
    renderersToProcess = renderers.slice().map normalize
    renderersToProcess.push (data) ->
      cb null, data
    sendFurther = (data, idx) ->
      renderer = renderersToProcess[idx]
      renderer data, options, ((data) -> sendFurther data, idx+1)
    sendFurther(data, 0)

module.exports.wrapHtml = require('../render_wrap_html/renderWrapHtml')
module.exports.json = require('../render_json/renderJson')
module.exports.splitByPortions = require('../render_split_by_portions/renderSplitByPortions')