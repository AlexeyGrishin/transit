fs = require('fs')
path = require('path')
child_process = require('child_process')

SRC = "src"
OUTPUT = "docs"
RENAME =
  'transit.doc.html': 'index.html'

post = ->
counter = 0
postProcess = (code) ->
  if typeof code == 'function'
    post = code
  else if typeof code == 'number'
    counter += code
    if counter == 0
      post()


generateDoc = (file) ->
  postProcess +1
  child_process.exec "docco --layout classic -o #{OUTPUT} -e .coffee \"#{file}\"", (err, stdout, stderr) ->
    console.log(stdout)
    console.error(err) if err
    console.error(stderr) if stderr
    postProcess -1

processFolder = (folder) ->
  for file in fs.readdirSync(folder)
    continue if ['.','..'].indexOf(file) == 0
    newPath = path.join(folder, file)
    stat = fs.statSync(newPath)
    if stat.isDirectory()
      processFolder(newPath)
    else if stat.isFile()
      if fs.readFileSync(newPath, "utf-8").indexOf("#") == 0
        generateDoc(newPath)

processFolder(SRC)
postProcess ->
  for file, newName of RENAME
    fs.renameSync path.join(OUTPUT, file), path.join(OUTPUT, newName)