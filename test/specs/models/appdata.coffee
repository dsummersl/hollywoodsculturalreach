require = window.require
Spine = require('spine')
Spine.Model.Ajax = {}

describe 'Appdata', ->
  Appdata = require('models/appdata')

  it 'can set and get', ->
    expect(Appdata.get('one')).toEqual(null)
    Appdata.set('one',1)
    expect(Appdata.get('one')).toEqual(1)

