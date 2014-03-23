String::startswith = (ex) ->
    if @substr(0, ex.length) == ex
        return true
    false

String::istartswith = (ex) ->
    if @substr(0, ex.length).toLowerCase() == ex.toLowerCase()
        return true
    false

