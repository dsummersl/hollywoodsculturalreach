require = window.require
Spine = require 'spine'
Spine.Model.Ajax = {}
Country = require('models/country')
Overview = require('models/overview')
Movieshowing = require('models/movieshowing')
Movie = require('models/movie')
Appdata = require('models/appdata')

describe 'Overview', ->
  usa = Country.create({name: 'United States',region:'everywhere',key:'unitedstates'})
  usa.overviews().create({year:2010,genre:'Unknown', other:1,hollywood:2,oldhollywood:3,othermoney:1,hollywoodmoney:20,oldhollywoodmoney:15})
  usa.overviews().create({year:2010,genre:'Comedy', other:2,hollywood:3,oldhollywood:4,othermoney:2,hollywoodmoney:30,oldhollywoodmoney:15})
  usa.overviews().create({year:2011,genre:'Unknown', other:1,hollywood:4,oldhollywood:0,othermoney:1,hollywoodmoney:40,oldhollywoodmoney:0})
  m = Movie.create({title: 'one', hollywood: true, year:2008, story:'Unknown',genre:'Unknown',distributor:'Unknown'})
  ms = usa.showings().create({year:2008, boxoffice:15.5, movie_id:m.id})

  c2 = Country.create({name: 'test2',region:'everywhere',key:'test2'})
  c2.overviews().create({year:2010,genre:'Unknown', other:1,hollywood:2,oldhollywood:8,othermoney:1,hollywoodmoney:20,oldhollywoodmoney:40})

  c3 = Country.create({name: 'test3',region:'everywhere',key:'test3'})

  it 'can compute totalHollyWoodRatio', ->
    #jasmine.log "the dat looks like #{JSON.stringify(Overview.all())}"
    #jasmine.log "c2 looks like #{JSON.stringify(c2.overviews())}"
    #jasmine.log "c3 looks like #{JSON.stringify(c3.overviews())}"
    #jasmine.log "c2 looks like #{JSON.stringify(c2.overviews().findByAttribute('year',2010))}"

    expect(Overview.totalHollyWoodRatio(usa)).toEqual(16 / 20)
    expect(Overview.totalHollyWoodRatio(usa,{year: 2009})).toEqual(0)
    expect(Overview.totalHollyWoodRatio(usa,{year: 2010})).toEqual(12 / 15)
    expect(Overview.totalHollyWoodRatio(usa,{year: 2010, genre: null})).toEqual(12 / 15)
    expect(Overview.totalHollyWoodRatio(usa,{year: 2010, genre: 'Unknown'})).toEqual(5 / 6)
    expect(Overview.totalHollyWoodRatio(usa,{year: null, genre: 'Unknown'})).toEqual(9 / 11)
    expect(Overview.totalHollyWoodRatio(usa,{year: 2011})).toEqual(4 / 5)
    expect(Overview.totalHollyWoodRatio(c2)).toEqual(10 / 11)
    expect(Overview.totalHollyWoodRatio(c2,{year: 2009})).toEqual(0)
    expect(Overview.totalHollyWoodRatio(c2,{year: 2010})).toEqual(10 / 11)
    expect(Overview.totalHollyWoodRatio(c3)).toEqual(0)

  it 'can compute the totalRevenueRatio', ->
    expect(Overview.totalRevenueRatio(usa)).toEqual((90+30)/(90+30+4))
    expect(Overview.totalRevenueRatio(usa,{year: 2009})).toEqual(0)
    expect(Overview.totalRevenueRatio(usa,{year: 2010})).toEqual((50+30) / (50+30+3))
    expect(Overview.totalRevenueRatio(usa,{year: 2010, genre: null})).toEqual((50+30) / (50+30+3))
    expect(Overview.totalRevenueRatio(usa,{year: 2010, genre: 'Unknown'})).toEqual((20+15) / (20+15+1))
    expect(Overview.totalRevenueRatio(usa,{year: null, genre: 'Unknown'})).toEqual((60+15) / (60+15+2))
    expect(Overview.totalRevenueRatio(usa,{year: 2011})).toEqual((40) / (40+1))
    ###
    expect(Overview.totalRevenueRatio(c2)).toEqual(10 / 11)
    expect(Overview.totalRevenueRatio(c2,{year: 2009})).toEqual(0)
    expect(Overview.totalRevenueRatio(c2,{year: 2010})).toEqual(10 / 11)
    expect(Overview.totalRevenueRatio(c3)).toEqual(0)
    ###

  it 'constrains properly', ->
    expect(Overview.getConstraints()).toEqual({year: null})
    Appdata.set('genres','Unknown')
    expect(Overview.getConstraints()).toEqual({year: null, genre: 'Unknown'})
    expect(Overview.filter(usa.showings(),Overview.getConstraints()).length).toEqual(1)
