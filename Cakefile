{exec} = require 'child_process'

task 'build', 'build all', ->
    exec "coffee -bc -o html/js/ scripts/coffee/", (err, sout, serr) ->
        if err
            console.log "#{err}"
            #console.log "Stdout: #{sout}"
            #console.log "Errout: #{serr}"
        else
            console.log "Build successful"
