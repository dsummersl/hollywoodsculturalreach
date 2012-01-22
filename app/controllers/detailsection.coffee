Spine = require('spine')

# information about a specific country, a table of actual movies.
class Detailsection extends Spine.Controller
  constructor: ->
    super
    $('#detailsection').append("""
    <h1>Title</h1>
    <hr/>
    body
    """)
    
module.exports = Detailsection
