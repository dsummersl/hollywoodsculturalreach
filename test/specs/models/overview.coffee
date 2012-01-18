describe 'Overview', ->
  Overview = null
  
  beforeEach ->
    class Overview extends Spine.Model
      @configure 'Overview'
  
  it 'can noop', ->
    