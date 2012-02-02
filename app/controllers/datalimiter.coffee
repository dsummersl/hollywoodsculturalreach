Spine = require('spine')
Appdata = require 'models/appdata'
Country = require 'models/country'
Movieshowing = require 'models/movieshowing'
Options = require 'lib/options'
Overview = require 'models/overview'

# controls the filtering of the data (ie, only 2008 data).
class Datalimiter extends Spine.Controller

  constructor: ->
    super
    $('#datalimiter').append("""
    <div id="dl-desc">... description ...</div>
    <div class="modal" id="dl-modifydialog" style="display: none;">
      <div class="modal-header"><h3>Map options</h3></div>
      <div class="modal-body">
        <p>Change <u>how much</u> information is displayed:</p>
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
          <div class="clearfix">
            <label for="xlInput">Color By:</label>
            <div class="input">
              <select id="dl-measure"></select>
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
        extendeddesc: 'The percentage of movies shown in a countries theatres that are from Hollywood.'
        colors: ['#bbd3f9','#f1ee9c']
      percentmoneyhollywood: # the percent of box office $s that are from hollywood movies
        compute: @computeHollyWoodMoney
        viz: @hollywoodviz
        desc: '% Revenue Hollywood Movies'
        extendeddesc: 'The percentage of revenue from movies shown in a countries theatres that are from Hollywood.'
        colors: ['#bbd3f9','#f1ee9c']

    # Movies from 2007-2011
    $("#dl-year").append("<option>#{y}</option>") for y in Options.years
    $("#dl-year").append("<option>All</option>")
    $("#dl-year").val('All')

    genres = []
    usa = Country.findByAttribute('key','unitedstates')
    #console.log "showings = #{ms.movie().genre}" for ms in usa.showings().all()
    genres.push(ms.movie().genre) for ms in usa.showings().all() when ms.movie().genre not in genres
    # TODO alphabetize
    $("#dl-genre").append("<option>#{g}</option>") for g in genres
    #$("#dl-genre").append("<option>Unknown</option>")
    $("#dl-genre").append("<option>All</option>")
    $("#dl-genre").val('All')

    $("#dl-measure").append("<option value='#{k}'>#{v.desc}</option>") for k,v of @measures

    @updateDescription()

    $("#dl-change").click => $('#dl-modifydialog').fadeIn()
    $("#dl-closemodifydialog").click => $('#dl-modifydialog').fadeOut()
    $("#dl-year").change(@yearchanged)
    $("#dl-genre").change(@genrechanged)
    $("#dl-measure").change(@measurechanged)

    @changeMeasure('percentcounthollywood')
  
  updateDescription: =>
    if Appdata.get('years')
      $('#dl-desc').html("<span id='dl-change'>Hollywood movies in #{Appdata.get('years')}, countries are colored by percent of Hollywood movies<span>")
    else # show all years
      $('#dl-desc').html("<span id='dl-change'>Hollywood movies from #{Options.years[0]} &mdash; #{Options.years[Options.years.length-1]}, countries are colored by percent of Hollywood movies<span>")

  yearchanged: (e) =>
    Appdata.set('years',$(e.target).val())
    @updateDescription()
  genrechanged: (e) =>
    Appdata.set('genres',$(e.target).val())
    @updateDescription()
  measurechanged: (e) =>
    @changeMeasure($(e.target).val())

  changeMeasure: (m) =>
    Appdata.set('measure',@measures[m])
    @measures[m].compute()
    @measures[m].viz()
    
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
    year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'All'
    genre = Appdata.get('genres') if Appdata.get('genres') and Appdata.get('genres') != 'All'
    data[c.key] = Overview.totalRevenueRatio(c,{year:year,genre:genre}) for c in Country.all()
    Appdata.set('measuredata',data)

  appupdate: (r) =>
    @computeHollyWood() if r.key == 'years'
    @computeHollyWood() if r.key == 'genres'
    
module.exports = Datalimiter
