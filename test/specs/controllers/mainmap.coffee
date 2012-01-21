require = window.require

describe 'Mainmap', ->
  require('d3/d3')
  Mainmap = require('controllers/mainmap')

  it 'can find min and max keys', ->
    mm = new Mainmap()
    expect(mm.findMaxKey(null)).toEqual(null)
    expect(mm.findMinKey(null)).toEqual(null)
    expect(mm.findMaxKey({})).toEqual(null)
    expect(mm.findMinKey({})).toEqual(null)
    data =
      one: 1
      two: 2
      three: 3
      four: 4
    expect(mm.findMaxKey(data)).toEqual('four')
    expect(mm.findMinKey(data)).toEqual('one')
