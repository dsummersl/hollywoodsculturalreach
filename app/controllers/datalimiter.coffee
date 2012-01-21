Spine = require('spine')

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
    $("#dl-year").append("<option>#{y}</option>") for y in [2007..2011]
    $("#dl-year").change(@yearchanged)
    $("#dl-genre").change(@genrechanged)
    $("#dl-story").change(@storychanged)
  
  yearchanged: (e) => @log 'new year'
  genrechanged: (e) => @log "new genre"
  storychanged: (e) => @log "new story"
    
module.exports = Datalimiter
