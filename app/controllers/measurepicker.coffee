Spine = require('spine')
Country = require 'models/country'
Overview = require 'models/overview'
Appdata = require 'models/appdata'

# the logic that controls which measures (hollywood %) should be shown on screen.
# Also intended to control the 'key' view (color of the answer key)
class Measurepicker extends Spine.Controller
  constructor: ->
    super
    data = {}
    data[c.key] = Overview.totalHollyWoodRatio(c.overviews()) for c in Country.all()
    Appdata.set('measure','totalHollyWoodRatio')
    Appdata.set('measuredata',data)
    
module.exports = Measurepicker
