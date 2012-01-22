Options = require 'lib/options'
Country = require('models/country')

# A histogram based map - each value is stored in a bucket, and you provide some coloring information.
class Mapkey
  constructor: (id,numBuckets) ->
    # what kind of data am I using on the map key?
    # Along the X axis I should the percent of the data (% hollywood movies)
    # Along the Y axis I show the country count.
    # So the data should be equal to the number of buckets I want for the
    # percentages
    @numBuckets = numBuckets
    @h = parseFloat($('#m-key').attr('height'))
    @w = parseFloat($('#m-key').attr('width'))
    d3.select(id)
      .attr('style','') # clear away any style that might have already been there
      .attr('fill','#000000')
      .attr('fill-opacity',0.0)
    d3.select('#mainmap svg')
      .append('svg:g')
      .attr('transform',"translate(#{$(id).attr('x')},#{$(id).attr('y')})")
      .attr('id','m-keygroup')
 
  refresh: (data) ->
    buckets = []
    buckets.push(0) for nothing in [1..@numBuckets]
    max = 0
    max = v for k,v of data when v > max
    colors = d3.scale.linear().domain([0,max]).range(Options.colors)
    bucketX = d3.scale.linear().domain([0,max]).range([0,@numBuckets-1])
    buckets[parseInt(bucketX(v))] += Country.findByAttribute('key',k).getSVGIDs().length for k,v of data
    bucketY = d3.scale.linear().domain([0,d3.max(buckets)]).range([0,@h])
    bucketYH = (d) => @h - bucketY(d)
    bucketWidth = parseInt(@w / @numBuckets)
    keyx = d3.scale.linear().domain([0,1]).range([0,@w])
    #console.log "bucket width = #{bucketWidth} for total width = #{@w} max is #{max}"
    #console.log "the buckets = #{JSON.stringify(buckets)}"
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

module.exports = Mapkey
