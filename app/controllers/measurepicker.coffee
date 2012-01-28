Spine = require('spine')
Country = require 'models/country'
Overview = require 'models/overview'
Appdata = require 'models/appdata'
Options = require 'lib/options'

# the logic that controls which measures (hollywood %) should be shown on screen.
# Also intended to control the 'key' view (color of the answer key)
class Measurepicker extends Spine.Controller
  constructor: ->
    super
    Appdata.bind('update',@appupdate)
    @measures =
      percentcounthollywood: # the percent of # of movies that are hollywood movies
        compute: @computeHollyWood
        viz: @hollywoodviz
        desc: '% Hollywood Movies'
      percentmoneyhollywood: # the percent of box office $s that are from hollywood movies
        compute: @computeHollyWoodMoney
        viz: @hollywoodviz
        desc: 'none'
    $('#measurepicker').append("<select id='mp-measure'></select>")
    $('#measurepicker select').append("<option label='#{v.desc}'>#{k}</option>") for k,v of @measures
    @changeMeasure('percentcounthollywood')

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

module.exports = Measurepicker
