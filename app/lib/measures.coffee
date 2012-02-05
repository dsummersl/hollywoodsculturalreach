Appdata = require 'models/appdata'
Country = require 'models/country'
Overview = require 'models/overview'

measures =
  # TODO of all the hollywood movies, what percent played in the foreign country?
  countmovies:
    compute: =>
      data = {}
      for c in Country.all()
        sum = 0
        sum += o.other + o.hollywood + o.oldhollywood for o in Overview.filter(c.overviews(),Overview.getConstraints())
        data[c.key] = sum
      Appdata.set('measuredata',data)
    desc: '# Movies'
    extendeddesc: ' colored by total # movies shown in each country.'
    colors: ['#bbd3f9','#f1ee9c'] # 217, 58
    formatData: (d) -> $.sprintf('%d',d)
  counthollywoodmovies:
    compute: =>
      data = {}
      for c in Country.all()
        sum = 0
        sum += o.hollywood + o.oldhollywood for o in Overview.filter(c.overviews(),Overview.getConstraints())
        data[c.key] = sum
      Appdata.set('measuredata',data)
    desc: '# Hollywood Movies'
    extendeddesc: ' colored by total # Hollywood movies shown in each country.'
    colors: ['#bbbef9','#d7f19c'] # 237, 78
    formatData: (d) -> $.sprintf('%d',d)
  movierevenue:
    compute: =>
      data = {}
      for c in Country.all()
        sum = 0
        sum += o.othermoney + o.hollywoodmoney + o.oldhollywoodmoney for o in Overview.filter(c.overviews(),Overview.getConstraints())
        data[c.key] = sum
      Appdata.set('measuredata',data)
    desc: 'Movie Revenue'
    extendeddesc: ' colored by total revenue for movies shown in each country.'
    colors: ['#cdbbf9','#bbf19c'] # 257, 98
    formatData: (d) -> Appdata.sprintmoney(d)
  ###
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
