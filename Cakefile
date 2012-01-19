fs = require 'fs'
exec = require('child_process').exec

execHandler = (error,stdout,stderr) ->
  console.log stdout
  console.log stderr
  #console.log error if error != null

option '-y','--year [YEAR]', 'Year to build fetchdata with'

task 'fetchdata', 'Get all the data for countries from the website (use --year to specify year).', (options) ->
  if not options.year
    console.log "You need to specify the year: --year=2011"
    return
  console.log "running get_country_list"
  exec "sh bin/get_country_list.sh #{options.year}", execHandler

task 'makeJSON', 'Make all the existing data into JSON for the spine app - you must run this like this:\n\nNODE_PATH="app" cake makeJSON', ->
  Extractor = require('lib/extract')
  Movie = require 'models/movie'
  Spine = require 'spine'
  Spine.Model.Ajax = {}
  exec 'mkdir public/data', execHandler
  console.log "building country data..."
  exec 'sh bin/convert_to_json.sh', execHandler
  # TODO verify that the data is actually good standing JSON
  console.log "building domestic data..."
  for year in [2007..2011]
    console.log "#{year}"
    l = (d) => Movie.create({title: d.film, year:d.year, story:d.story,genre:d.genre,country:null})
    console.log " - going to parse JSON"
    yearlyData = JSON.parse(fs.readFileSync("public/data/#{year}.json"))
    console.log " - parsed JSON"
    Extractor.extractDomesticMovies(yearlyData,'us',2007,l)
    console.log " - extracted movies"
  console.log "\nbuilding overview data..."
  countries = JSON.parse(fs.readFileSync('public/data/countries.json'))
  summaryData = {}
  #for k,c of countries
  for k,c of {"row": {'Country|key': [0,'china']}}
    country = c['Country|key'][1]
    summaryData[country] = {} if country not in summaryData
    console.log "#{country}"
    for year in [2007..2011]
      console.log "  #{year}"
      movieFile = null
      try
        console.log "    - try to parse JSON"
        movieFile = fs.readFileSync("public/data/#{country}/#{year}.json")
        console.log "    - read JSON"
      catch e
        #...
      if movieFile
        movies = JSON.parse(movieFile)
        console.log "    - parsed JSON"
        summaryData[country][year] = Extractor.extractCountrySummary(movies,Movie,country,year)
        console.log "    - read summary data"
  fs.createWriteStream('public/data/countrysummaries.json').write(JSON.stringify(summaryData))
