Spine = require('spine')
Country = require('models/country')

require 'spine/lib/relation' # just a little something I seem to need to do Cakefile(see makeJSON) relations...

class Overview extends Spine.Model
  @configure 'Overview', 'year', 'other', 'hollywood', 'oldhollywood'
  @belongsTo 'country', Country

  # if year is supplied then do a specific year, otherwise do all years
  # filters = {
  #   year: [2007,2008] etc... or just year: 2007
  #   genre: [...,...] etc genre: 'love'
  #   story: [...,...] etc
  @totalHollyWoodRatio: (country,year=null) =>
    if year
      all = movies.select((el)=> el.year == year and movies.record.id == el.country_id)
    else
      all = movies.all()
    all = [] if not all
    total = 0
    total+=o.hollywood+o.oldhollywood for o in all
    return total

module.exports = Overview
