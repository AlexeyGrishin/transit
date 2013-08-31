# This renderer splits output data on several portions, each portion has less or equal characters than specified limit.
#
# It could be useful for ICQ clients which have limitations on message size.
#
# Data is splitted by lines, so there will be no break inside line.
#
# If there is line larger than limit the exception will be thrown
module.exports = (limit = 2000) ->
  (data, next) ->
    forEachPortion data, limit, (dataPart) ->
      next(dataPart)

forEachPortion = (text, maxPortionLength, forPortion) ->
  lines = text.split("\n")
  lengths = lines.map (l) -> l.length
  throw "Cannot split text - there are lines larger than specified limit" if Math.max.apply(null, lengths) > maxPortionLength
  buffer = []
  sum = 0
  CRLF = 1
  for length, index in lengths
    if sum + length > maxPortionLength
      forPortion buffer.join("\n")
      buffer = []
      sum = 0
    buffer.push lines[index]
    sum += length + CRLF
  forPortion buffer.join("\n") if buffer.length

