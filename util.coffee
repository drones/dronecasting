

exports.varintEncodeToOctets = varintEncodeToOctets = (octets, x) ->
  if x < 128
    octets.push x
  else
    while true
      octet = (x % 128)
      octet |= 128 if x >= 128
      octets.push octet
      if x < 128
        return
      x = Math.floor(x / 128)


exports.varintsEncode = varintsEncode = (ints) ->
  octets = []
  for x in ints
    varintEncodeToOctets octets, x
  new Buffer octets


exports.intervalSet = intervalSet = (ms, f) -> setInterval f, ms
exports.timeoutSet = timeoutSet = (ms, f) -> setTimeout f, ms

exports.joinBuffers = joinBuffers = (arr) ->
  size = 0
  for x in arr
    size += x.length
  result = new Buffer size
  pos = 0
  for x in arr
    x.copy result, pos
    pos += x.length
  result

