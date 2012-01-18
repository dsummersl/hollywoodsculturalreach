Spine = require('spine')

class Overview extends Spine.Model
  @configure 'Overview', 'year', ''
  @belongsTo 'country', 'models/country'
  
module.exports = Overview
