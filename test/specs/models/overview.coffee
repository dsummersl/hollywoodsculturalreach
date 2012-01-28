require = window.require
Spine = require 'spine'
Spine.Model.Ajax = {}
Country = require('models/country')
Overview = require('models/overview')
Movieshowing = require('models/movieshowing')

describe 'Overview', ->
  beforeEach ->
    Overview.deleteAll()
    Country.deleteAll()
  
  it 'can compute totalHollyWoodRatio', ->
    c = Country.create({name: 'test',region:'everywhere',key:'test'})
    c.overviews().create({year:2010,genre:'Unknown', other:1,hollywood:2,oldhollywood:3,othermoney:0,hollywoodmoney:0,oldhollywoodmoney:0})
    c.overviews().create({year:2010,genre:'Comedy', other:2,hollywood:3,oldhollywood:4,othermoney:0,hollywoodmoney:0,oldhollywoodmoney:0})
    c.overviews().create({year:2011,genre:'Unknown', other:1,hollywood:4,oldhollywood:0,othermoney:0,hollywoodmoney:0,oldhollywoodmoney:0})
    c2 = Country.create({name: 'test2',region:'everywhere',key:'test2'})
    c2.overviews().create({year:2010,genre:'Unknown', other:1,hollywood:2,oldhollywood:8,othermoney:0,hollywoodmoney:0,oldhollywoodmoney:0})
    c3 = Country.create({name: 'test3',region:'everywhere',key:'test3'})
    #jasmine.log "the dat looks like #{JSON.stringify(Overview.all())}"
    #jasmine.log "c2 looks like #{JSON.stringify(c2.overviews())}"
    #jasmine.log "c3 looks like #{JSON.stringify(c3.overviews())}"
    #jasmine.log "c2 looks like #{JSON.stringify(c2.overviews().findByAttribute('year',2010))}"

    expect(Overview.totalHollyWoodRatio(c)).toEqual(16 / 20)
    expect(Overview.totalHollyWoodRatio(c,{year: 2009})).toEqual(0)
    expect(Overview.totalHollyWoodRatio(c,{year: 2010})).toEqual(12 / 15)
    expect(Overview.totalHollyWoodRatio(c,{year: 2010, genre: NaN})).toEqual(12 / 15)
    expect(Overview.totalHollyWoodRatio(c,{year: 2010, genre: null})).toEqual(12 / 15)
    expect(Overview.totalHollyWoodRatio(c,{year: 2010, genre: 'Unknown'})).toEqual(12 / 15)
    expect(Overview.totalHollyWoodRatio(c,{year: null, genre: 'Unknown'})).toEqual(16 / 20)
    expect(Overview.totalHollyWoodRatio(c,{year: 2011})).toEqual(4 / 5)
    expect(Overview.totalHollyWoodRatio(c2)).toEqual(10 / 11)
    expect(Overview.totalHollyWoodRatio(c2,{year: 2009})).toEqual(0)
    expect(Overview.totalHollyWoodRatio(c2,{year: 2010})).toEqual(10 / 11)
    expect(Overview.totalHollyWoodRatio(c3)).toEqual(0)
