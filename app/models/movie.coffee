Spine = require('spine')

class Movie extends Spine.Model
  @configure 'Movie', 'title', 'hollywood', 'story', 'genre', 'year', 'distributor'
 
module.exports = Movie
