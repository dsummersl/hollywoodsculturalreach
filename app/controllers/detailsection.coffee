Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Movie = require 'models/movie'
Options = require 'lib/options'

# information about a specific country, a table of actual movies.
class Detailsection extends Spine.Controller
  constructor: ->
    super
    Appdata.bind('update',@appupdate)
    $('#detailsection').append("""
    <hr/>
    <div class="span4">
      <h2 id="ds-title">Title</h2>
      <div id="ds-summary"></div>
    </div>
    <div class="span12" id="ds-movies">
    </div>
    """)
    
  appupdate: (r) =>
    if r.key == 'country'
      country = Country.findByAttribute('key',r.data)
      $('#ds-title').text(country.name)
      $('#ds-movies').text('')
      showings = country.showings().all()
      if showings.length == 0
        $('#startuptext').text("Loading #{country.name} data...")
        $('#startupdialog').fadeIn()
        $.getJSON "data/#{country.key}.json", (d) =>
          for row in d
            m = Movie.create(row)
            # TODO money looks likeit might be zero for everybody
            s = country.showings().create({year:row.year, boxoffice:row.money, movie_id:m.id})
            #console.log "adding #{s.boxoffice} to us total for #{m.title}"
            #console.log "row = #{JSON.stringify(d)}
          $('#startupdialog').fadeOut()
          showings = country.showings().all()
          @updateDetails(showings)
      else
        @updateDetails(showings)

  sprintmoney: (m) ->
    return $.sprintf('$%.1f bil',m/1000) if m > 1000
    return $.sprintf('$%.1f mil',m)

  updateDetails: (showings) =>
    # TODO filter by the current filters
    # TODO short by movie title 
    hollywoods = []
    nothollywoods = []
    hollywoodmoney = 0
    nothollywoodmoney = 0
    for s in showings
      m = s.movie()
      if m.hollywood
        hollywoodmoney += s.boxoffice
        hollywoods.push m
      else
        nothollywoodmoney += s.boxoffice
        nothollywoods.push m
    # TODO What to show...for #ds-summary
    # - show a pie chart breaking down the genre's and the distributors
    # - show the money amounts for total american exports. show non american.
    $('#ds-summary').text('')
    # TODO format the string as money
    $('#ds-summary').append("""
    <ul class="unstyled">
      <li>#{hollywoods.length} Hollywood movies: <span class="ds-rightside">#{@sprintmoney(hollywoodmoney)}</span></li>
      <li>#{nothollywoods.length} other movies: <span class="ds-rightside">#{@sprintmoney(nothollywoodmoney)}</span></li>
      <li><hr/></li>
    </ul>
    """)
    w = 700
    h = 400
    data =
      name: 'alldata'
      children: [
        {
          name: 'Hollywood',
          size: hollywoods.length
          text: ("<span class='ds-hollywood'>#{m.title}</span>" for m in hollywoods).join("<span class='ds-dash'> &mdash; </span>")
        },
        {
          name: 'Non Hollywood',
          size: nothollywoods.length
          text: ("<span class='ds-nothollywood'>#{m.title}</span>" for m in nothollywoods).join("<span class='ds-dash'> &mdash; </span>")
        }
      ]
    treemap = d3.layout.treemap()
      .size([w,h])
      .sticky(true)
      .value((d)=>d.size)
    $('#ds-movies').empty()
    div = d3.select('#ds-movies')
      .append('div')
      .style('position','relative')
      .style('width', w+'px')
      .style('height', h+'px')
    div.data([ data ]).selectAll('div')
      .data(treemap.nodes)
      .enter()
      .append('div')
      .attr('class','ds-cell')
      .style('background', (d)=>
        return Appdata.get('measure').colors[1] if not d.children and d.name == 'Hollywood'
        return Appdata.get('measure').colors[0]
      )
      .style('left',(d)=> d.x+'px')
      .style('top',(d)=> d.y+'px')
      .style('width',(d)=> d.dx+'px')
      .style('height',(d)=> d.dy+'px')
      .html((d)=> d.text)

module.exports = Detailsection
