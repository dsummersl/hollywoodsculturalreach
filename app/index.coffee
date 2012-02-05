require('lib/setup')

Spine = require('spine')
Extractor = require('lib/extract')

Country = require 'models/country'
Movie = require 'models/movie'
Movieshowing = require 'models/movieshowing'
Overview = require 'models/overview'
Appdata = require 'models/appdata'

Datalimiter = require 'controllers/datalimiter'
Detailsection = require 'controllers/detailsection'
Mainmap = require 'controllers/mainmap'

class App extends Spine.Controller
  constructor: ->
    super
    @currentRMIs = 0
    $('#startuptext').text("Loading countries...")
    @loadIfZero(Country,'data/countries.csv',@loadcountries)

  # get variables passed to the application:
  getUrlVars: =>
    vars = {}
    hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')
    for el in hashes
      hash = el.split('=')
      vars[hash[0]] = hash[1]
    return vars

  #TODO I could just use Model.refresh(JSONofdata) to setup my models. That seems ideal-ish.
 
  loadIfZero: (datastore,file,loadmethod) =>
    #@currentRMIs++
    #datastore.bind('refresh',@datarefreshed)
    #datastore.fetch()
    #console.log "bound to #{datastore.className}"
    fn = (datastore,file,loadmethod) =>
      return =>
        #console.log "reload? #{@getUrlVars().reload != null}"
        #console.log "length? #{datastore.count()}"
        if file instanceof Array
          #console.log "its an array"
          @manyDatas = []
          for f in file
            d3.csv(f, @keepLoading) if @getUrlVars().reload != null or datastore.count() == 0
          fn = =>
            loadmethod(@manyDatas)
            @manyDatas = null
          @checkData((=> @manyDatas.length == file.length),1000,fn)
        else
          d3.csv(file, loadmethod) if @getUrlVars().reload != null or datastore.count() == 0
    @checkData(@rmiIsZero,1000,fn(datastore,file,loadmethod))

  keepLoading: (d) => @manyDatas.push(d)

  ###
  datarefreshed: =>
    @currentRMIs--
    console.log "fetched: #{@currentRMIs} RMIs left"
  ###

  rmiIsZero: => @currentRMIs == 0

  loadcountries: (d) =>
    #@log "reloading countries..."
    Country.deleteAll()
    exclude = ['israel','ecuador','indonesia','uae','bahrain'] # TODO need data for these.
    for k,v of d
      parts = v['Country|key'].split('|')
      Country.create(name: parts[0],region: v['Continent'],key: parts[1]) if parts[1] not in exclude
    Country.create(name: 'US & Canada',region: 'North America',key: 'unitedstates')
    $('#startuptext').text("Loading 2007 Hollywood movies...")
    Movie.deleteAll()
    Movieshowing.deleteAll()
    @loadIfZero(Movie,"data/2007.csv",@loadmovies(2007))

  loadmovies: (year) =>
    return (d) =>
      #console.log "loading movies"
      usa = Country.findByAttribute('key','unitedstates')
      mkmov = (d) =>
        genre = d.genre
        genre = 'Unknown' if genre == ''
        m = Movie.create({title: d.film, hollywood: true, year:d.year, story:d.story,genre:genre,distributor:d.distributor})
        money = d.domestic
        money = 0 if isNaN(money)
        ms = usa.showings().create({year:d.year, boxoffice:money, movie_id:m.id})
      Extractor.extractDomesticMovies(d,'unitedstates',year,mkmov)
      #console.log "Loaded #{year} Hollywood movies (count: #{Movie.count()})..."
      if year < 2011
        $('#startuptext').text("Loading #{year+1} Hollywood movies...")
        d3.csv("data/#{year+1}.csv", @loadmovies(year+1))
      else
        $('#startuptext').text("Loading summary data...")
        d3.csv("data/countryfiles.csv", @domesticmoviesloaded)

  domesticmoviesloaded:  =>
    @currentRMIs++
    $.getJSON "data/countrysummaries.json", (d) =>
      for c,yearData of d
        country = Country.findByAttribute('key',c)
        for summary in yearData
          country.overviews().create(summary)
      @currentRMIs--
      @log 'loaded all the summary data'
    @checkData(@rmiIsZero,1000,@dataloaded)

  dataloaded: =>
    $('#startupdialog').fadeOut()
    @log "Countries: #{Country.count()}"
    @log "Movies: #{Movie.count()}"
    @log "Movieshowing: #{Movieshowing.count()}"
    @log "Overviews: #{Overview.count()}"
    @mainmap = new Mainmap()
    @datalimiter = new Datalimiter()
    @detailsection = new Detailsection()
    @checkData( (=> @mainmap.maploaded),500,(=> Appdata.set('country','unitedstates')))

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
