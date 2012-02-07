Options = require 'lib/options'
Country = require('models/country')
Appdata = require 'models/appdata'

# A histogram based map - each value is stored in a bucket, and you provide some coloring information.
class Mapkey
  constructor: (id) ->
    # what kind of data am I using on the map key?
    # Along the X axis I should the percent of the data (% hollywood movies)
    # Along the Y axis I show the country count.
    # So the data should be equal to the number of buckets I want for the
    # percentages
    @numBuckets = Country.count()
    @previousSelection = null
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
    @h = parseFloat($(id).attr('height'))
    @w = parseFloat($(id).attr('width'))
    d3.select('#m-xaxis').style('stroke',Options.disabledcountries)
    d3.select('#m-xaxis').style('visibility','hidden')
    d3.select('#m-yaxis').style('stroke',Options.disabledcountries)
    d3.select('#m-origin').attr('fill',Options.disabledcountries)
    d3.selectAll('#m-nodataatalltext tspan').attr('fill',Options.disabledcountries)
    d3.selectAll('#m-dataunavailable tspan').attr('fill',Options.disabledcountries)
    d3.select('#m-nodataatall')
      .attr('style',Options.nodatacountries)
      .attr('rx', 2)
    d3.select('#m-keyunderxaxis')
      .attr('style','') # clear away any style that might have already been there
      .attr('fill',Options.disabledcountries)
      .attr('fill-opacity',0.0)
    d3.select('#m-xaxislabel')
      .text('Countries')
      .attr('fill',Options.disabledcountries)
    @sep = 1
    @bucketWidth = parseInt(@w / @numBuckets)
    colors = d3.scale.linear().domain([0,@numBuckets]).range(Appdata.get('measure').colors)
    groups = d3.select('#m-keygroup')
      .selectAll('rect')
      .data(0 for i in [1..@numBuckets])
      .enter()
      .append('svg:rect')
      .attr('fill', (d,i) => colors(i))
      .attr('fill-opacity',1.0)
      .attr('x', (d,i)=> i*@bucketWidth+@sep)
      .attr('width', @bucketWidth-2*@sep)
      .on('click', (d) => Appdata.set('country',d))
    popupfn = ->
      key = $(@).attr('movie-key')
      md = Appdata.get('measuredata')
      me = Appdata.get('measure')
      return """
      <ul class="unstyled">
        <li>#{me.desc}: <span class="ds-rightside">#{me.formatData(md[key])}</span></li>
      </ul>
      """
    $('#m-keygroup rect').popover({placement: 'top', content: popupfn})
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
    groups = d3.select('#m-keygroupaxis')
      .selectAll('text')
      .data(0 for i in [1..@numBuckets])
      .enter()
      .append('svg:text')
      .attr('class','keyxaxistext')
      .attr('x', (d,i)=> i*@bucketWidth+@bucketWidth/2.0-3)
      .attr('y', 5)
      .attr('fill',Options.disabledcountries)
      .attr('transform', (d,i)=> "rotate(90 #{i*@bucketWidth+@bucketWidth/2.0-3} 5)")
      .attr('text-anchor', "start")
      .text((d,i)=> "#{parseInt((i+1)/@numBuckets*100)}%")
    ###

  refresh: (data) ->
    $(".mk-selected").attr('class','') if @previousSelection?
    buckets = []
    buckets.push(0) for nothing in [1..@numBuckets]
    min = 0
    min = v for k,v of data when v < min
    max = 0
    max = v for k,v of data when v > max
    colors = Appdata.get('measure').colors(data)
    nodatabucket = 0
    buckets[i] = c.key for c,i in Country.all()
    buckets = buckets.sort((a,b)=> data[a] - data[b])
    heightRange = d3.scale.linear().domain([0,Math.max(Math.abs(min),max)]).range([0,@h])
    bucketYH = (d) => 1 + heightRange(Math.abs(data[d]))
    bucketY = (d) =>
      return @h - heightRange(data[d]) if data[d] >= 0
      return @h
    keyx = d3.scale.linear().domain([0,1]).range([0,@w])
    #console.log "bucket width = #{@bucketWidth} for total width = #{@w} max is #{max}"
    #console.log "the buckets = #{JSON.stringify(buckets)}"
    groups = d3.select('#m-keygroup')
      .selectAll('rect')
      .data(buckets)
      .transition()
      .duration(600)
      .attr('y', bucketY)
      .attr('height', bucketYH)
      .attr('fill', (d) => colors(data[d]))
      .attr('data-original-title', (d) => Country.findByAttribute('key',d).name)
      .attr('movie-key', String)
    ### TODO make a x and y axis
    groups = d3.select('#m-keygroup')
      .selectAll('text')
      .data(buckets)
      .transition()
      .duration(600)
      .attr('y', (d) => bucketYH(d)+10)
      .text(String)
    groups = d3.select('#m-keygroupaxis')
      .selectAll('text')
      .data(buckets)
      .transition()
      .duration(600)
      .attr('class', (d)=>
        return "keyxaxistext" if d > 0
        return "keytext-invisible"
      )
    ###
    d3.select('#m-yaxislabel')
      .attr('fill',Options.disabledcountries)
      .text(Appdata.get('measure').desc)
    $("rect[movie-key='#{@previousSelection}']").attr('class','mk-selected') if @previousSelection?

  # update any selected country information - just listen for any appdata mentions..
  updateSelection: (r) ->
    c = Appdata.get('country')
    $('.mk-selected').attr('class','') if @previousSelection?
    $("rect[movie-key='#{c}']").attr('class','mk-selected')
    @previousSelection = c

module.exports = Mapkey
