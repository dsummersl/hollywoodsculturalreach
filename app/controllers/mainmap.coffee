Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'

# responsible for controlling the main map.
class Mainmap extends Spine.Controller
  constructor: ->
    super
    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)=>
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#mainmap').node().appendChild(importNode)
      country = d3.select('#m-antarctica')
        .attr('fill','#ffffff')
    Appdata.bind('update',@measureUpdated)

  measureUpdated: =>
    @log "measure updated"
    ###
    for c in Country.all()
      svgId = c.getSVGIDs()
      #console.log "svg id = '#{id}'"
      if svgId
        for id in svgId
          #console.log "#{c.name} = '#{id}'"
          d3.select("#{id}")
            .attr('fill','#555555')
            #.attr('style','#555555')
            #.on 'mousedown',(d,i)=>
            #  console.log "mouse down on #{country.name}"
      else
        @log "No mapping for #{c.name} (#{c.key})."
    ###

module.exports = Mainmap
