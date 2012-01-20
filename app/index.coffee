require('lib/setup')
Country = require('models/country')
Spine = require('spine')
Extractor = require('lib/extract')

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
          @log "loaded all the country data for #{year}"
      $.getJSON "data/#{year}.json", fn(year)
    @currentRMIs++
    $.getJSON "data/countrysummaries.json", (d) =>
      for c,year of d
        country = Country.findByAttribute('key',c)
        for k,v of year
          country.overviews().create({year: year, other:v.otherfilms,hollywood:v.hollywoodfilms,oldhollywood:v.oldhollywoodfilms})
      @currentRMIs--
      @log 'loaded all the summary data'
    @checkData(@rmiIsZero,1000,@dataloaded)


  rmiIsZero: => @currentRMIs == 0

  dataloaded: =>
    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)=>
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#viz').node().appendChild(importNode)
      country = d3.select('#m-antarctica')
        .attr('fill','#ffffff')
      for c in Country.all()
        svgId = c.getSVGIDs()
        #console.log "svg id = '#{id}'"
        if svgId
          for id in svgId
            #console.log "#{c.name} = '#{id}'"
            d3.select("#{id}")
              .attr('fill','#555555')
              #.attr('style','#555555')
              #.on 'mousedown',(d,i)=>
              #  console.log "mouse down on #{country.name}"
        else
          @log "No mapping for #{c.name} (#{c.key})."

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
