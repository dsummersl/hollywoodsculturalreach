Spine = require('spine')

class Movie extends Spine.Model
  @configure 'Movie', 'title', 'hollywood', 'story', 'genre', 'year', 'distributor'
  @extend Spine.Model.Local
 
module.exports = Movie
