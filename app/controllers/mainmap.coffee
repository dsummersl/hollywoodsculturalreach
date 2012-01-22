Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Options = require 'lib/options'

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
      d3.select('#m-key')
        .attr('style','') # clear away any style that might have already been there
        .attr('fill','#000000')
        .attr('fill-opacity',0.5)
      d3.select('#mainmap svg')
        .append('svg:g')
        .attr('transform',"translate(#{$('#m-key').attr('x')},#{$('#m-key').attr('y')})")
        .attr('id','m-keygroup')
      @maploaded = true
      @measureUpdated({key:'measuredata', data: Appdata.get('measuredata')})
    Appdata.bind('update',@measureUpdated)

  measureUpdated: (r) =>
    if @maploaded and r.key == 'measuredata'
      max = r.data[@findMaxKey(r.data)]
      h = parseFloat($('#m-key').attr('height'))
      w = parseFloat($('#m-key').attr('width'))
      colors = d3.scale.linear().domain([0,max]).range(Options.colors)
      # what kind of data am I using on the map key?
      # Along the X axis I should the percent of the data (% hollywood movies)
      # Along the Y axis I show the country count.
      # So the data should be equal to the number of buckets I want for the
      # percentages
      numBuckets = 10
      bucketX = d3.scale.linear().domain([0,max]).range([0,numBuckets-1])
      buckets = []
      buckets.push(0) for nothing in [1..10]
      for c in Country.all()
        svgIds = c.getSVGIDs()
        if r.data[c.key] and svgIds
          #@log "bucket of #{r.data[c.key]} is #{bucketX(r.data[c.key])}"
          buckets[parseInt(bucketX(r.data[c.key]))] += svgIds.length
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
              .attr('fill','#555555')
        else
          @log "No mapping for #{c.name} (#{c.key})."
      bucketY = d3.scale.linear().domain([0,d3.max(buckets)]).range([0,h])
      bucketYH = (d) => h - bucketY(d)
      bucketWidth = parseInt(w / numBuckets)
      keyx = d3.scale.linear().domain([0,1]).range([0,w])
      @log "bucket width = #{bucketWidth} for total width = #{w}"
      @log "the buckets = #{JSON.stringify(buckets)}"
      groups = d3.select('#m-keygroup')
        .selectAll('rect')
        .data(buckets)
      groups.enter()
        .append('svg:rect')
        .attr('fill', (d,i) => colors(max*(i+1)/10.0))
        .attr('fill-opacity',1.0)
        .attr('x', (d,i)=> i*bucketWidth)
        .attr('width', bucketWidth)
      groups
        .transition()
        .duration(600)
        .attr('y', bucketYH)
        .attr('height', bucketY)
      groups = d3.select('#m-keygroup')
        .selectAll('text')
        .data(buckets)
      groups.enter()
        .append('svg:text')
        .attr('x', (d,i)=> i*bucketWidth+bucketWidth/2.0-8)
        .attr('dy', ".35em")
      groups
        .transition()
        .duration(600)
        .attr('y', (d) => bucketYH(d)+10)
        .text(String)

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
