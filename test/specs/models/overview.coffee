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
    c.showings().create({year:2010,other:1,hollywood:2,oldhollywood:3})
    c.showings().create({year:2011,other:1,hollywood:4,oldhollywood:0})
    c2 = Country.create({name: 'test2',region:'everywhere',key:'test2'})
    c2.showings().create({year:2010,other:1,hollywood:2,oldhollywood:8})
    c3 = Country.create({name: 'test3',region:'everywhere',key:'test3'})
    #jasmine.log "the dat looks like #{JSON.stringify(Overview.all())}"
    #jasmine.log "c2 looks like #{JSON.stringify(c2.overviews())}"
    #jasmine.log "c3 looks like #{JSON.stringify(c3.overviews())}"
    #jasmine.log "c2 looks like #{JSON.stringify(c2.overviews().findByAttribute('year',2010))}"

    expect(Overview.totalHollyWoodRatio(c.overviews())).toEqual(9)
    expect(Overview.totalHollyWoodRatio(c.overviews(),2009)).toEqual(0)
    expect(Overview.totalHollyWoodRatio(c.overviews(),2010)).toEqual(5)
    expect(Overview.totalHollyWoodRatio(c.overviews(),2011)).toEqual(4)
    expect(Overview.totalHollyWoodRatio(c2.overviews())).toEqual(10)
    expect(Overview.totalHollyWoodRatio(c2.overviews(),2009)).toEqual(0)
    expect(Overview.totalHollyWoodRatio(c2.overviews(),2010)).toEqual(10)
    expect(Overview.totalHollyWoodRatio(c3.overviews())).toEqual(0)

    # TODO neither of these work b/c of the result is not a 'collection'
    #expect(Overview.totalHollyWoodRatio(c.overviews().select((d)=>d.year == 2010))).toEqual(5)
    #expect(Overview.totalHollyWoodRatio(c.overviews().findByAttribute('year',2010))).toEqual(5)
