require('lib/setup')
Country = require('models/country')
Spine = require('spine')
Extractor = require('lib/extract')

class App extends Spine.Controller
  constructor: ->
    super
    $.getJSON("data/countries.json", @dataloaded)

  dataloaded: (d) =>
    Country.create(name: v['Country|key'][0],region: v['Continent'],key: v['Country|key'][1]) for k,v of d
    # plus the domestic market:
    Country.create(name: 'US & Canada',region: 'North America',key: 'unitedstates')

    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)=>
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#viz').node().appendChild(importNode)
      country = d3.select('#m-antarctica')
        .attr('fill','#ffffff')
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

module.exports = App
