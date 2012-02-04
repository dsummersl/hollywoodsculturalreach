Spine = require 'spine'
Country = require 'models/country'
Appdata = require 'models/appdata'

require 'spine/lib/relation' # just a little something I seem to need to do Cakefile(see makeJSON) relations...

class Overview extends Spine.Model
  @configure 'Overview', 'year', 'genre', 'other', 'hollywood', 'oldhollywood', 'othermoney', 'hollywoodmoney', 'oldhollywoodmoney'
  @belongsTo 'country', Country

  # the total number of movies in the country that are from hollywood
  # When a genre is selected I'm not interested in the % of hollywood love stories in
  # the country - they're all hollywood love stories if you are only selecting hollywood love stories.
  # 
  # Given all love stories from hollywood - I want to know what percentage of those the country saw.
  @totalHollyWoodRatio: (country,constraints={}) =>
    return @computeRatio(country,constraints,((o)=>o.hollywood+o.oldhollywood),((o)=>o.hollywood+o.oldhollywood+o.other))

  # the total revenue of movies in the country that are from hollywood
  @totalRevenueRatio: (country,constraints={}) =>
    return @computeRatio(country,constraints,((o)=>o.hollywoodmoney+o.oldhollywoodmoney),((o)=>o.hollywoodmoney+o.oldhollywoodmoney+o.othermoney))

  # if year is supplied then do a specific year, otherwise do all years
  # filters = {
  #   year: [2007,2008] etc... or just year: 2007
  #   genre: [...,...] etc genre: 'love'
  #   story: [...,...] etc
  #
  # When limited by year and genre the number would be of all movies for the year
  @computeRatio: (country,constraints,adder,totaller) =>
    # for some reason I have to re-import the country to use it:
    usa = require('models/country').findByAttribute('key','unitedstates')
    allusa = @filter(usa.overviews(),constraints)
    allusa = [] if not allusa
    all = @filter(country.overviews(),constraints)
    all = [] if not all
    #console.log "os = #{JSON.stringify(os)}" for os in all
    hollywood = 0
    hollywood+=adder(o) for o in all
    total = 0
    # TODO totaller is wrong it needs to total based on...
    # the total should be all from the same year that aren't the specific category
    total += totaller(o) for o in allusa
    return 0 if hollywood == total == 0
    return hollywood / total

  @filter: (overviews,constraints) =>
    filter = (el) =>
      result = true
      result = result and el.year == constraints.year if constraints.year?
      result = result and el.genre == constraints.genre if constraints.genre?
      return result
    return overviews.select(filter)

  @getConstraints: =>
      year = null
      year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'All'
      genre = Appdata.get('genres') if Appdata.get('genres') and Appdata.get('genres') != 'All'
      return {year:year,genre:genre}

module.exports = Overview
