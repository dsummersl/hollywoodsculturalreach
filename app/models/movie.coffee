Spine = require('spine')
Movieshowing = require 'models/movieshowing'

class Movie extends Spine.Model
  @configure 'Movie', 'title', 'hollywood', 'story', 'genre', 'year', 'distributor'
  @belongsTo 'showing', Movieshowing
 
module.exports = Movie
