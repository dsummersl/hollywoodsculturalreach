Spine = require('spine')
Appdata = require 'models/appdata'

# information about a specific country, a table of actual movies.
class Detailsection extends Spine.Controller
  constructor: ->
    super
    Appdata.bind('update',@appupdate)
    $('#detailsection').append("""
    <h2 id="ds-title">Title</h2>
    <ul class="tabs">
      <li id="ds-summary" class="active"><a href="#">Summary</a></li>
      <li id="ds-movies"><a href="#">Movies</a></li>
    </ul>
    """)
    
  appupdate: (r) =>
    @log "updating details"
    if r.key == 'country'
      $('#ds-title')

module.exports = Detailsection
