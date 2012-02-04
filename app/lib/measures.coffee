Appdata = require 'models/appdata'
Country = require 'models/country'
Overview = require 'models/overview'

measures =
  # TODO of all the hollywood movies, what percent played in the foreign country?
  #desc: '% Hollywood Movies'
  percentcounthollywood: # the percent of # of movies that are hollywood movies
    compute: =>
      data = {}
      data[c.key] = Overview.totalHollyWoodRatio(c,Overview.getConstraints()) for c in Country.all()
      #@log "DATA = #{JSON.stringify(data)}"
      Appdata.set('measuredata',data)
    desc: '% Hollywood Movies'
    extendeddesc: 'colored by # Hollywood movies in county\'s theatres / # movies shown the country'
    colors: ['#bbd3f9','#f1ee9c'] # 217, 58
  percentmoneyhollywood: # the percent of box office $s that are from hollywood movies
    compute: =>
      data = {}
      data[c.key] = Overview.totalRevenueRatio(c,Overview.getConstraints()) for c in Country.all()
      Appdata.set('measuredata',data)
    desc: '% Revenue Hollywood Movies'
    extendeddesc: 'colored by the revenue percentage shown in each country\'s theatres.'
    colors: ['#bbbef9','#d7f19c'] # 237, 78
  ###
  percentcounthollywoodincountry: # the percent of # of movies that are hollywood movies vs all countries movies
    compute: =>
      data = {}
      year = null
      year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'all'
      genre = Appdata.get('genres') if Appdata.get('genres') and Appdata.get('genres') != 'All'
      #@log "filtering by #{year} and #{genre}"
      data[c.key] = Overview.totalHollyWoodRatio(c,{year:year,genre:genre}) for c in Country.all()
      #@log "DATA = #{JSON.stringify(data)}"
      Appdata.set('measuredata',data)
    desc: '% Hollywood Movies'
    extendeddesc: 'colored by # Hollywood movies in county\'s theatres / # movies shown the country'
    colors: ['#cdbbf9','#bbf19c'] # 257, 98
  percentmoneyhollywoodincountry: # the percent of box office $s that are from hollywood movies vs all countries movies
    compute: =>
      data = {}
      year = null
      year = parseInt(Appdata.get('years')) if Appdata.get('years') and Appdata.get('years') != 'All'
      genre = Appdata.get('genres') if Appdata.get('genres') and Appdata.get('genres') != 'All'
      data[c.key] = Overview.totalRevenueRatio(c,{year:year,genre:genre}) for c in Country.all()
      Appdata.set('measuredata',data)
    desc: '% Revenue Hollywood Movies'
    extendeddesc: 'colored by the revenue percentage shown in each country\'s theatres.'
    colors: ['#cdbbf9','#9ff19c'] # 257,118
    #colors: ['#e1bbf9','#9cf1b6'] # 277,138
    #colors: ['#f6bbf9','#9cf1d2'] # 297,158
  ###

module.exports = measures
