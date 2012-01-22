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
    d3.select(id)
      .attr('style','') # clear away any style that might have already been there
      .attr('fill','#000000')
      .attr('fill-opacity',0.0)
    d3.select('#mainmap svg')
      .append('svg:g')
      .attr('transform',"translate(#{$(id).attr('x')},#{$(id).attr('y')})")
      .attr('id','m-keyarea')
    d3.select('#m-keyarea')
      .append('svg:g')
      .attr('transform',"translate(10,10)")
      .attr('id','m-keygroup')
    # height/width of the histogram area
    @h = parseFloat($('#m-key').attr('height')) - 20
    @w = parseFloat($('#m-key').attr('width')) - 10
    d3.select('#m-keyarea')
      .append('svg:line')
      .attr('stroke','#000')
      .attr('x1', 10)
      .attr('y1', 10)
      .attr('x2', 10)
      .attr('y2', 10+@h)
    d3.select('#m-keyarea')
      .append('svg:line')
      .attr('stroke','#000')
      .attr('x1', 10)
      .attr('y1', 10+@h)
      .attr('x2', 10+@w)
      .attr('y2', 10+@h)
    d3.select('#m-keyarea')
      .append('svg:text')
      .attr('class','keytext')
      .attr('x', 10)
      .attr('dy', ".35em")
      .attr('fill', "black")
      .attr('text-anchor', "middle")
      .text("Countries")
    d3.select('#m-keyarea')
      .append('svg:text')
      .attr('class','keytext')
      .attr('x', 10+@w)
      .attr('y', 10+@h)
      .attr('dy', ".35em")
      .attr('dx', ".35em")
      .attr('fill', "black")
      .attr('text-anchor', "start")
      .text("% match") # TODO make it match the current match type.
 
  refresh: (data) ->
    sep = 1
    buckets = []
    buckets.push(0) for nothing in [1..@numBuckets]
    max = 0
    max = v for k,v of data when v > max
    colors = d3.scale.linear().domain([0,@numBuckets]).range(Options.colors)
    bucketX = d3.scale.linear().domain([0,max]).range([0,@numBuckets-1])
    nodatabucket = 0
    for c in Country.all()
      if data[c.key]
        buckets[parseInt(bucketX(data[c.key]))] += c.getSVGIDs().length
      else
        nodatabucket++
    bucketY = d3.scale.linear().domain([0,d3.max(buckets)]).range([0,@h])
    bucketYH = (d) => @h - bucketY(d)
    bucketWidth = parseInt(@w / @numBuckets)
    keyx = d3.scale.linear().domain([0,1]).range([0,@w])
    console.log "bucket width = #{bucketWidth} for total width = #{@w} max is #{max}"
    console.log "the buckets = #{JSON.stringify(buckets)}"
    groups = d3.select('#m-keygroup')
      .selectAll('rect')
      .data(buckets)
    groups.enter()
      .append('svg:rect')
      .attr('fill', (d,i) => colors(i))
      .attr('fill-opacity',1.0)
      .attr('x', (d,i)=> i*bucketWidth+sep)
      .attr('width', bucketWidth-2*sep)
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
      .attr('class','keytext')
      .attr('x', (d,i)=> i*bucketWidth+bucketWidth/2.0)
      .attr('fill', "white")
      .attr('text-anchor', "middle")
    groups
      .transition()
      .duration(600)
      .attr('y', (d) => bucketYH(d)+10)
      .text(String)

module.exports = Mapkey
