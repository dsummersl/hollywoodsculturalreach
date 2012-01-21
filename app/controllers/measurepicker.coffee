Spine = require('spine')
Country = require 'models/country'
Overview = require 'models/overview'
Appdata = require 'models/appdata'

# the logic that controls which measures (hollywood %) should be shown on screen.
# Also intended to control the 'key' view (color of the answer key)
class Measurepicker extends Spine.Controller
  constructor: ->
    super
    @computeHollyWood()
    
  computeHollyWood: =>
    data = {}
    year = null
    year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'all'
    data[c.key] = Overview.totalHollyWoodRatio(c.overviews(),year) for c in Country.all()
    #@log "US is here" for c in Country.all() when c.key == 'unitedstates'
    #@log "us overview datas: #{JSON.stringify(Country.findByAttribute('key','unitedstates').overviews().all())}"
    #@log "us would be: #{Overview.totalHollyWoodRatio(Country.findByAttribute('key','unitedstates').overviews(),year)}"
    #@log "got US data: #{JSON.stringify(data.unitedstates)}" if data.unitedstates
    Appdata.set('measure','totalHollyWoodRatio')
    Appdata.set('measuredata',data)
    Appdata.bind('update',@appupdate)

  appupdate: (r) =>
    @computeHollyWood() if r.key == 'years'


module.exports = Measurepicker
