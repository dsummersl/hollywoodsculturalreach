Spine = require('spine')
Country = require('models/country')

class Overview extends Spine.Model
  @configure 'Overview', 'year', ''
  @belongsTo 'country', Country
  
module.exports = Overview
