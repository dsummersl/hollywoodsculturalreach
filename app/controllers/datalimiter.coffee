Spine = require('spine')
Appdata = require 'models/appdata'
Country = require 'models/country'
Movieshowing = require 'models/movieshowing'
Options = require 'lib/options'
Overview = require 'models/overview'

# controls the filtering of the data (ie, only 2008 data).
class Datalimiter extends Spine.Controller
  # events: doesn't appear to work for the not-yet living"
  #events:
  #  "change #dl-year": "@yearchanged"

  constructor: ->
    super
    $('#datalimiter').append("""
    <div id="dl-desc">... description ...</div>
    <div id="dl-change">change</div>
    <div class="modal" id="dl-modifydialog" style="display: none;">
      <div class="modal-header"><h3>Map options</h3></div>
      <div class="modal-body">
        <p>Change what information is displayed on the map:</p>
        <form>
          <div class="clearfix">
            <label for="xlInput">Year:</label>
            <div class="input">
              <select id="dl-year"></select>
            </div>
          </div>
          <div class="clearfix">
            <label for="xlInput">Genre:</label>
            <div class="input">
              <select id="dl-genre"></select>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <a href="#" id="dl-closemodifydialog" class="btn large primary">Close</a>
      </div>
    </div>
    <hr/>
    """)

    @measures =
      percentcounthollywood: # the percent of # of movies that are hollywood movies
        compute: @computeHollyWood
        viz: @hollywoodviz
        desc: '% Hollywood Movies'
      percentmoneyhollywood: # the percent of box office $s that are from hollywood movies
        compute: @computeHollyWoodMoney
        viz: @hollywoodviz
        desc: 'none'
    @changeMeasure('percentcounthollywood')

    # Movies from 2007-2011
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

    @updateDescription()

    $("#dl-change").click => $('#dl-modifydialog').fadeIn()
    $("#dl-closemodifydialog").click => $('#dl-modifydialog').fadeOut()

    $("#dl-year").change(@yearchanged)
    $("#dl-genre").change(@genrechanged)
  
  updateDescription: =>
    if Appdata.get('years')
      $('#dl-desc').html("Hollywood movies from #{Appdata.get('years')}, each country colored by percent of Hollywood movies")
    else # show all years
      $('#dl-desc').html("Hollywood movies from #{Options.years[0]} &mdash; #{Options.years[Options.years.length-1]}, each country colored by percent of Hollywood movies")

  yearchanged: (e) => Appdata.set('years',$(e.target).val())
  genrechanged: (e) => Appdata.set('genres',$(e.target).val())

  changeMeasure: (m) =>
    @measures[m].compute()
    @measures[m].viz()
    Appdata.set('measureDesc',@measures[m].desc)
    Appdata.set('measure',m)
    
  hollywoodviz: => # block.
  computeHollyWood: =>
    data = {}
    year = null
    year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'all'
    genre = Appdata.get('genres') if Appdata.get('genres') and Appdata.get('genres') != 'All'
    @log "filtering by #{year} and #{genre}"
    data[c.key] = Overview.totalHollyWoodRatio(c,{year:year,genre:genre}) for c in Country.all()
    #@log "DATA = #{JSON.stringify(data)}"
    Appdata.set('measuredata',data)

  computeHollyWoodMoney: =>
    data = {}
    year = null
    year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'all'
    data[c.key] = Overview.totalHollyWoodRatio(c,{year:year}) for c in Country.all()
    Appdata.set('measuredata',data)

  appupdate: (r) =>
    @computeHollyWood() if r.key == 'years'
    @computeHollyWood() if r.key == 'genres'
    
module.exports = Datalimiter
