require = window.require
Spine = require 'spine'
Movie = require 'models/movie'
Extract = require('lib/extract')
Spine.Model.Ajax = {}

describe 'Extract', ->
  yearlyData = {"row0": {"exclude": "","Film ": "","Major Studio": "","Rotten Tomatoes": "","Audience Score": "","Story": "","Genre": "","Number of Theatres in Opening Weekend": "","Box Office Average per Cinema": "($)","Domestic Gross": "($m)","Foreign Gross": "($m)","Worldwide Gross": "($m)","Budget": "($m)","Market Profitability": "% of budget recovered","Opening Weekend": "($m)","Oscar": "","Bafta": "","Source": "all the-numbers.com","": "","Domestic Gross": "($)","Foreign Gross": "($)","Worldwide": "($)","Budget": "($)"},
  "row1": {"exclude": "","Film ": "Average","Major Studio": "","Rotten Tomatoes": "51","Audience Score": "","Story": "","Genre": "","Number of Theatres in Opening Weekend": "","Box Office Average per Cinema": "","Domestic Gross": "86.10","Foreign Gross": "105.38","Worldwide Gross": "191.47","Budget": "62.93","Market Profitability": "360.82%","Opening Weekend": "25.78","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "","Foreign Gross": "","Worldwide": "","Budget": ""},
  "row2": {"exclude": "","Film ": "Juno","Major Studio": "Fox","Rotten Tomatoes": "94","Audience Score": "89","Story": "Maturation","Genre": "Comedy","Number of Theatres in Opening Weekend": "1019","Box Office Average per Cinema": "10436","Domestic Gross": "143.50","Foreign Gross": "87.69","Worldwide Gross": "231.18","Budget": "7.50","Market Profitability": "3082.46%","Opening Weekend": "10.6","Oscar": "Original Screenplay","Bafta": "Original Screenplay","Source": "","": "","Domestic Gross": "143495265","Foreign Gross": "87688908","Worldwide": "231184173","Budget": "7500000"},
  "row3": {"exclude": "","Film ": "Saw IV","Major Studio": "Independent","Rotten Tomatoes": "18","Audience Score": "70","Story": "Escape","Genre": "Horror","Number of Theatres in Opening Weekend": "3183","Box Office Average per Cinema": "9976","Domestic Gross": "63.30","Foreign Gross": "76.05","Worldwide Gross": "139.35","Budget": "10.00","Market Profitability": "1393.53%","Opening Weekend": "31.7","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "63300095","Foreign Gross": "76052538","Worldwide": "139352633","Budget": "10000000"},
  "row4": {"exclude": "","Film ": "Waitress","Major Studio": "Independent","Rotten Tomatoes": "89","Audience Score": "67","Story": "Love","Genre": "Romance","Number of Theatres in Opening Weekend": "605","Box Office Average per Cinema": "3327","Domestic Gross": "19.07","Foreign Gross": "3.10","Worldwide Gross": "22.18","Budget": "2.00","Market Profitability": "1108.97%","Opening Weekend": "2","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "19074800","Foreign Gross": "3104683","Worldwide": "22179483","Budget": "2000000"},
  "row5": {"exclude": "","Film ": "Superbad","Major Studio": "Sony","Rotten Tomatoes": "88","Audience Score": "87","Story": "Comedy","Genre": "Comedy","Number of Theatres in Opening Weekend": "2948","Box Office Average per Cinema": "11211","Domestic Gross": "121.46","Foreign Gross": "48.41","Worldwide Gross": "169.87","Budget": "20.00","Market Profitability": "849.36%","Opening Weekend": "33","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "121463226","Foreign Gross": "48408493","Worldwide": "169871719","Budget": "20000000"},
  "row6": {"exclude": "","Film ": "The Simpsons Movie","Major Studio": "Fox","Rotten Tomatoes": "90","Audience Score": "78","Story": "Maturation","Genre": "Comedy","Number of Theatres in Opening Weekend": "3922","Box Office Average per Cinema": "18877","Domestic Gross": "183.14","Foreign Gross": "343.93","Worldwide Gross": "527.07","Budget": "75.00","Market Profitability": "702.76%","Opening Weekend": "74","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "183135014","Foreign Gross": "343932723","Worldwide": "527067737","Budget": "75000000"},
  "row7": {"exclude": "","Film ": "300","Major Studio": "Warner Bros.","Rotten Tomatoes": "60","Audience Score": "90","Story": "Sacrifice","Genre": "Action","Number of Theatres in Opening Weekend": "3103","Box Office Average per Cinema": "22844","Domestic Gross": "210.61","Foreign Gross": "245.45","Worldwide Gross": "456.07","Budget": "65.00","Market Profitability": "701.64%","Opening Weekend": "70.9","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "210614939","Foreign Gross": "245453242","Worldwide": "456068181","Budget": "65000000"},
  "row8": {"exclude": "","Film ": "The Game Plan","Major Studio": "Disney","Rotten Tomatoes": "27","Audience Score": "75","Story": "Discovery","Genre": "Comedy","Number of Theatres in Opening Weekend": "3103","Box Office Average per Cinema": "7396","Domestic Gross": "90.64","Foreign Gross": "57.23","Worldwide Gross": "147.87","Budget": "22.00","Market Profitability": "672.13%","Opening Weekend": "22.9","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "90636983","Foreign Gross": "57232341","Worldwide": "147869324","Budget": "22000000"},
  "row9": {"exclude": "","Film ": "Knocked Up","Major Studio": "Universal","Rotten Tomatoes": "91","Audience Score": "83","Story": "Love","Genre": "Comedy","Number of Theatres in Opening Weekend": "2871","Box Office Average per Cinema": "10690","Domestic Gross": "148.77","Foreign Gross": "70.23","Worldwide Gross": "219.00","Budget": "33.00","Market Profitability": "663.64%","Opening Weekend": "30.7","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "148768917","Foreign Gross": "70232344","Worldwide": "219001261","Budget": "33000000"},
  "row10": {"exclude": "","Film ": "No Country for Old Men","Major Studio": "Paramount","Rotten Tomatoes": "95","Audience Score": "84","Story": "Pursuit","Genre": "Drama","Number of Theatres in Opening Weekend": "860","Box Office Average per Cinema": "9042","Domestic Gross": "74.28","Foreign Gross": "86.72","Worldwide Gross": "161.00","Budget": "25.00","Market Profitability": "644.00%","Opening Weekend": "7.8","Oscar": "Best Picture, Director, Supporting Actor, Adapted Screenplay","Bafta": "Supporting Actor, Director","Source": "","": "","Domestic Gross": "74283625","Foreign Gross": "86715832","Worldwide": "160999457","Budget": "25000000"},
  "row11": {"exclude": "","Film ": "Harry Potter and the Order of the Phoenix","Major Studio": "Warner Bros.","Rotten Tomatoes": "78","Audience Score": "82","Story": "Quest","Genre": "Adventure","Number of Theatres in Opening Weekend": "4285","Box Office Average per Cinema": "17998","Domestic Gross": "292","Foreign Gross": "647.88","Worldwide Gross": "939.88","Budget": "150","Market Profitability": "626.59%","Opening Weekend": "77.1","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "","Foreign Gross": "","Worldwide": "","Budget": ""}
  "row12": {"exclude": "y","Film": "88 Minutes","Major Studio": "","Rotten Tomatoes": "5","Audience Score": "51","Story": "The Riddle","Genre": "Drama","Number of Theatres in Opening Weekend": "2168","Box Office Average per Cinema": "3209","Domestic Gross": "16.93","Foreign Gross": "","Worldwide Gross": "32.30","Budget ": "30.00","Market Profitability": "1.08","Opening Weekend": "7","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "16930884","Foreign Gross": "","worldwide": "32.3","Budget": "30000000","budget ": "30"},
  "row13": {"exclude": "y","Film": "Appaloosa","Major Studio": "","Rotten Tomatoes": "77","Audience Score": "55","Story": "Rescue","Genre": "Action","Number of Theatres in Opening Weekend": "","Box Office Average per Cinema": "","Domestic Gross": "20.07","Foreign Gross": "","Worldwide Gross": "25.90","Budget ": "20.00","Market Profitability": "1.30","Opening Weekend": "5","Oscar": "","Bafta": "","Source": "","": "","Domestic Gross": "20070952","Foreign Gross": "","worldwide": "25.9","Budget": "20000000","budget ": "20"},
  }

  countryData = {"row0": {" Movie Title": "Pirates of the Caribbean: At World's End","Distributor": "BVI","Gross": "$91,119,039","Release": "5/25"},
  "row1": {" Movie Title": "Harry Potter and the Order of the Phoenix","Distributor": "WB","Gross": "$80,564,009","Release": "7/20"},
  "row2": {" Movie Title": "Hero (2007)","Distributor": "Toho","Gross": "$73,109,846","Release": "9/8"},
  "row3": {" Movie Title": "Superbad","Distributor": "Sony","Gross": "$58,320,289","Release": "5/1"},
  "row4": {" Movie Title": "Gekijôban Poketto Monsutâ Daiyamondo to Pâru Diaruga Tai Parukia Tai Dâkurai (Pokémon: Diamond and Pearl) (2007)","Distributor": "Toho","Gross": "$42,238,454","Release": "7/14"},
  "row5": {" Movie Title": "Always zoku san-chôme no yûhi","Distributor": "Toho","Gross": "$42,235,940","Release": "11/3"},
  "row6": {" Movie Title": "Knocked Up","Distributor": "Universal","Gross": "$40,268,674","Release": "12/14"}
  }

  it 'can load domestic data', ->
    cnt = 0
    l = (d) =>
      expect(d.key).toEqual('us')
      expect(d.year).toEqual(2010)
      expect(d.film).toEqual('Juno') if cnt == 0
      expect(d.story).toEqual('Maturation') if cnt == 0
      expect(d.genre).toEqual('Comedy') if cnt == 0
      expect(d.film).toEqual('Saw IV') if cnt == 1
      expect(d.film).toEqual('Waitress') if cnt == 2
      expect(d.film).toEqual('Superbad') if cnt == 3
      expect(d.film).toEqual('The Simpsons Movie') if cnt == 4
      expect(d.film).toEqual('Appaloosa') if cnt == 11
      cnt++

    Extract.extractDomesticMovies(yearlyData,'us',2010,l)
    expect(cnt).toEqual(12)

  it 'can load country data', ->
    l = (d) => Movie.create({title: d.film, year:d.year, story:d.story,genre:d.genre,country:null})
    Extract.extractDomesticMovies(yearlyData,'us',2007,l)

    results = Extract.extractCountrySummary(countryData,Movie,'japan',2007)
    expect(results.key).toEqual('japan')
    expect(results.year).toEqual(2007)
    expect(results.otherfilms).toEqual(4)
    expect(results.hollywoodfilms).toEqual(3)
    expect(results.oldhollywoodfilms).toEqual(0)
