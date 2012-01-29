Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'
Movie = require 'models/movie'

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
      # TODO What to show...for #ds-summary
      # - show a pie chart breaking down the genre's and the distributors
      # - show the money amounts for total american exports. show non american.
      $('#ds-summary').text('')
      $('#ds-summary').append("Some summary information...")
      if showings.length == 0
        $('#startuptext').text("Loading #{country.name} data...")
        $('#startupdialog').fadeIn()
        $.getJSON "data/#{country.key}.json", (d) =>
          for row in d
            m = Movie.create(row)
            # TODO money looks likeit might be zero for everybody
            ms = country.showings().create({year:d.year, boxoffice:d.money, movie_id:m.id})
          $('#startupdialog').fadeOut()
          showings = country.showings().all()
          @updateDetails(showings)
      else
        @updateDetails(showings)

  updateDetails: (showings) =>
    # TODO filter by the current filters
    # TODO short by movie title 
    hollywoods = []
    nothollywoods = []
    for s in showings
      m = s.movie()
      if m.hollywood
        hollywoods.push m
      else
        nothollywoods.push m
    $('#ds-movies').append("<span class='ds-hollywood'>#{m.title}</span><span class='ds-dash'>&mdash;</span>") for m in hollywoods
    $('#ds-movies').append("<span class='ds-nothollywood'>#{m.title}</span><span class='ds-dash'>&mdash;</span>") for m in nothollywoods

module.exports = Detailsection
