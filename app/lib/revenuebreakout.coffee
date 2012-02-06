Spine = require('spine')
Overview = require 'models/overview'
Appdata = require 'models/appdata'
Country = require('models/country')
Options = require 'lib/options'

class Revenuebreakout
  constructor: (id) ->
    $(id).append("""
    <div>
      <h2 id="rb-country">Country</h2>
      <div id="rb-graph"></div>
    </div>
    """)
    @h = 500
    @w = 450
    @svg = d3.select('#rb-graph').append('svg')
      .attr('width',@w+20)
      .attr('height',@h+20)
    @graphtop = @svg.append('g')
      .attr('transform', 'translate(10,10)')
    @graphbottom = @svg.append('g')
      .attr('transform', 'translate(10,10)')
    @graph = @svg.append('g')
      .attr('transform', 'translate(10,10)')
    # y axis
    @graph.append('line')
      .attr('x1',0)
      .attr('y1',10)
      .attr('x2',0)
      .attr('y2',@h)
      .style('stroke',Options.disabledcountries)
    @graph.append('line')
      .attr('x1',0)
      .attr('y1',10)
      .attr('x2',-4)
      .attr('y2',20)
      .style('stroke',Options.disabledcountries)
    @graph.append('text')
      .attr('class','rb-keytext')
      .attr('x', 0)
      .attr('y', 5)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "middle")
      .text('$')
    # x axis
    @graph.append('line')
      .attr('x1',0)
      .attr('y1',@h)
      .attr('x2',@w-50)
      .attr('y2',@h)
      .style('stroke',Options.disabledcountries)
    @graph.append('line')
      .attr('x1',@w-50)
      .attr('y1',@h)
      .attr('x2',@w-60)
      .attr('y2',@h+4)
      .style('stroke',Options.disabledcountries)
    @graph.append('text')
      .attr('class','rb-keytext')
      .attr('x', @w-20)
      .attr('y', @h+4)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "middle")
      .text('# Movies')


  refresh: (showings) =>
    country = Country.findByAttribute('key',Appdata.get('country'))
    $('#rb-country').text(country.name)

    constrained = Overview.filter(showings,Overview.getConstraints())
    h = []
    nh = []
    hMoney = 0
    nhMoney = 0
    for s in constrained
      m = s.movie()
      maxMoney = s.boxoffice if s.boxoffice > maxMoney
      if m.hollywood
        h.push s
        hMoney += s.boxoffice
      else
        nh.push s
        nhMoney += s.boxoffice

    h = h.sort((a,b)=>a.boxoffice-b.boxoffice)
    nh = nh.sort((a,b)=>a.boxoffice-b.boxoffice)

    top = nh
    bottom = h
    if nh.length > h.length
      top = h
      bottom = nh

    runup = 0
    for s in bottom
      s.runup = s.boxoffice + runup
      runup += s.boxoffice
    for s in top
      s.runup = s.boxoffice + runup
      runup += s.boxoffice

    yRange = d3.scale.linear().domain([0,hMoney+nhMoney]).range([0,@h])
    xRange = d3.scale.linear().domain([0,Math.max(h.length,nh.length)]).range([0,@w])

    ###
    console.log "@h = #{@h}"
    console.log "top money and bottom money = #{hMoney} and #{nhMoney}"
    console.log "bottom count and top count = #{bottom.length} #{top.length}"

    poly = @graph.selectAll('.rb-top-poly')
      .data([0])
    points =[]
    if top.length > 0
      points = ["#{xRange(bottom.length)},#{@h}"]
      points.push "#{xRange(bottom.length-i)},#{@h-yRange(s.runup)}" for s,i in top by 10
      points.push ["#{xRange(bottom.length-top.length)},#{@h-yRange(top[top.length-1].runup)}"]
      points.push ["#{xRange(bottom.length-top.length)},#{@h}"]
      poly.enter()
        .append('polygon')
        .attr('class','rb-top-poly')
        .attr('points',points.join(' '))
      poly.exit()
        .transition()
        .duration(600)
        .remove()
    poly.transition()
      .duration(600)
      .attr('points',points.join(' '))

    poly = @graph.selectAll('.rb-bottom-poly')
      .data([0])
    points = []
    if bottom.length > 0
      points.push "#{xRange(i)},#{@h-yRange(s.runup)}" for s,i in bottom by 10
      points.push ["#{xRange(bottom.length-1)},#{@h-yRange(bottom[bottom.length-1].runup)}"]
      points.push ["#{xRange(bottom.length-1)},#{@h}"]
      poly.enter()
        .append('polygon')
        .attr('class','rb-bottom-poly')
        .attr('points',points.join(' '))
      poly.exit()
        .transition()
        .duration(600)
        .remove()
    poly.transition()
      .duration(600)
      .attr('points',points.join(' '))
    ###

    common = ->
      @.attr('data-original-title',(d)=>"#{d.movie().title} <small>#{d.movie().year} (#{d.movie().genre})</small>")
      .attr('movie-id',(d)=>d.movie().id)
      .attr('width', 2)
      .attr('fill', (d)=>
        return "#eeeeee" if d.movie().hollywood
        return "#cccccc"
      )

    dots = @graphtop.selectAll('.rb-top')
      .data(top)
    dots.enter()
      .append('rect')
      .attr('class','rb-top')
      .attr('x', (d,i)=>xRange(bottom.length-i))
      .attr('y', (d,i)=>@h-yRange(d.runup))
      .attr('height', 1)
      .call(common)
      .transition()
      .duration(600)
      .attr('height', (d)=>yRange(d.runup))
    dots.transition()
      .duration(600)
      .attr('x', (d,i)=>xRange(bottom.length-i))
      .attr('y', (d,i)=>@h-yRange(d.runup))
      .attr('height', (d)=>yRange(d.runup))
      .call(common)
    dots.exit()
      .transition()
      .duration(600)
      .remove()
    dots = @graphbottom.selectAll('.rb-bottom')
      .data(bottom)
    dots.enter()
      .append('rect')
      .attr('class','rb-bottom')
      .attr('x', (d,i)=>xRange(i))
      .attr('y', (d,i)=>@h-yRange(d.runup))
      .attr('height', 1)
      .call(common)
      .transition()
      .duration(600)
      .attr('height', (d)=>yRange(d.runup))
    dots.transition()
      .duration(600)
      .attr('x', (d,i)=>xRange(i))
      .attr('y', (d,i)=>@h-yRange(d.runup))
      .attr('height', (d)=>yRange(d.runup))
      .call(common)
    dots.exit()
      .transition()
      .duration(600)
      .remove()

module.exports = Revenuebreakout
