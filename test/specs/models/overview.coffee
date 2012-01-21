require = window.require
Spine = require 'spine'
Spine.Model.Ajax = {}
Country = require('models/country')
Overview = require('models/overview')

describe 'Overview', ->
  beforeEach ->
    Overview.deleteAll()
    Country.deleteAll()
  
  it 'can compute totalHollyWoodRatio', ->
    c = Country.create({name: 'test',region:'everywhere',key:'test'})
    c.overviews().create({year:2010,other:1,hollywood:2,oldhollywood:3})
    c.overviews().create({year:2011,other:1,hollywood:4,oldhollywood:0})
    c2 = Country.create({name: 'test2',region:'everywhere',key:'test2'})
    c2.overviews().create({year:2010,other:1,hollywood:2,oldhollywood:8})
    c3 = Country.create({name: 'test3',region:'everywhere',key:'test3'})
    expect(Overview.totalHollyWoodRatio(c.overviews())).toEqual(9)
    expect(Overview.totalHollyWoodRatio(c2.overviews())).toEqual(10)
    expect(Overview.totalHollyWoodRatio(c3.overviews())).toEqual(0)
    # TODO neither of these work b/c of the result is not a 'collection'
    #expect(Overview.totalHollyWoodRatio(c.overviews().select((d)=>d.year == 2010))).toEqual(5)
    #expect(Overview.totalHollyWoodRatio(c.overviews().findByAttribute('year',2010))).toEqual(5)
