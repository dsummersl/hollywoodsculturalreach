Spine = require('spine')
Appdata = require 'models/appdata'
Country = require 'models/country'
Movieshowing = require 'models/movieshowing'
Options = require 'lib/options'
Measures = require 'lib/measures'

# controls the filtering of the data (ie, only 2008 data).
class Datalimiter extends Spine.Controller

  constructor: ->
    super
    $('#datalimiter').append("""
    <a href="#" id="dl-change" class="btn" style="float: right;"><i class="icon-pencil"></i></a>
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


    # Movies from 2007-2011
    $("#dl-year").append("<option>#{y}</option>") for y in Options.years
    $("#dl-year").append("<option>All</option>")
    $("#dl-year").val('All')

    genres = []
    usa = Country.findByAttribute('key','unitedstates')
    #console.log "showings = #{ms.movie().genre}" for ms in usa.showings().all()
    genres.push(ms.movie().genre) for ms in usa.showings().all() when ms.movie().genre not in genres
    genres = genres.sort()
    #console.log "movie #{ms.movie().title} genre is #{ms.movie().genre}" for ms in usa.showings().all() when ms.movie().genre == ''
    $("#dl-genre").append("<option>#{g}</option>") for g in genres
    #$("#dl-genre").append("<option>Unknown</option>")
    $("#dl-genre").append("<option>All</option>")
    $("#dl-genre").val('All')

    $("#dl-measure").append("<option value='#{k}'>#{v.desc}</option>") for k,v of Measures
    console.log "initial measure = #{Options.initialmeasure}"
    #$("#dl-measure option[value='#{Options.initialmeasure}']").attr('selected','selected')
    $("#dl-measure").val(Options.initialmeasure)

    $("#dl-change").click => $('#dl-modifydialog').fadeIn()
    $("#dl-closemodifydialog").click => $('#dl-modifydialog').fadeOut()
    $("#dl-year").change(@yearchanged)
    $("#dl-genre").change(@genrechanged)
    $("#dl-measure").change(@measurechanged)

    
    @changeMeasure(Options.initialmeasure)
    @updateDescription()
  
  updateDescription: =>
    years = Appdata.get('years') if Appdata.get('years') != 'All'
    genres = Appdata.get('genres') if Appdata.get('genres') != 'All'
    str = "Hollywood movies from #{Options.years[0]} &mdash; #{Options.years[Options.years.length-1]}, #{Appdata.get('measure').extendeddesc}"
    if years? and genres?
      str = "Hollywood #{Appdata.get('genres')} movies in #{Appdata.get('years')}, #{Appdata.get('measure').extendeddesc}"
    if genres?
      str = "Hollywood #{Appdata.get('genres')} movies from #{Options.years[0]} &mdash; #{Options.years[Options.years.length-1]}, #{Appdata.get('measure').extendeddesc}"
    if years?
      str = "Hollywood movies in #{Appdata.get('years')}, #{Appdata.get('measure').extendeddesc}"
    #console.log "new string = '#{str}'"
    $('#dl-desc').html(str)

  yearchanged: (e) =>
    Appdata.set('years',$(e.target).val())
    @changeMeasure(Appdata.get('measureKey'))
    @updateDescription()
  genrechanged: (e) =>
    Appdata.set('genres',$(e.target).val())
    @changeMeasure(Appdata.get('measureKey'))
    @updateDescription()
  measurechanged: (e) =>
    @changeMeasure($(e.target).val())
    @updateDescription()

  changeMeasure: (m) =>
    Appdata.set('measure',Measures[m])
    Appdata.set('measureKey',m)
    Measures[m].compute()

module.exports = Datalimiter
