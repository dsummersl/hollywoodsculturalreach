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

  @sprintmoney: (m) ->
    return $.sprintf('$%.1f bil',m/1000) if m > 1000
    return $.sprintf('$%.1f mil',m)


module.exports = Appdata
