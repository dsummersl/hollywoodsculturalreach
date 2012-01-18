describe 'Country', ->
  Country = null
  
  beforeEach ->
    class Country extends Spine.Model
      @configure 'Country'
  
  it 'can noop', ->
    