Options = require 'lib/options'
Country = require('models/country')
Appdata = require 'models/appdata'

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
      .attr('id','m-keygroup')
    d3.select('#mainmap svg')
      .append('svg:g')
      .attr('transform',"translate(#{$('#m-keyunderxaxis').attr('x')},#{$('#m-keyunderxaxis').attr('y')})")
      .attr('id','m-keygroupaxis')
    d3.select('#mainmap svg')
      .append('svg:g')
      .attr('transform',"translate(#{$('#m-nodataavailable').attr('x')},#{$('#m-nodataavailable').attr('y')})")
      .attr('id','m-keynodataavail')
    @h = parseFloat($(id).attr('height'))
    @w = parseFloat($(id).attr('width'))
    d3.select('#m-nodataatall')
      .attr('style',Options.nodatacountries)
      .attr('rx', 2)
    d3.select('#m-nodataavailable')
      .attr('style','') # clear away any style that might have already been there
      .attr('fill','#000000')
      .attr('fill-opacity',0.0)
    d3.select('#m-keyunderxaxis')
      .attr('style','') # clear away any style that might have already been there
      .attr('fill','#000000')
      .attr('fill-opacity',0.0)
    d3.select('#m-yaxislabel')
      .text('# Countries')
    @sep = 1
    @bucketWidth = parseInt(@w / @numBuckets)
    colors = d3.scale.linear().domain([0,@numBuckets]).range(Options.colors)
    groups = d3.select('#m-keynodataavail')
      .selectAll('rect')
      .data([0])
      .enter()
      .append('svg:rect')
      .attr('fill', Options.disabledcountries)
      .attr('fill-opacity',0.9)
      .attr('x',0)
      .attr('width', @bucketWidth-2*@sep)
    ### don't like the look of this:
    groups = d3.select('#m-keynodataavail')
      .selectAll('text')
      .data([0])
      .enter()
      .append('svg:text')
      .attr('class','keytext')
      .attr('x', (d,i)=> @bucketWidth/2.0)
      .attr('fill', "white")
      .attr('text-anchor', "middle")
    ###
    groups = d3.select('#m-keygroup')
      .selectAll('rect')
      .data(0 for i in [1..@numBuckets])
      .enter()
      .append('svg:rect')
      .attr('fill', (d,i) => colors(i))
      .attr('fill-opacity',1.0)
      .attr('x', (d,i)=> i*@bucketWidth+@sep)
      .attr('width', @bucketWidth-2*@sep)
    ###
    groups = d3.select('#m-keygroup')
      .selectAll('text')
      .data(0 for i in [1..@numBuckets])
      .enter()
      .append('svg:text')
      .attr('class','keytext')
      .attr('x', (d,i)=> i*@bucketWidth+@bucketWidth/2.0)
      .attr('fill', "white")
      .attr('text-anchor', "middle")
    ###
    groups = d3.select('#m-keygroupaxis')
      .selectAll('text')
      .data(0 for i in [1..@numBuckets])
      .enter()
      .append('svg:text')
      .attr('class','keyxaxistext')
      .attr('x', (d,i)=> i*@bucketWidth+@bucketWidth/2.0-3)
      .attr('y', 5)
      .attr('fill', "black")
      .attr('transform', (d,i)=> "rotate(90 #{i*@bucketWidth+@bucketWidth/2.0-3} 5)")
      .attr('text-anchor', "start")
      .text((d,i)=> "#{parseInt((i+1)/@numBuckets*100)}%")
 
  refresh: (data) ->
    buckets = []
    buckets.push(0) for nothing in [1..@numBuckets]
    max = 0
    max = v for k,v of data when v > max
    bucketX = d3.scale.linear().domain([0,max]).range([0,@numBuckets-1])
    nodatabucket = 0
    for c in Country.all()
      if data[c.key]
        buckets[parseInt(bucketX(data[c.key]))] += c.getSVGIDs().length
      else
        nodatabucket++
    bucketY = d3.scale.linear().domain([0,d3.max(buckets)]).range([0,@h])
    bucketYH = (d) => @h - bucketY(d)
    keyx = d3.scale.linear().domain([0,1]).range([0,@w])
    #console.log "bucket width = #{@bucketWidth} for total width = #{@w} max is #{max}"
    #console.log "the buckets = #{JSON.stringify(buckets)}"
    # TODO improve this transition by putting all the 'enter' stuff into my constuctor (like I did for the 'data unavailable' section).
    # TODO put the percent numbers underneath the key
    groups = d3.select('#m-keygroup')
      .selectAll('rect')
      .data(buckets)
      .transition()
      .duration(600)
      .attr('y', bucketYH)
      .attr('height', bucketY)
    ###
    groups = d3.select('#m-keygroup')
      .selectAll('text')
      .data(buckets)
      .transition()
      .duration(600)
      .attr('y', (d) => bucketYH(d)+10)
      .text(String)
    ###
    groups = d3.select('#m-keynodataavail')
      .selectAll('rect')
      .data([0])
      .transition()
      .duration(600)
      .attr('y', bucketYH(nodatabucket))
      .attr('height', bucketY(nodatabucket))
    ###
    groups = d3.select('#m-keynodataavail')
      .selectAll('text')
      .data([0])
      .transition()
      .duration(600)
      .attr('y', bucketYH(nodatabucket)+10)
      .text(nodatabucket)
    ###
    d3.select('#m-xaxislabel')
      .text(Appdata.get('measureDesc'))
    groups = d3.select('#m-keygroupaxis')
      .selectAll('text')
      .data(buckets)
      .transition()
      .duration(600)
      # TODO text transition?
      .attr('class', (d)=>
        return "keyxaxistext" if d > 0
        return "keytext-invisible"
      )

module.exports = Mapkey
