Spine = require('spine')

class Appdata extends Spine.Model
  @configure 'Appdata','key','data'

  @set: (k,v) ->
    el = @findByAttribute('key',k)
    el = @create({key: k, data: v}) if not el
    el.data = v
    el.save()
    return null

  @get: (k) -> @findByAttribute('key',k)?.data

module.exports = Appdata
