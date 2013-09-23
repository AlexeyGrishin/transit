module.exports = (func) ->
  asCallback = (okCb, errorCb) ->
    (err, data) -> if (err) then errorCb(err) else okCb(data)
  func.asCallback = asCallback func, func
  func.withoutError = (errCb) -> asCallback func, errCb
  func
