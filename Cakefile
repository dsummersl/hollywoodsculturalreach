fs = require 'fs'
exec = require('child_process').exec

execHandler = (error,stdout,stderr) ->
  console.log stdout
  console.log stderr
  #console.log error if error != null

task 'fetchdata', 'Get all the data for countries from the website (use --year to specify year).', (options) ->
  if not options.year
    console.log "You need to specify the year: --year=2011"
    return
  exec "python get_country_list.sh #{options.year}", execHandler

task 'makeJSON', 'Make all the existing data into JSON for the spine app', ->
  exec 'mkdir public/data', execHandler
  console.log "building country data..."
  exec 'sh bin/convert_to_json.sh', execHandler
