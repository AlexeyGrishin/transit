fs = require('fs')
path = require('path')
child_process = require('child_process')

generateDoc = (file) ->
  child_process.exec "docco --layout classic -o docs -e .coffee \"#{file}\"", (err, stdout, stderr) ->
    console.log(stdout)
    console.error(err) if err
    console.error(stderr) if stderr

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

processFolder("src")