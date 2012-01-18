require = window.require
Spine = require 'spine'
Spine.Model.Ajax = {}

describe 'Country', ->
  Country = null
  
  beforeEach ->
    class Country extends Spine.Model
      @configure 'Country'
  
  it 'can noop', ->
    
