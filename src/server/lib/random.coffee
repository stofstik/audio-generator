random = {}

random.int = (min, max) ->
  min = Math.ceil min
  max = Math.floor max
  return Math.floor(Math.random() * (max - min + 1)) + min

random.dec = (min, max) ->
  min = Math.ceil min
  max = Math.floor max
  return 0.1 * (Math.floor(Math.random() * (max - min + 1)) + min)

random.hun = (min, max) ->
  min = Math.ceil min
  max = Math.floor max
  return 0.01 * (Math.floor(Math.random() * (max - min + 1)) + min)

module.exports = random
