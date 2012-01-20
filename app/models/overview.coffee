Spine = require('spine')
Country = require('models/country')

require 'spine/lib/relation' # just a little something I seem to need to do Cakefile(see makeJSON) relations...

class Overview extends Spine.Model
  @configure 'Overview', 'year', 'other', 'hollywood', 'oldhollywood'
  @belongsTo 'country', Country

  # if year is supplied then do a specific year, otherwise do all years
  @totalHollyWoodRatio: (year=null) =>
    if year
      @log "totalHollyWoodRatio for year is not defined"
    else

module.exports = Overview
