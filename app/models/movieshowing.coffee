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

  # find by movie and country
  @findByMC: (movie,country) ->
    results = @select((el)=>
      return true if el.movie_id == movie.id and el.country_id == country.id
      return false
    )
    throw "There was more than one showing (#{results.length}), there should be no more than one" if results?.length > 1
    return results[0] if results?.length == 1
    return null

module.exports = Movieshowing
