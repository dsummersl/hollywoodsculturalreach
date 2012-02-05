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
    colors: (data) =>
      colors = ['#bbd3f9','#f1ee9c'] # 217, 58
      max = 0
      max = v for k,v of data when v > max
      return d3.scale.linear().domain([0,max]).range(colors)
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
    colors: (data) =>
      colors = ['#bbbef9','#d7f19c'] # 237, 78
      max = 0
      max = v for k,v of data when v > max
      return d3.scale.linear().domain([0,max]).range(colors)
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
    extendeddesc: ' colored by total revenue of movies shown in each country.'
    colors: (data) =>
      colors = ['#cdbbf9','#bbf19c'] # 257, 98
      max = 0
      max = v for k,v of data when v > max
      return d3.scale.linear().domain([0,max]).range(colors)
    formatData: (d) -> Appdata.sprintmoney(d)
  othervshollywood:
    compute: =>
      data = {}
      for c in Country.all()
        sum = 0
        sum += (o.hollywoodmoney + o.oldhollywoodmoney) - o.othermoney for o in Overview.filter(c.overviews(),Overview.getConstraints())
        data[c.key] = sum
      Appdata.set('measuredata',data)
    desc: 'Hollywood - Others'
    extendeddesc: ' colored by the difference of Hollywood and non-Hollywood movie revenue for movies shown in each country.'
    colors: (data) =>
      colors = ['#e1bbf9','#9ff19c'] # 277,118
      min = 0
      min = v for k,v of data when v < min
      max = 0
      max = v for k,v of data when v > max
      poscolors = d3.scale.linear().domain([0,max]).range([colors[0],d3.rgb(colors[0]).darker().toString()])
      negcolors = d3.scale.linear().domain([min,0]).range([d3.rgb(colors[1]).darker().toString(),colors[1]])
      return (d) =>
        return poscolors(d) if d >=0
        return negcolors(d)
    formatData: (d) -> Appdata.sprintmoney(d)
  ###
    #colors: ['#f6bbf9','#9cf1b6'] # 297,138
    #colors: ['#......','#9cf1d2'] # ???,158
  ###

module.exports = measures
