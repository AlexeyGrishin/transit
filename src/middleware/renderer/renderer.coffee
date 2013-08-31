
module.exports = (renderers...) ->
  install: (transit) ->
    transit.extendResponse "render"
    (req, res, next) ->
      res.attr "render", (data) ->
        renderersToProcess = renderers.slice()
        renderersToProcess.push (data) ->
          res.sendBack data
        sendFurther = (data, idx) ->
          renderer = renderersToProcess[idx]
          renderer data, (data) ->
            sendFurther data, idx+1
        sendFurther(data, 0)
      next()

module.exports.wrapHtml = require('../render_wrap_html/renderWrapHtml')
module.exports.json = require('../render_json/renderJson')
module.exports.splitByPortions = require('../render_split_by_portions/renderSplitByPortions')