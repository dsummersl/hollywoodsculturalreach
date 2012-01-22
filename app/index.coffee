require('lib/setup')
Country = require('models/country')
Spine = require('spine')
Extractor = require('lib/extract')
Mainmap = require 'controllers/mainmap'
Datalimiter = require 'controllers/datalimiter'
Measurepicker = require 'controllers/measurepicker'
Detailsection = require 'controllers/detailsection'

class App extends Spine.Controller
  constructor: ->
    super
    $.getJSON("data/countries.json", @countriesloaded)
    @currentRMIs = 0

  countriesloaded: (d) =>
    Country.create(name: v['Country|key'][0],region: v['Continent'],key: v['Country|key'][1]) for k,v of d
    # plus the domestic market:
    Country.create(name: 'US & Canada',region: 'North America',key: 'unitedstates')
    usa = Country.findByAttribute('key','unitedstates')
    for year in [2007..2011]
      @currentRMIs++
      fn = (year) =>
        return (d) =>
          Extractor.extractDomesticMovies(d,'unitedstates',year,(d) => usa.movies().create({title: d.film, year:d.year, story:d.story,genre:d.genre}))
          @currentRMIs--
          #@log "loaded all the country data for #{year}"
      $.getJSON "data/#{year}.json", fn(year)
    @currentRMIs++
    $.getJSON "data/countrysummaries.json", (d) =>
      for c,yearData of d
        country = Country.findByAttribute('key',c)
        for k,v of yearData
          country.overviews().create({year: v.year, other:v.otherfilms,hollywood:v.hollywoodfilms,oldhollywood:v.oldhollywoodfilms})
      @currentRMIs--
      @log 'loaded all the summary data'
    @checkData(@rmiIsZero,1000,@dataloaded)


  rmiIsZero: => @currentRMIs == 0

  dataloaded: =>
    @mainmap = new Mainmap()
    @datalimiter = new Datalimiter()
    @measurepicker = new Measurepicker()
    @detailsection = new Detailsection()

  ###
  # Checks an array of data for existance called via function. when they all exist the
  # onExists function is called.
  # dataFunc = when it returns true then proceed.
  ###
  checkData: (dataFunc,interval,onExists) =>
    anyNull = false
    datum = dataFunc()
    if datum
      onExists()
    else
      recurse = => @checkData(dataFunc,interval,onExists)
      setTimeout(recurse, interval)

module.exports = App
