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
  results =
    key: key
    year: year
    otherfilms: 0
    hollywoodfilms: 0
    oldhollywoodfilms: 0
    otherfilmmoney: 0
    hollywoodfilmmoney: 0
    oldhollywoodfilmmoney: 0
  firstrow = true
  for k,v of data
    if not firstrow
      title = v['Film ']
      title = v['Film'] if not title
      title = title.trim()
      results.hollywoodfilms++
      val = parseFloat(v['Domestic Gross'])*1000000
      results.hollywoodfilmmoney += val if val
      #console.log "hollywood = #{results.hollywoodfilmmoney} for #{v['Domestic Gross']}"
      listener(
        film: title
        story: v['Story']
        genre: v['Genre']
        year: year
        key: key
      )
    else
      if firstrow
        firstrow = false
  return results
 
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
    otherfilmmoney: 0
    hollywoodfilmmoney: 0
    oldhollywoodfilmmoney: 0
  for k,v of data
    title = v[' Movie Title'].trim()
    money = 0
    money = v.Gross.replace(/\$/,'').replace(/,/g,'') if v.Gross
    f = movies.findByAttribute('title',title)
    #console.log "looking for '#{title}' and found '#{f?.title}' = money = #{money} before it was #{v.Gross}"
    money = parseInt(money)
    if f
      #console.log " -  year info '#{f?.year}' == '#{year}' ? #{f?.year == year}"
      if f.year == year
        results.hollywoodfilms++
        results.hollywoodfilmmoney += money
      else
        results.oldhollywoodfilms++
        results.oldhollywoodfilmmoney += money
    else
      results.otherfilms++
      results.otherfilmmoney += money
  return results

module.exports =
  extractDomesticMovies: extractDomesticMovies
  extractCountrySummary: extractCountrySummary
