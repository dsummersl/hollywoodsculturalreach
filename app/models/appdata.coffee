Spine = require('spine')

class Appdata extends Spine.Model
  @configure 'Appdata','data'

  @set: (k,v) ->
    el = @first()
    el = @create({data: {}}) if not el
    el.data[k] = v
    el.save()
    return null

  @get: (k) ->
    el = @first()
    el = @create({data: {}}) if not el
    return el.data[k]

module.exports = Appdata
