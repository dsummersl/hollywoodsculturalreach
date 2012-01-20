Spine = require('spine')
CountryMapping = require('lib/svgmap')
Overview = require('models/overview')
Movie = require('models/movie')

class Country extends Spine.Model
  @configure 'Country', 'name', 'region', 'key'
  @hasMany 'overviews', Overview
  @hasMany 'movies', Movie

  # TODO population, languages
  
  getSVGIDs: ->
    val = CountryMapping[@key]
    #console.log "looking for #{@key} and it is #{CountryMapping[@key]}"
    if val
      return val if val instanceof Array
      return [val]
    return null

module.exports = Country
