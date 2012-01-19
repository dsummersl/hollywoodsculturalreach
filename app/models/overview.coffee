Spine = require('spine')
Country = require('models/country')

require 'spine/lib/relation' # just a little something I seem to need to do Cakefile(see makeJSON) relations...

class Overview extends Spine.Model
  @configure 'Overview', 'year', 'other', 'hollywood', 'oldhollywood'
  @belongsTo 'country', Country
  
module.exports = Overview
