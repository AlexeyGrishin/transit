fs = require('fs')
path = require('path')
child_process = require('child_process')

rmdir = (dir, cb) ->
  console.log "#{dir} removed"
  cb()

mkdir = (dir, cb) ->
  console.log "#{dir} created"
  cb()

copyFile = (path, newPath, cb) ->
  console.log "#{newPath} created"
  cb()

rmdir "build", ->
  child_process.exec "coffee --compile --output build src", ->
    copyFile "package.json", "build/package.json", ->
      copyFile "README.md", "build/README.md", ->
        console.log "done :)"