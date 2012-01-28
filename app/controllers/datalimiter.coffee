Spine = require('spine')
Appdata = require 'models/appdata'
Country = require 'models/country'
Movieshowing = require 'models/movieshowing'
Options = require 'lib/options'

# controls the filtering of the data (ie, only 2008 data).
class Datalimiter extends Spine.Controller
  # events: doesn't appear to work for the not-yet living"
  #events:
  #  "change #dl-year": "@yearchanged"

  constructor: ->
    super
    @log "datalimiter"
    $('#datalimiter').append("""
    <select id="dl-year"></select>
    <select id="dl-genre"></select>
    <select id="dl-story"></select>
    """)
    $("#dl-year").append("<option>#{y}</option>") for y in Options.years
    $("#dl-year").append("<option>all</option>")
    $("#dl-year").val('all')

    genres = []
    usa = Country.findByAttribute('key','unitedstates')
    #console.log "showings = #{ms.movie().genre}" for ms in usa.showings().all()
    genres.push(ms.movie().genre) for ms in usa.showings().all() when ms.movie().genre not in genres
    # TODO alphabetize
    $("#dl-genre").append("<option>#{g}</option>") for g in genres
    #$("#dl-genre").append("<option>Unknown</option>")
    $("#dl-genre").append("<option>All</option>")
    $("#dl-genre").val('All')

    $("#dl-year").change(@yearchanged)
    $("#dl-genre").change(@genrechanged)
    $("#dl-story").change(@storychanged)
  
  yearchanged: (e) => Appdata.set('years',$(e.target).val())
  genrechanged: (e) => Appdata.set('genres',$(e.target).val())

  storychanged: (e) => @log "new story"
    
module.exports = Datalimiter
