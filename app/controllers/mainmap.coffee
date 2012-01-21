Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'

# responsible for controlling the main map.
class Mainmap extends Spine.Controller
  constructor: ->
    super
    @maploaded = false
    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)=>
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#mainmap').node().appendChild(importNode)
      d3.select('#mainmap svg').attr('fill','#999999')
      d3.select('#m-antarctica')
        .attr('fill','#ffffff')
        #.attr('style','#555555')
      @maploaded = true
      @measureUpdated({key:'measuredata', data: Appdata.get('measuredata')})
    Appdata.bind('update',@measureUpdated)

  measureUpdated: (r) =>
    if @maploaded and r.key == 'measuredata'
      #max = @findMaxKey(r.data)
      max = @findMaxKey(r.data)
      colors = d3.scale.linear().domain([0,r.data[max]]).range(['#0000aa','#dd0000'])
      for c in Country.all()
        svgId = c.getSVGIDs()
        if r.data[c.key] and svgId
          for id in svgId
            d3.select(id)
              .transition()
              .duration(600)
              .attr('fill',colors(r.data[c.key]))
        else if svgId
          for id in svgId
            d3.select(id)
              .transition()
              .duration(600)
              .attr('fill','#555555')
        else
          @log "No mapping for #{c.name} (#{c.key})."

  findMaxKey: (d) ->
    maxKey = null
    max = null
    for k,v of d
      maxKey = k if not max
      max = v if not max
      maxKey = k if max < v
      max = v if max < v
    return maxKey

  findMinKey: (d) ->
    minKey = null
    min = null
    for k,v of d
      minKey = k if not min
      min = v if not min
      minKey = k if min > v
      min = v if min > v
    return minKey

module.exports = Mainmap
