Spine = require('spine')
Country = require('models/country')
Appdata = require 'models/appdata'

# information about a specific country, a table of actual movies.
class Detailsection extends Spine.Controller
  constructor: ->
    super
    Appdata.bind('update',@appupdate)
    $('#detailsection').append("""
    <div class="span8">
      <h2 id="ds-title">Title</h2>
      <div id="ds-summary"></div>
    </div>
    <div class="span8" id="ds-movies">
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
        $('#startuptext').text("Loading #{country.title} data...")
        #$('#startupdialog').fadeIn()
      $('#ds-movies').append(s.movie().title) for s in showings

module.exports = Detailsection
