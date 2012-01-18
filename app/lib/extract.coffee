require('lib/setup')

extractDomesticMovies = (datafile,year,listener)->
  # get the domestic tickets. I'm assuming these all need to be 'locally available'
  # for the spine app.
  # "row1": {"exclude": "","Film ": "Average","Major Studio": "","Rotten Tomatoes": "51","Audience Score": "","Story": "","Genre": "","Number of Theatres in Opening Weekend": "","Box Office Average per Cinema": "","Domestic Gross": "86.10","Foreign Gross": "105.38","Worldwide Gross": "191.47","Budget": "62.93","Market Profitability": "360.82%","Opening Weekend": "25.78","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "","Foreign Gross": "","Worldwide": "","Budget": ""},
 
extractCountrySummary = (datafile,year,listener)->
  # try to get the year, and then mush it out.

module.exports =
  extractDomesticMovies: extractDomesticMovies
  extractCountrySummary: extractCountrySummary
