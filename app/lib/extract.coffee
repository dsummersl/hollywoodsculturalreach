###
# Parse a file and then give the listener the following information:
#  - film = name of film
#  - year = year film was released
#  - story
#  - genre
###
extractDomesticMovies = (data,key,year,listener)->
  # get the domestic tickets. I'm assuming these all need to be 'locally available'
  # for the spine app.
  # first and second row is always a header:
  firstrow = true
  secondrow = true
  for k,v of data
    if not firstrow and not secondrow
      listener(
        film: v['Film ']
        story: v['Story']
        genre: v['Genre']
        year: year
        key: key
      )
    else
      if firstrow
        firstrow = false
      else if secondrow
        secondrow = false
 
###
# generate a summary of a data file. Keys include:
# - key:
# - year:
# - hollywoodfilms: total films from hollywood
# - oldhollywoodfilms: total films from hollywood (but not this year)
# - otherfilms: total films from we know not where
# 
# films = function that takes a title. returns a 'movie' like object:
# - year, title, etc
###
extractCountrySummary = (data,movies,key,year)->
  results =
    key: key
    year: year
    otherfilms: 0
    hollywoodfilms: 0
    oldhollywoodfilms: 0
  for k,v of data
    title = v[' Movie Title']
    f = movies.findByAttribute('title',title)
    if f
      if f.year == year
        results.hollywoodfilms++
      else
        results.oldhollywoodfilms++
    else
      results.otherfilms++
  return results

module.exports =
  extractDomesticMovies: extractDomesticMovies
  extractCountrySummary: extractCountrySummary
