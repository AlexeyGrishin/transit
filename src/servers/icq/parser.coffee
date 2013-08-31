module.exports =
  forEachPortion: (text, maxPortionLength, forPortion) ->
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