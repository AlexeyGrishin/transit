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
    renderersToProcess = renderers.slice().map normalize
    renderersToProcess.push (data) ->
      cb null, data
    sendFurther = (data, idx) ->
      renderer = renderersToProcess[idx]
      renderer data, options, ((data) -> sendFurther data, idx+1)
    sendFurther(data, 0)