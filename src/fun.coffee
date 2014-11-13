type = require './type'
object = require './object'

class fun

  # PRIVATE

  matchAtom = (patternAtom) ->
    type = typeof patternAtom
    value = patternAtom

    return (valueAtom, bindings) ->
      return (typeof valueAtom == type && valueAtom == value) ||
        (typeof value == 'number' && isNaN(valueAtom) && isNaN(value))

  matchRegExp = (patternRegExp) ->
    return (value, bindings) ->
      return typeof value != undefined && typeof value == 'string' && patternRegExp.test(value)

  # not so sure about this one...
  matchFunction = (patternFunction) ->
    return (value, bindings) ->
      return value.constructor == patternFunction && bindings.push(value) > 0

  matchArray = (patternArray) ->
    patternLength = patternArray.length
    subMatches = patternArray.map (v) -> return buildMatch v

    return (valueArray, bindings) ->
      return patternLength == valueArray.length &&
        valueArray.every (value, i) ->
          return i in subMatches && subMatches[i](valueArray[i], bindings)

  matchObject = (patternObject) ->
    type = patternObject.constructor
    patternLength = 0

    subMatches = object.map patternObject, (value) ->
      ++patternLength
      return buildMatch value

    return (valueObject, bindings) ->
      valueLength = 0

      return valueObject.constructor == type &&
        object.every(valueObject, (value, key) ->
          ++valueLength
          return key in subMatches && subMatches[key](valueObject[key], bindings)
        ) &&
        valueLength == patternLength

  buildMatch = (pattern) ->
    if pattern && (pattern == fun.parameter || pattern.constructor.name == fun.parameter().constructor.name)
      return (value, bindings) -> return bindings.push(value) > 0

    else if pattern && pattern.constructor == fun.wildcard.constructor
      return -> true

    else if type.isAtom(pattern) return matchAtom pattern
    else if type.
