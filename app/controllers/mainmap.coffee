Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Options = require 'lib/options'
Mapkey = require "lib/mapkey"

# responsible for controlling the main map.
class Mainmap extends Spine.Controller
  constructor: ->
    super
    @maploaded = false
    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)=>
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#mainmap').node().appendChild(importNode)
      d3.select('#mainmap svg').attr('fill',Options.nodatacountries)
      ###
      d3.select('#m-antarctica')
        .attr('fill','#ffffff')
      ###
      for c in Country.all()
        svgIds = c.getSVGIDs()
        if svgIds
          for id in svgIds
            fn = (c) => return =>
              key = c.key
              if Appdata.get('country')?
                oldc = Country.findByAttribute('key',Appdata.get('country'))
                $(id).attr('class','') for id in oldc.getSVGIDs()
              Appdata.set('country',key)
              $(id).attr('class','mm-selected') for id in c.getSVGIDs()
            d3.select(id).on('click', fn(c))
      @mapkey = new Mapkey('#m-key',20)
      @maploaded = true
      @measureUpdated({key:'measuredata', data: Appdata.get('measuredata')})
    Appdata.bind('update',@measureUpdated)

  measureUpdated: (r) =>
    if @maploaded and r.key == 'measuredata'
      max = r.data[@findMaxKey(r.data)]
      colors = d3.scale.linear().domain([0,max]).range(Appdata.get('measure').colors)
      @mapkey.refresh(r.data)
      for c in Country.all()
        svgIds = c.getSVGIDs()
        if r.data[c.key] and svgIds
          for id in svgIds
            d3.select(id)
              .transition()
              .duration(600)
              .attr('fill',colors(r.data[c.key]))
        else if svgIds
          for id in svgIds
            d3.select(id)
              .transition()
              .duration(600)
              .attr('fill',Options.disabledcountries)
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
