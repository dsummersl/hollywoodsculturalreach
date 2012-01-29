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
    <div class="span4">
      <h2 id="ds-title">Title</h2>
      <div id="ds-summary"></div>
    </div>
    <div class="span12" id="ds-movies">
    </div>
    """)
    
  appupdate: (r) =>
    @log "updating details"
    if r.key == 'country'
      country = Country.findByAttribute('key',r.data)
      $('#ds-title').text(country.name)
      # TODO What to show...for #ds-summary
      $('#ds-summary').text('')
      $('#ds-summary').append("Some summary information...")
      $('#ds-movies').text('')
      showings = country.showings().all()
      if showings.length == 0
        $('#startuptext').text("Loading #{country.name} data...")
        $('#startupdialog').fadeIn()
        $.getJSON "data/#{country.key}.json", (d) =>
          for row in d
            m = Movie.create(row)
            # TODO money looks likeit might be zero for everybody
            ms = country.showings().create({year:d.year, boxoffice:d.money, movie_id:m.id})
          $('#startupdialog').fadeOut()
          @updateDetails(country.showings().all())
      else
        @updateDetails(showings)

  updateDetails: (showings) =>
    # TODO short by movie title 
    $('#ds-movies').append("<span class='ds-#{s.movie().hollywood}-hollywood'>#{s.movie().title}</span><span class='ds-dash'>&mdash;</span>") for s in showings

module.exports = Detailsection
