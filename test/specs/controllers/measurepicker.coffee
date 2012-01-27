require = window.require
Spine = require 'spine'
Spine.Model.Ajax = {}

describe 'Measurepicker', ->
  Measurepicker = require('controllers/measurepicker')
  
  it 'can noop', ->
    
