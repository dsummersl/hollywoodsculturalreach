makeEmptyOverview = (k,y,g) ->
  key: k
  year: y
  genre: g
  other: 0
  hollywood: 0
  oldhollywood: 0
  othermoney: 0
  hollywoodmoney: 0
  oldhollywoodmoney: 0

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
  results = []
  firstrow = true
  secondrow = true
  for k,v of data
    if not firstrow and not secondrow
      title = v['Film ']
      title = v['Film'] if not title
      title = title.trim()
      genre = v['Genre']
      overview = null
      for o in results when o.year == year and o.genre == genre
        overview = o
      if overview == null
        overview = makeEmptyOverview(key,year,genre)
        results.push overview
      overview.hollywood++
      val = parseFloat(v['Domestic Gross'])*1000000
      overview.hollywoodmoney += val if val
      #console.log "hollywood = #{overview.hollywoodmoney} for #{v['Domestic Gross']}"
      listener(
        film: title
        story: v['Story']
        genre: genre
        year: year
        key: key
        domestic: val
        distributor: v['Major Studio']
      )
    else
      if firstrow
        firstrow = false
      else if secondrow
        secondrow = false
  return results
 
###
# Extract movies for a country
###
extractCountryMovies = (data,movies,year)->
  results = []
  for k,v of data
    title = v[' Movie Title']
    # see if any years are embedded in the title and if so extract them:
    matches = title.match(/^.*\((\d\d\d\d)\).*/)
    if matches and matches.length > 1
      title = title.replace(/\(\d\d\d\d\)/,'')
      year = parseInt(matches[1])
    title = title.trim()
    money = 0
    money = v.Gross.replace(/\$/,'').replace(/,/g,'') if v.Gross
    f = movies.findByAttribute('title',title)
    #console.log "looking for '#{title}' and found '#{f?.title}' = money = #{money} before it was #{v.Gross}"
    money = parseInt(money)
    hollywood = false
    hollywood = f.hollywood if f != null
    exists = f != null
    distributor = v['Distributor']
    distributor = f.distributor if f != null
    year = f.year if f != null
    results.push({title: title, money:money,hollywood:hollywood,exists:exists,distributor:distributor,year:year})
  return results

###
# generate a summary of a data file. Keys include:
# - key:
# - year:
# - hollywood: total films from hollywood
# - oldhollywood: total films from hollywood (but not this year)
# - other: total films from we know not where
# 
# films = function that takes a title. returns a 'movie' like object:
# - year, title, etc
###
extractCountrySummary = (data,movies,key,year)->
  results = []
  results.push makeEmptyOverview(key,year,'Unknown')
  unknownO = results[0]
  for k,v of data
    title = v[' Movie Title'].trim()
    money = 0
    money = v.Gross.replace(/\$/,'').replace(/,/g,'') if v.Gross
    f = movies.findByAttribute('title',title)
    #console.log "looking for '#{title}' and found '#{f?.title}' = money = #{money} before it was #{v.Gross}"
    money = parseInt(money)
    if f
      overview = null
      for o in results when o.year == year and o.genre == f.genre
        overview = o
      if overview == null
        overview = makeEmptyOverview(key,year,f.genre)
        results.push overview
      #console.log " -  year info '#{f?.year}' == '#{year}' ? #{f?.year == year}"
      if f.year == year
        overview.hollywood++
        overview.hollywoodmoney += money
      else
        overview.oldhollywood++
        overview.oldhollywoodmoney += money
    else
      unknownO.other++
      unknownO.othermoney += money
  return results

module.exports =
  extractDomesticMovies: extractDomesticMovies
  extractCountrySummary: extractCountrySummary
  extractCountryMovies: extractCountryMovies
