# Removed surrounding whitespace
unless typeof String::trim is "function"
  String::trim = ->
    @replace /^\s+|\s+$/g, ''

# Returns true if a string starts with a given string, false otherwise
# "Hello World".startsWith "He" => true
unless typeof String::startsWith is "function"
  String::startsWith = (str) ->
    @slice(0, str.length) is str
