Spine = require('spine')
Country = require('models/country')

require 'spine/lib/relation' # just a little something I seem to need to do Cakefile(see makeJSON) relations...

class Overview extends Spine.Model
  @configure 'Overview', 'year', 'other', 'hollywood', 'oldhollywood'
  @belongsTo 'country', Country

  # if year is supplied then do a specific year, otherwise do all years
  @totalHollyWoodRatio: (collection,year=null) =>
    all = collection.all() if not year
    all = collection.findByAttribute('year',year) if year
    total = 0
    total+=o.hollywood+o.oldhollywood for o in all
    return total

module.exports = Overview
