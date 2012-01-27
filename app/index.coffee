require('lib/setup')

Spine = require('spine')
Extractor = require('lib/extract')

Country = require 'models/country'
Movie = require 'models/movie'
Movieshowing = require 'models/movieshowing'

Datalimiter = require 'controllers/datalimiter'
Detailsection = require 'controllers/detailsection'
Mainmap = require 'controllers/mainmap'
Measurepicker = require 'controllers/measurepicker'

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
    @currentRMIs++
    datastore.bind('refresh',@datarefreshed)
    datastore.fetch()
    console.log "bound to #{datastore.className}"
    fn = (datastore,file,loadmethod) =>
      return =>
        console.log "reload? #{@getUrlVars().reload != null}"
        console.log "length? #{datastore.count()}"
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

  datarefreshed: =>
    @currentRMIs--
    console.log "fetched: #{@currentRMIs} RMIs left"

  rmiIsZero: => @currentRMIs == 0

  loadcountries: (d) =>
    @log "reloading countries..."
    Country.deleteAll()
    for k,v of d
      parts = v['Country|key'].split('|')
      Country.create(name: parts[0],region: v['Continent'],key: parts[1])
    Country.create(name: 'US & Canada',region: 'North America',key: 'unitedstates')
    console.log "Loaded movies?"
    @loadIfZero(Movie,"data/2007.csv",@loadmovies(2007))

  loadmovies: (year) =>
    return (d) =>
      console.log "loading movies"
      Movie.deleteAll()
      Movieshowing.deleteAll()
      usa = Country.findByAttribute('key','unitedstates')
      mkmov = (d) =>
        m = Movie.create({title: d.film, hollywood: true, year:d.year, story:d.story,genre:d.genre})
        ms = usa.showings().create({year:d.year, boxoffice:d.domestic, movie:m})
      Extractor.extractDomesticMovies(d,'unitedstates',year,mkmov)
      console.log "Loaded #{year} Hollywood movies (count: #{Movie.count()})..."
      $('#startuptext').text("Loaded Hollywood movies...")
      if year < 2011
        d3.csv("data/#{year+1}.csv", @loadmovies(year+1))
      else
        d3.csv("data/countryfiles.csv", @domesticmoviesloaded)

  domesticmoviesloaded: (d) => d3.csv(d[0].file,@loadforeignmovies(d,0))
  loadforeignmovies: (files,i) =>
    return (d) =>
      row = files[i]
      @log "row = #{row.file} #{i}"
      year = parseInt(row.file.match(/^.*(\d\d\d\d).csv/)[1])
      country = Country.findByAttribute('key',row.file.match(/^data\/(\w+)\/.*/)[1])
      movies = Extractor.extractCountryMovies(d,Movie,year)
      for m in movies
        if not m.exists
          m = Movie.create({title: m.title, hollywood: m.hollywood, year:m.year, story: '',genre: ''})
        else
          m = Movie.findByAttribute('title',m.title)
        ms = country.showings().create({year:year, boxoffice:m.money, movie:m})
      @log "read #{country.key} #{year} movies: #{movies.length} #{Movie.count()}"
      if i < files.length
        d3.csv(files[i+1].file,@loadforeignmovies(files,i+1))
      else
        @log "all done"
        @dataloaded()

  dataloaded: =>
    $('#startupdialog').fadeOut()
    @log "Countries: #{Country.all().length}"
    @log "Movies: #{Movie.all().length}"
    @log "Movieshowing: #{Movieshowing.all().length}"
    @mainmap = new Mainmap()
    @datalimiter = new Datalimiter()
    @measurepicker = new Measurepicker()
    #@detailsection = new Detailsection()

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
