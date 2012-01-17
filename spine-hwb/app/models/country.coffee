Spine = require('spine')
CountryMapping = require('lib/svgmap')

class Country extends Spine.Model
  @configure 'Country', 'name', 'region', 'key'
  # TODO population, languages
  
  getSVGIDs: ->
    val = CountryMapping[@key]
    #console.log "looking for #{@key} and it is #{CountryMapping[@key]}"
    if val
      return val if val instanceof Array
      return [val]
    return null

module.exports = Country
