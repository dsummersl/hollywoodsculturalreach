fs = require 'fs'
exec = require('child_process').exec

execHandler = (error,stdout,stderr) ->
  console.log stdout
  console.log stderr
  #console.log error if error != null

option '-y','--year [YEAR]', 'Year to build fetchdata with'

task 'fetchdata', 'Get all the data for countries from the website (use --year to specify year).', (options) ->
  if not options.year
    console.log "You need to specify the year: --year 2011"
    return
  console.log "running get_country_list"
  exec "sh bin/get_country_list.sh #{options.year}", execHandler

task 'makeJSON', 'Make all the existing data into JSON', ->
  exec 'mkdir public/data', execHandler
  console.log "building country data..."
  exec 'sh bin/convert_to_json.sh', execHandler
  # TODO verify that the data is actually good standing JSON

task 'makeSummaries', 'Make Overview data - you must run this like this:\n\nNODE_PATH="app" cake makeJSON', ->
  Spine = require 'spine'
  Spine.Model.Local = {}
  Spine.Model.Ajax = {}
  Extractor = require 'lib/extract'
  Movie = require 'models/movie'
  years = [2007..2011]

  console.log "building domestic data..."
  summaryData =
    unitedstates: []
  for year in years
    console.log "#{year}"
    l = (d) =>
      Movie.create({title: d.film?.replace(/"/g,''), hollywood: true, year:d.year, distributor: d.distributor, story:d.story?.replace(/"/g,''),genre:d.genre?.replace(/"/g,''),country:null})
      console.log "Made movie for '#{d.film}' #{d.year}"
    console.log " - going to parse JSON"
    yearlyData = JSON.parse(fs.readFileSync("public/data/#{year}.json"))
    console.log " - parsed JSON"
    results = Extractor.extractDomesticMovies(yearlyData,'unitedstates',year,l)
    summaryData.unitedstates.push(s) for s in results
    console.log " - extracted movies"

  console.log "\nbuilding INTERNATIONAL data..."
  countries = JSON.parse(fs.readFileSync('public/data/countries.json'))
  #countries = {"row0": {"Continent": "Africa","Country|key": ["Egypt","egypt"]}}
  for k,c of countries
    country = c['Country|key'][1]
    summaryData[country] = [] if country not in summaryData
    movieData = []
    console.log "#{country}"
    for year in years
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
        results = Extractor.extractCountrySummary(movies,Movie,country,year)
        summaryData[country].push(s) for s in results
        console.log "    - read summary data"
        movieData = movieData.concat Extractor.extractCountryMovies(movies,Movie,year)
        console.log "    - read movie data"
    fs.createWriteStream("public/data/#{country}.json").write(JSON.stringify(movieData))
  fs.createWriteStream('public/data/countrysummaries.json').write(JSON.stringify(summaryData))
  #console.log "Summary: #{JSON.stringify(summaryData)}"
