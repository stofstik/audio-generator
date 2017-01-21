random     = require("random-js")()

randHelper = {}

randHelper.round = (num, precision) ->
  return Math.round(num * 100 + Number.EPSILON) / 100

randHelper.real = (min, max, inclusive, precision) ->
  if(!precision)
    return random.real(min, max, inclusive)
  return this.round( random.real(min, max, inclusive), precision )

module.exports = randHelper
