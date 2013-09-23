fs = require('fs')
path = require('path')
wrench = require('wrench')
child_process = require('child_process')

rmdir = (dir, cb) ->
  wrench.rmdirSyncRecursive dir
  console.log "#{dir} removed"
  cb()


copyFile = (path, newPath, cb) ->
  fs.writeFileSync(newPath, fs.readFileSync(path))
  console.log "#{newPath} created"
  cb()

rmdir "build", ->
  child_process.exec "coffee --compile --output build src", ->
    copyFile "package.json", "build/package.json", ->
      copyFile "README.md", "build/README.md", ->
        console.log "done :)"