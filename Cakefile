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

task 'makeJSON', 'Make all the existing data into JSON', ->
  exec 'mkdir public/data', execHandler
  console.log "building country data..."
  exec 'sh bin/convert_to_json.sh', execHandler
  # TODO verify that the data is actually good standing JSON

task 'makeSummaries', 'Make Overview data - you must run this like this:\n\nNODE_PATH="app" cake makeJSON', ->
  Extractor = require('lib/extract')
  Movie = require 'models/movie'
  Spine = require 'spine'
  Spine.Model.Ajax = {}
  console.log "building domestic data..."
  summaryData =
    unitedstates: {}
  for year in [2007..2011]
    console.log "#{year}"
    summaryData.unitedstates[year] =
      key: 'unitedstates'
      year: year
      otherfilms: 0
      hollywoodfilms: 0
      oldhollywoodfilms: 0
    l = (d) =>
      Movie.create({title: d.film?.replace('"',''), year:d.year, story:d.story?.replace('"',''),genre:d.genre?.replace('"',''),country:null})
      summaryData.unitedstates[year].hollywoodfilms++
      #console.log "Made movie for '#{d.film}' #{d.year}"
    console.log " - going to parse JSON"
    yearlyData = JSON.parse(fs.readFileSync("public/data/#{year}.json"))
    console.log " - parsed JSON"
    Extractor.extractDomesticMovies(yearlyData,'us',year,l)
    console.log " - extracted movies"
  console.log "\nbuilding INTERNATIONAL data..."
  countries = JSON.parse(fs.readFileSync('public/data/countries.json'))
  #countries = {"row0": {"Continent": "Africa","Country|key": ["Egypt","egypt"]}}
  for k,c of countries
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
  #console.log "Summary: #{JSON.stringify(summaryData)}"
