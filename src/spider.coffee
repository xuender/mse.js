###
spider.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
DICT = []
URLS = []
OLDS = []
STRS = {}
DATA =
  dict: []
  urls: {}
addStr = (s)->
  if s of STRS
    STRS[s]++
  else
    STRS[s] = 1

count = (url, html)->
  console.info url
  w = /\w+/
  for s in html.split(/\W+/)
    if s and w.test(s)
      for k, v of STRS
        if s == k
          # TODO 计算集合
          DATA.urls[url] = v
          break
    else
      for k, v of STRS
        if s.indexOf(k) >= 0
          # TODO 计算集合
          DATA.urls[url] = v
          break

read = (html)->
  w = /\w+/
  for d in DICT
    if d and html.indexOf(d)>=0
      addStr(d)
  for s in html.split(/\W+/)
    if s and w.test(s)
      addStr(s.toLowerCase())
  1

secan = ->
  if URLS.length > 0
    url = $.trim(URLS.pop())
    if url
      OLDS.push url
      $('#urls').val(OLDS.join('\n'))
      div = $('<div></div>')
      h = div.load(url, (html)->
        read($(this).text())
        $(this).contents('a').each((i, a)->
          href = $(a).attr('href')
          if href and (not (':' in href)) and (not (href in URLS)) and (not (href in OLDS))
            URLS.push href
            secan()
        )
      )
    secan()

$ ->
  $('#read').click(->
    $.get($('#dict').val(), (txt)->
      DICT = txt.split('\n')
      $('#dict_size').text(DICT.length)
    )
  )
  $('#scan').click(->
    URLS = $('#urls').val().split('\n')
    if DICT.length > 0 or confirm('Ignore CJK Dictionary?')
      OLDS = []
      secan()
      $('#count').attr("disabled",false)
  )
  $('#count').click(->
    $('#download').attr("disabled",false)
    temp = []
    for k,v of STRS
      temp.push(
        k:k
        v:v
      )
    DATA.dict = []
    for t in temp.sort((a, b)->
      b.v - a.v
    )
      DATA.dict.push(t.k)
    for d, i in DATA.dict
      STRS[d] = i
    for url in OLDS
      div = $("<div data-url=#{url}></div>")
      h = div.load(url, (html)->
        count($(this).attr('data-url'), $(this).text())
      )
  )
  $('#download').click(->
    a = $("<a download='mse.json' href='data:text/plain,#{JSON.stringify(DATA)}'></a>")
    evt = document.createEvent("HTMLEvents")
    evt.initEvent("click", false, false)
    a[0].dispatchEvent(evt)
  )

