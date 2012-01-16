require('lib/setup')
Spine = require('spine')

class App extends Spine.Controller
  constructor: ->
    super
    d3.xml "img/World_map_-_low_resolution.svg", "image/svg+xml", (xml)->
      importNode = document.importNode(xml.documentElement, true)
      d3.select('#viz').node().appendChild(importNode)

      america = d3.select('#m-canada')
        .attr('fill','#555555')
        .on 'mousedown',(d,i)->
          console.log 'mouse down on america'
      america = d3.select('#m-antarctica')
        .attr('fill','#ffffff')

module.exports = App
    
