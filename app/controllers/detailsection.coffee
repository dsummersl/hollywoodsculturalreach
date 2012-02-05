Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Movie = require 'models/movie'
Movieshowing = require 'models/movieshowing'
Options = require 'lib/options'
Overview = require 'models/overview'
Genrebreakout = require 'lib/genrebreakout'

# information about a specific country, a table of actual movies.
class Detailsection extends Spine.Controller
  constructor: ->
    super
    Appdata.bind('update',@appupdate)
    $('#detailsection').append("""
    <hr/>
    <div class="span6">
      <h2 id="ds-title">Title</h2>
      <div id="ds-summary"></div>
    </div>
    <div class="span6" id="ds-genres">
    </div>
    """)
    @genres = new Genrebreakout('#ds-genres')
    
  appupdate: (r) =>
    console.log "update details"
    if r.key == 'country' or r.key == 'years' or r.key == 'genres'
      country = Country.findByAttribute('key',Appdata.get('country'))
      showings = country.showings()
      if showings.all().length == 0
        $('#startuptext').text("Loading #{country.name} data...")
        $('#startupdialog').fadeIn()
        $.getJSON "data/#{country.key}.json", (d) =>
          for row in d
            m = Movie.findByAttribute('title',row.title)
            if not m?
              row.genre = 'Unknown'
              row.story = 'Unknown'
              m = Movie.create(row)
            s = country.showings().create({year:row.year, boxoffice:row.money, movie_id:m.id})
            #console.log "adding #{s.boxoffice} to us total for #{m.title}"
            #console.log "row = #{JSON.stringify(d)}
          $('#startupdialog').fadeOut()
          @genres.refresh(country.showings())
      else
        @genres.refresh(showings)

  old_appupdate: (r) =>
    if r.key == 'country' or r.key == 'years' or r.key == 'genres'
      country = Country.findByAttribute('key',Appdata.get('country'))
      $('#ds-title').text(country.name)
      $('#ds-movies').text('')
      showings = country.showings()
      if showings.all().length == 0
        $('#startuptext').text("Loading #{country.name} data...")
        $('#startupdialog').fadeIn()
        $.getJSON "data/#{country.key}.json", (d) =>
          for row in d
            m = Movie.findByAttribute('title',row.title)
            if not m?
              row.genre = 'Unknown'
              row.story = 'Unknown'
              m = Movie.create(row)
            s = country.showings().create({year:row.year, boxoffice:row.money, movie_id:m.id})
            #console.log "adding #{s.boxoffice} to us total for #{m.title}"
            #console.log "row = #{JSON.stringify(d)}
          $('#startupdialog').fadeOut()
          @updateDetails(country.showings())
      else
        @updateDetails(showings)

  updateDetails: (showings) =>
    # TODO sort by movie title 
    constrained = Overview.filter(showings,Overview.getConstraints()).sort((a,b) ->
      ###
      return a.movie().title - b.movie().title
      ###
      ss = [a.movie().title.toLowerCase(),b.movie().title.toLowerCase()].sort()
      return 1 if ss[0] == a
      return -1 if ss[0] == b
      return 0
    )
    #console.log "m = #{m.movie().title}" for m in constrained
    hollywoods = []
    nothollywoods = []
    hollywoodmoney = 0
    nothollywoodmoney = 0
    for s in constrained
      m = s.movie()
      if m.hollywood
        hollywoodmoney += s.boxoffice
        hollywoods.push m
      else
        nothollywoodmoney += s.boxoffice
        nothollywoods.push m
    # TODO What to show...for #ds-summary
    # - show a pie chart breaking down the genre's and the distributors
    $('#ds-summary').text('')
    $('#ds-summary').append("""
    <ul class="unstyled">
      <li>#{hollywoods.length} Hollywood movies: <span class="ds-rightside">#{Appdata.sprintmoney(hollywoodmoney)}</span></li>
      <li>#{nothollywoods.length} other movies: <span class="ds-rightside">#{Appdata.sprintmoney(nothollywoodmoney)}</span></li>
      <li><hr/></li>
    </ul>
    """)
    w = 700
    h = 400
    #<div id='#{m.id.replace('#','')}' style='visibility: hidden;'>My content</div>
    hs = []
    for m in hollywoods
      hs.push "<a class='ds-hollywood' data-original-title=\"#{m.title} <small>#{m.year} (#{m.genre})</small>\" movie-id='#{m.id}'>#{m.title}</a>"
    nhs = []
    for m in nothollywoods
      nhs.push "<a class='ds-nothollywood' data-original-title=\"#{m.title} <small>#{m.year} (#{m?.genre})</small>\" movie-id='#{m.id}'>#{m.title}</a>"
    data =
      name: 'alldata'
      children: [
        {
          name: 'Hollywood',
          size: hollywoods.length
          text: hs.join("<span class='ds-dash'> &mdash; </span>")
        },
        {
          name: 'Non Hollywood',
          size: nothollywoods.length
          text: nhs.join("<span class='ds-dash'> &mdash; </span>")
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
      .attr('class',(d) =>
         return 'ds-cell' if d.size > 0
         return 'ds-cell-empty'
      )
      .style('background', (d)=>
        #return Appdata.get('measure').colors[1] if not d.children and d.name == 'Hollywood'
        #return Appdata.get('measure').colors[0]
        return '#aa0000' if not d.children and d.name == 'Hollywood'
        return '#00bb00'
      )
      .style('left',(d)=> d.x+'px')
      .style('top',(d)=> d.y+'px')
      .style('width',(d)=> d.dx+'px')
      .style('height',(d)=> d.dy+'px')
      .html((d)=> d.text)
    popupfn = ->
      #console.log "painting content: #{$(@).attr('movie-id')}"
      #console.log "id = #{$(@).attr('class')}"
      #console.log "country = #{Appdata.get('country')}"
      m = Movie.find($(@).attr('movie-id'))
      c = Country.findByAttribute('key',Appdata.get('country'))
      usa = Country.findByAttribute('key','unitedstates')
      ms = Movieshowing.findByMC(m,c)
      usams = Movieshowing.findByMC(m,usa)
      usaboxoffice = ""
      usaboxoffice = "<li>US Box Office: <span class='ds-rightside'>#{Appdata.sprintmoney(usams.boxoffice)}</span></li>" if usams?
      return """
      <ul class="unstyled">
        <li>Distributor: <span class="ds-rightside">#{m.distributor}</span></li>
        <li>#{c.name} Box Office: <span class="ds-rightside">#{Appdata.sprintmoney(ms.boxoffice)}</span></li>
        #{usaboxoffice}
      </ul>"""

    $('.ds-hollywood').popover({placement: 'top', content: popupfn})
    $('.ds-nothollywood').popover({placement: 'top', content: popupfn})

module.exports = Detailsection
