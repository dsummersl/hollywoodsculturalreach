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
      <div class="gb-tier" id="gb-row2">
        <div id="gb-genre-hollywood">hollywood</div>
        <div id="gb-genre-hollywood-totals" class="gb-comment">comment</div>
      </div>
      <div class="gb-tier" id="gb-row3">
        <div id="gb-genre-nothollywood">not hollywood</div>
        <div id="gb-genre-nothollywood-totals" class="gb-comment">comment</div>
      </div>
    </div>
    """)

  genretext: (winner) ->
    return """
      <center><h4>#{winner[0]}</h4></center>
      <div class="gb-winner">#{@makeMovieText(winner[1])}</div>
    """

  otherstext: (description,list,height) ->
    return """
      <h4>#{description}</h4>
      <div class="gb-bulk" height="#{height}px">#{@makeMovieText(list)}</div>
    """

  makeMovieText: (list) ->
    hs = []
    for s in list
      m = s.movie()
      hs.push "<a class='ds-movie' data-original-title=\"#{m.title} <small>#{m.year} (#{m.genre})</small>\" movie-id='#{m.id}'>#{m.title}</a>"
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


    $('#gb-genre1').html('')
    $('#gb-genre2').html('')
    $('#gb-genre3').html('')

    maxHeight = 400
    minHeight = 40
    genres = {}
    unknowns = []
    total = 0
    for s in constrained
      m = s.movie()
      total++
      if m.hollywood
        genres[m.genre] = [] if not genres[m.genre]?
        genres[m.genre].push s
      else
        unknowns.push s

    genre1 = @extractBiggest(genres)
    genre2 = @extractBiggest(genres)
    genre3 = @extractBiggest(genres)
    ###
    genre4 = @extractBiggest(genres)
    genre5 = @extractBiggest(genres)
    genre6 = @extractBiggest(genres)
    ###
    # TODO would like to do the top 6 genres - then just lump the rest of the movies together
    $('#gb-genre1').html(@genretext(genre1)) if genre1?
    $('#gb-genre2').html(@genretext(genre2)) if genre2?
    $('#gb-genre3').html(@genretext(genre3)) if genre3?
    allwinners = []
    allwinners = allwinners.concat genre1[1] if genre1?
    allwinners = allwinners.concat genre2[1] if genre2?
    allwinners = allwinners.concat genre3[1] if genre3?
    $('#gb-genre-totals').html(@makeComments(allwinners,total))

    rest = []
    rest = rest.concat(v) for k,v of genres

    #row1height = parseInt(allwinners.length/total*400)
    row1height = 60
    row2height = Math.max(minHeight,parseInt(d3.sum(v.length for k,v of genres)/total*400))
    row3height = Math.max(minHeight,parseInt(unknowns.length/total*400))

    $('#gb-genre-hollywood').html(@otherstext('Hollywood',rest,row2height))
    $('#gb-genre-hollywood-totals').html(@makeComments(rest,total))

    $('#gb-genre-nothollywood').html(@otherstext('Not Hollywood',unknowns,row3height))
    $('#gb-genre-nothollywood-totals').html(@makeComments(unknowns,total))

    $('.gb-winner').css('height', "#{row1height}px")
    $('#gb-genre-hollywood .gb-bulk').css('height', "#{row2height}px")
    $('#gb-genre-nothollywood .gb-bulk').css('height', "#{row3height}px")
    $('#gb-genre-hollywood .gb-bulk').css('background', "#eee")
    $('#gb-genre-nothollywood .gb-bulk').css('background', "#ccc")


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
