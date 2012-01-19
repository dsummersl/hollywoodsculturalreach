Spine = require('spine')
Country = require('models/country')

class Movie extends Spine.Model
  @configure 'Movie', 'title', 'story', 'genre', 'year'
  @belongsTo 'country', Country
  
module.exports = Movie
