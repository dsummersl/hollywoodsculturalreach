Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Movie = require 'models/movie'
Movieshowing = require 'models/movieshowing'
Options = require 'lib/options'
Extras = require 'lib/extrahollywoods'
Overview = require 'models/overview'
Genrebreakout = require 'lib/genrebreakout'
Revenuebreakout = require 'lib/revenuebreakout'

# information about a specific country, a table of actual movies.
class Detailsection extends Spine.Controller
  constructor: ->
    super
    Appdata.bind('update',@appupdate)
    $('#detailsection').append("""
    <div class="span6" id="ds-revenues"></div>
    <div class="span6" id="ds-genres"></div>
    """)
    @genres = new Genrebreakout('#ds-genres')
    @revenues = new Revenuebreakout('#ds-revenues')
    
  appupdate: (r) =>
    popupfn = ->
      try
        m = Movie.find($(@).attr('movie-id'))
        c = Country.findByAttribute('key',Appdata.get('country'))
        usa = Country.findByAttribute('key','unitedstates')
        ms = Movieshowing.findByMC(m,c)
        usams = Movieshowing.findByMC(m,usa)
        usaboxoffice = ""
        usaboxoffice = "<li>US Box Office: <span class='ds-rightside'>#{Appdata.sprintmoney(usams.boxoffice)}</span></li>" if usams?
        # TODO show global revenue
        return """
        <ul class="unstyled">
          <li>Distributor: <span class="ds-rightside">#{m.distributor}</span></li>
          <li>#{c.name} Box Office: <span class="ds-rightside">#{Appdata.sprintmoney(ms.boxoffice)}</span></li>
          #{usaboxoffice}
        </ul>"""
      catch error
        return ""

    if r.key == 'country' or r.key == 'years' or r.key == 'genres'
      country = Country.findByAttribute('key',Appdata.get('country'))
      $('#startupdialog').fadeIn()
      showings = country.showings()
      $('#startuptext').text("Loading #{country.name} data...")
      if showings.all().length == 0
        $.getJSON "data/#{country.key}.json", (d) =>
          for row in d
            title = row.title.toLowerCase()
            title = Extras.alternatemappings[title] if Extras.alternatemappings[title]?
            m = Movie.select((el) => return el.title.toLowerCase() == title)
            if m.length == 0
              row.genre = 'Unknown'
              row.story = 'Unknown'
              m = Movie.create(row)
              #console.log "making new movie: #{m.title} - alternate? #{Extras.alternatemappings[row.title.toLowerCase()]}"
            else
              m = m[0]
            s = country.showings().create({year:row.year, boxoffice:row.money, movie_id:m.id})
            #console.log "adding #{s.boxoffice} to us total for #{m.title}"
            #console.log "row = #{JSON.stringify(d)}
          constrained = Overview.filter(country.showings(),Overview.getConstraints())
          console.log "constrained to #{JSON.stringify(Overview.getConstraints())}: #{constrained.length}"
          @genres.refresh(constrained)
          @revenues.refresh(constrained)
          $('.ds-movie').popover({placement: 'top', content: popupfn})
          $('.rb-bottom').popover({placement: 'top', content: popupfn})
          $('.rb-top').popover({placement: 'top', content: popupfn})
          $('#startupdialog').fadeOut()
      else
        constrained = Overview.filter(showings,Overview.getConstraints())
        console.log "cached constrained to #{JSON.stringify(Overview.getConstraints())}: #{constrained.length}"
        @genres.refresh(constrained)
        @revenues.refresh(constrained)
        $('.ds-movie').popover({placement: 'top', content: popupfn})
        $('.rb-bottom').popover({placement: 'top', content: popupfn})
        $('.rb-top').popover({placement: 'top', content: popupfn})
        $('#startupdialog').fadeOut()

module.exports = Detailsection
