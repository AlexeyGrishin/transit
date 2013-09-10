#TODO: хотелось бы иметь озможность указывать опции, типа res.render bug, "bug.ejs"
#TODO: при вызове transit.sendBack renderer не будет вызван

module.exports = (renderers...) ->
  renderers = renderers.map (r) ->
    if r.length < 2
      (data, next) ->
        next(r(data))
    else
      r

  newRenderer: (transit) ->
    transit.renderer "render", (data, options, cb) ->
      renderersToProcess = renderers.slice()
      renderersToProcess.push (data) ->
        cb null, data
      sendFurther = (data, idx) ->
        renderer = renderersToProcess[idx]
        renderer data, ((data) -> sendFurther data, idx+1)
      sendFurther(data, 0)
    null

  install: (transit) ->
    transit.extendResponse "render"
    (req, res, next) ->
      res.attr "render", (data) ->
        renderersToProcess = renderers.slice()
        renderersToProcess.push (data) ->
          res.sendBack data
        sendFurther = (data, idx) ->
          renderer = renderersToProcess[idx]
          renderer data, ((data) -> sendFurther data, idx+1)
        sendFurther(data, 0)
      next()

module.exports.wrapHtml = require('../render_wrap_html/renderWrapHtml')
module.exports.json = require('../render_json/renderJson')
module.exports.splitByPortions = require('../render_split_by_portions/renderSplitByPortions')