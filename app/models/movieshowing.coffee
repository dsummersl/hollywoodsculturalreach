Spine = require('spine')
Country = require('models/country')
Movie = require('models/movie')

require 'spine/lib/relation' # just a little something I seem to need to do Cakefile(see makeJSON) relations...

class Movieshowing extends Spine.Model
  @configure 'Movieshowing', 'year', 'boxoffice', 'movie_id'
  @belongsTo 'country', Country
  # this hasOne thing doensn't work the way I thought it would:
  #@hasOne 'movie', Movie
  #@extend Spine.Model.Local
  
  movie: -> Movie.find(@movie_id)

module.exports = Movieshowing
