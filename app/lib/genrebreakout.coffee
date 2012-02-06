Spine = require('spine')
Overview = require 'models/overview'
Appdata = require 'models/appdata'

class Genrebreakout
  constructor: (id) ->
    $(id).append("""
    <h3>Top Genres</h3>
    <div class="gb-tier">
      <div class="gb-tier" id="gb-row1">
        <div id="gb-genre1" class="gb-col">one</div>
        <div id="gb-genre2" class="gb-col">two</div>
        <div id="gb-genre3" class="gb-col">three</div>
        <div id="gb-genre-totals" class="gb-comment">comment</div>
      </div>
      <div class="gb-tier" id="gb-row1">
        <div id="gb-genre4" class="gb-col">one</div>
        <div id="gb-genre5" class="gb-col">two</div>
        <div id="gb-genre6" class="gb-col">three</div>
        <div id="gb-genre2-totals" class="gb-comment">comment</div>
      </div>
    </div>
    """)

  genretext: (winner) ->
    if winner?
      return """
        <center><h4>#{winner[0]}</h4></center>
        <div class="gb-winner">#{@makeMovieText(winner[1])}</div>
      """
    else
      return """
        <center><h4>...</h4></center>
        <div class="gb-winner"></div>
      """

  makeMovieText: (list) ->
    hs = []
    for s in list
      m = s.movie()
      hs.push "<a class='ds-movie' data-original-title=\"#{m.title} <small>#{m.year} (#{m.genre})</small>\" ms-id='#{s.id}'>#{m.title}</a>"
    return hs.join("<span class='ds-dash'> &mdash; </span>")

  makeComments: (list,total) ->
    totalRevenue = 0
    totalRevenue += s.boxoffice for s in list
    percent = list.length / total
    return """
    <b>Total:</b><br/>
    #{Appdata.sprintmoney(totalRevenue)} <br/>
    (#{$.sprintf('%.1f',percent*100)}%)
    """

  refresh: (constrained) =>
    $('#gb-genre1').html(@genretext(null))
    $('#gb-genre2').html(@genretext(null))
    $('#gb-genre3').html(@genretext(null))
    $('#gb-genre4').html(@genretext(null))
    $('#gb-genre5').html(@genretext(null))
    $('#gb-genre6').html(@genretext(null))

    genres = {}
    total = 0
    for s in constrained
      m = s.movie()
      total++
      if m.hollywood
        genres[m.genre] = [] if not genres[m.genre]?
        genres[m.genre].push s

    genre1 = @extractBiggest(genres)
    genre2 = @extractBiggest(genres)
    genre3 = @extractBiggest(genres)
    genre4 = @extractBiggest(genres)
    genre5 = @extractBiggest(genres)
    genre6 = @extractBiggest(genres)
    $('#gb-genre1').html(@genretext(genre1)) if genre1?
    $('#gb-genre2').html(@genretext(genre2)) if genre2?
    $('#gb-genre3').html(@genretext(genre3)) if genre3?
    $('#gb-genre4').html(@genretext(genre4)) if genre4?
    $('#gb-genre5').html(@genretext(genre5)) if genre5?
    $('#gb-genre6').html(@genretext(genre6)) if genre6?
    allwinners = []
    allwinners = allwinners.concat genre1[1] if genre1?
    allwinners = allwinners.concat genre2[1] if genre2?
    allwinners = allwinners.concat genre3[1] if genre3?
    $('#gb-genre-totals').html(@makeComments(allwinners,total))
    allwinners = []
    allwinners = allwinners.concat genre4[1] if genre4?
    allwinners = allwinners.concat genre5[1] if genre5?
    allwinners = allwinners.concat genre6[1] if genre6?
    $('#gb-genre2-totals').html(@makeComments(allwinners,total))

    rowheight = 200
    $('.gb-winner').css('height', "#{rowheight}px")


  # extract a key from the map, and return the key if there is a biggest.
  # otherwise return null
  extractBiggest: (map)->
    # TODO something isn't right here b/c there are lots of comedies and I'm not seeing them here.
    sizes = {}
    sizes[k] = v.length for k,v of map
    max = 0
    biggest = null
    val = null
    for k,v of sizes when v > max
      biggest = k
      val = map[biggest]
      max = v
    delete map[biggest] if biggest?
    return [biggest,val] if biggest?
    return null

module.exports = Genrebreakout
