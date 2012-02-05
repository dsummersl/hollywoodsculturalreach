Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Options = require 'lib/options'
Mapkey = require "lib/mapkey"

# responsible for controlling the main map.
class Mainmap extends Spine.Controller
  constructor: ->
    super
    @previousSelection = null
    @maploaded = false
    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)=>
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#mainmap').node().appendChild(importNode)
      d3.select('#mainmap svg').attr('fill',Options.nodatacountries)
      for c in Country.all()
        svgIds = c.getSVGIDs()
        if svgIds
          for id in svgIds
            fn = (c) => => Appdata.set('country',c.key)
            d3.select(id).on('click', fn(c))
      @mapkey = new Mapkey('#m-key')
      @maploaded = true
      @measureUpdated({key:'measuredata', data: Appdata.get('measuredata')})
    Appdata.bind('update',@measureUpdated)

  measureUpdated: (r) =>
    return if !@maploaded
    if r.key == 'measuredata'
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
    if r.key == 'country'
      c = Country.findByAttribute('key',r.data)
      if @previousSelection?
        oldc = Country.findByAttribute('key',@previousSelection)
        $(id).attr('class','') for id in oldc.getSVGIDs()
      $(id).attr('class','mm-selected') for id in c.getSVGIDs()
      @previousSelection = r.data
    @mapkey.updateSelection(r)

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
