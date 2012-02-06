Spine = require('spine')
Overview = require 'models/overview'
Appdata = require 'models/appdata'
Country = require('models/country')
Options = require 'lib/options'

class Revenuebreakout
  constructor: (id) ->
    $(id).append("""
    <div>
      <h3 id="rb-country">Country</h3>
      <div id="rb-graph"></div>
      <div id="rb-bottomsummary"></div>
    </div>
    """)
    @h = 400
    @w = 350
    @margin = 100
    @m = 10
    @svg = d3.select('#rb-graph').append('svg')
      .attr('width',@w+@margin+@m*2)
      .attr('height',@h+@m*2+10)
    @graphtop = @svg.append('g')
      .attr('transform', "translate(#{@m},#{@m})")
    @graphbottom = @svg.append('g')
      .attr('transform', "translate(#{@m},#{@m})")
    @graph = @svg.append('g')
      .attr('transform', "translate(#{@m},#{@m})")
    # y axis
    @graph.append('line')
      .attr('x1',0)
      .attr('y1',@m)
      .attr('x2',0)
      .attr('y2',@h)
      .style('stroke',Options.disabledcountries)
    @graph.append('line')
      .attr('x1',0)
      .attr('y1',@m)
      .attr('x2',-4)
      .attr('y2',@m*2)
      .style('stroke',Options.disabledcountries)
    @graph.append('text')
      .attr('class','rb-keytext')
      .attr('x', 25)
      .attr('y', 5)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "middle")
      .text('movie total')
    # x axis
    @graph.append('line')
      .attr('x1',0)
      .attr('y1',@h)
      .attr('x2',@w+@margin-50)
      .attr('y2',@h)
      .style('stroke',Options.disabledcountries)
    @graph.append('line')
      .attr('x1',@w+@margin-50)
      .attr('y1',@h)
      .attr('x2',@w+@margin-60)
      .attr('y2',@h+4)
      .style('stroke',Options.disabledcountries)
    @graph.append('text')
      .attr('class','rb-keytext')
      .attr('x', @w+@margin-20)
      .attr('y', @h+4)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "middle")
      .text('# Movies')


  refresh: (constrained) =>
    country = Country.findByAttribute('key',Appdata.get('country'))
    $('#rb-country').text("Box Office totals in #{country.name}")
    $('#rb-bottomsummary').html("Box office totals in #{country.name} ordered from lowest box office movies to highest, grouped by Hollywood (light gray) vs Non-Hollywood (dark).")

    h = []
    nh = []
    hMoney = 0
    nhMoney = 0
    #console.log "revenue total = #{constrained.length}"
    for s in constrained
      m = s.movie()
      maxMoney = s.boxoffice if s.boxoffice > maxMoney
      if m.hollywood
        h.push s
        hMoney += s.boxoffice
      else
        nh.push s
        nhMoney += s.boxoffice
    #console.log "h total = #{h.length}"
    #console.log "nh total = #{nh.length}"

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

    yRange = d3.scale.linear().domain([0,hMoney+nhMoney]).range([5,@h])
    xRange = d3.scale.linear().domain([0,Math.max(h.length,nh.length)]).range([0,@w])

    common = ->
      # TODO we've having a problem here with the ms.id and movie id...someimtes then don't seiralize correctly. Very weird.
      # but it works fine on the genre breakout screen.
      @.attr('data-original-title',(d)=>"#{d.movie().title} <small>#{d.movie().year} (#{d.movie().genre})</small>")
      .attr('ms-id',(d)=>d.id)
      .attr('width', 4)
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

    ymarks = []
    ymarks.push(bottom[bottom.length-1]) if bottom.length > 0
    ymarks.push(top[top.length-1]) if top.length > 0
    ymarkgraph = @graph.selectAll('.rb-ymark')
      .data(ymarks)
    ymarkgraph.enter()
      .append('line')
      .attr('class','rb-ymark')
      .style('stroke',Options.disabledcountries)
      .style('stroke-dasharray','3, 3')
      .attr('x1',(d,i)=>
        return xRange(bottom.length-1)+2 if ymarks.length == 1 or i == 0
        return xRange(bottom.length-top.length)+2
      )
      .attr('x2',(d,i)=> return xRange(bottom.length-1)+20)
      .attr('y1', (d,i)=>@h-yRange(d.runup))
      .attr('y2', (d,i)=>@h-yRange(d.runup))
    ymarkgraph.transition()
      .duration(600)
      .attr('x1',(d,i)=>
        return xRange(bottom.length-1)+2 if ymarks.length == 1 or i == 0
        return xRange(bottom.length-top.length)+2
      )
      .attr('x2',(d,i)=> return xRange(bottom.length-1)+20)
      .attr('y1', (d,i)=>@h-yRange(d.runup))
      .attr('y2', (d,i)=>@h-yRange(d.runup))
    ymarkgraph.exit()
      .transition()
      .duration(600)
      .remove()

    ymarkgraphtext = @graph.selectAll('.rb-ymark-text')
      .data(ymarks)
    ymarkgraphtext.enter()
      .append('text')
      .attr('class','rb-ymark-text')
      .attr('x', @w+@margin)
      .attr('y', (d,i)=>@h-yRange(d.runup)+4)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "end")
      .text((d,i)=>
        return Appdata.sprintmoney(bottom[bottom.length-1].boxoffice) if ymarks.length == 1 or i == 0
        return Appdata.sprintmoney(top[top.length-1].boxoffice)
      )
    ymarkgraphtext.transition()
      .duration(600)
      .attr('y', (d,i)=>@h-yRange(d.runup)+4)
      .text((d,i)=>
        return Appdata.sprintmoney(bottom[bottom.length-1].runup) if ymarks.length == 1 or i == 0
        return Appdata.sprintmoney(top[top.length-1].runup)
      )
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()

    ymarkgraphtext = @graph.selectAll('.rb-ymark-text2')
      .data(ymarks)
    ymarkgraphtext.enter()
      .append('text')
      .attr('class','rb-ymark-text2')
      .attr('x', @w+@margin)
      .attr('y', (d,i)=>@h-yRange(d.runup)+4+15)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "end")
      .text((d,i)=>
        if ymarks.length == 1 or i == 0
          m = bottom[bottom.length-1]
        else
          m = top[top.length-1]
        return "#{m.movie().title} - #{Appdata.sprintmoney(m.boxoffice)}"
      )
    ymarkgraphtext.transition()
      .duration(600)
      .attr('y', (d,i)=>@h-yRange(d.runup)+4+15)
      .text((d,i)=>
        if ymarks.length == 1 or i == 0
          m = bottom[bottom.length-1]
        else
          m = top[top.length-1]
        return "#{m.movie().title} - #{Appdata.sprintmoney(m.boxoffice)}"
      )
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()

    ymarkgraphtext = @graph.selectAll('.rb-ymark-text3')
      .data(ymarks)
    ymarkgraphtext.enter()
      .append('text')
      .attr('class','rb-ymark-text3')
      .attr('x', @w+@margin)
      .attr('y', (d,i)=>@h-yRange(d.runup)+4+30)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', "end")
      .text((d,i)=>
        if ymarks.length == 1 or i == 0
          m = bottom[bottom.length-2]
        else
          m = top[top.length-2]
        return "#{m.movie().title} - #{Appdata.sprintmoney(m.boxoffice)}"
      )
    ymarkgraphtext.transition()
      .duration(600)
      .attr('y', (d,i)=>@h-yRange(d.runup)+4+30)
      .text((d,i)=>
        if ymarks.length == 1 or i == 0
          m = bottom[bottom.length-2]
        else
          m = top[top.length-2]
        return "#{m.movie().title} - #{Appdata.sprintmoney(m.boxoffice)}"
      )
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()

    lines = []
    lines.push 0 if ymarks.length > 1

    ymarkgraphtext = @graph.selectAll('.rb-xaxis-line1')
      .data(lines)
    ymarkgraphtext.enter()
      .append('line')
      .attr('class','rb-xaxis-line1')
      .attr('y1' , @h+10)
      .attr('y2' , @h+10)
      .attr('x1' ,(d,i)=> xRange(bottom.length-1))
      .attr('x2' ,(d,i)=> return xRange(bottom.length-top.length)+2)
      .attr('stroke',Options.disabledcountries)
      .text((d,i)=>
        return bottom.length if ymarks.length == 1 or i == 0
        return top.length
      )
    ymarkgraphtext.transition()
      .duration(600)
      .attr('y1' , @h+10)
      .attr('y2' , @h+10)
      .attr('x1' ,(d,i)=> xRange(bottom.length-1))
      .attr('x2' ,(d,i)=> return xRange(bottom.length-top.length)+2)
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()

    ymarkgraphtext = @graph.selectAll('.rb-xaxis-line2')
      .data(lines)
    ymarkgraphtext.enter()
      .append('line')
      .attr('class','rb-xaxis-line2')
      .attr('y1' , @h+2)
      .attr('y2' , @h+15)
      .attr('x1' ,(d,i)=> return xRange(bottom.length-top.length)+2)
      .attr('x2' ,(d,i)=> return xRange(bottom.length-top.length)+2)
      .attr('stroke',Options.disabledcountries)
      .text((d,i)=>
        return bottom.length if ymarks.length == 1 or i == 0
        return top.length
      )
    ymarkgraphtext.transition()
      .duration(600)
      .attr('y1' , @h+5)
      .attr('y2' , @h+15)
      .attr('x1' ,(d,i)=> return xRange(bottom.length-top.length)+1)
      .attr('x2' ,(d,i)=> return xRange(bottom.length-top.length)+1)
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()

    ymarkgraphtext = @graph.selectAll('.rb-xaxis-bg')
      .data(lines)
    ymarkgraphtext.enter()
      .append('rect')
      .attr('class','rb-xaxis-bg')
      .attr('y' , @h+5)
      .attr('x' ,(d,i)=> return xRange(bottom.length-top.length/2) - 15)
      .attr('height' , 10)
      .attr('width' , 30)
      .attr('fill','white')
    ymarkgraphtext.transition()
      .duration(600)
      .attr('x' ,(d,i)=> return xRange(bottom.length-top.length/2) - 15)
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()

    ymarkgraphtext = @graph.selectAll('.rb-xaxis-text1')
      .data(ymarks)
    ymarkgraphtext.enter()
      .append('text')
      .attr('class','rb-xaxis-text1')
      .attr('x' ,(d,i)=>
        return xRange(bottom.length-1)+4 if ymarks.length == 1 or i == 0
        return xRange(bottom.length-top.length/2)+2
      )
      .attr('y', (d,i)=>@h+15)
      .attr('fill',Options.disabledcountries)
      .attr('text-anchor', (d,i)=>
        return "start" if ymarks.length == 1 or i == 0
        return "middle"
      )
      .text((d,i)=>
        return bottom.length if ymarks.length == 1 or i == 0
        return top.length
      )
    ymarkgraphtext.transition()
      .duration(600)
      .attr('x' ,(d,i)=>
        return xRange(bottom.length-1)+4 if ymarks.length == 1 or i == 0
        return xRange(bottom.length-top.length/2)+2
      )
      .text((d,i)=>
        return bottom.length if ymarks.length == 1 or i == 0
        return top.length
      )
    ymarkgraphtext.exit()
      .transition()
      .duration(600)
      .remove()


module.exports = Revenuebreakout
