###
spider.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
DICT = []
PAGES = []
OLDS = []
KEYWORDS = {}
DATA =
  dict: []
  pages: []

IGNORED = [
  'the'
  'an'
  'of'
  'then'
]
addStr = (s)->
  if s of KEYWORDS
    KEYWORDS[s]++
  else
    KEYWORDS[s] = 1

count = (url, title, html)->
  w = /\w+/
  page =
    url: url
    title: title
    set: new Set()
  notInPages = true
  for p in DATA.pages
    if p.url == url
      page = p
      notInPage = false
  for s in html.split(/\W+/)
    if s and w.test(s)
      for k, v of KEYWORDS
        if s == k
          page.set.add(v)
          break
  for k, v of KEYWORDS
    if html.indexOf(k) >= 0
      page.set.add(v)
  if notInPages
    DATA.pages.push page

read = (html)->
  w = /\w+/
  for d in DICT
    if d and html.indexOf(d)>=0
      addStr(d)
  for s in html.split(/\W+/)
    if s and w.test(s)
      addStr(s.toLowerCase())
  1

inPages = (url, pages=PAGES)->
  for p in pages
    if url == p.url
      return true
  false

secan =(find=true) ->
  if PAGES.length > 0
    url = PAGES.pop()
    if url
      OLDS.push url
      $('#pages').val(JSON.stringify(OLDS))
      div = $('<div></div>')
      h = div.load(url.url, (html)->
        read($(this).text())
        if find
          $(this).contents('a').each((i, a)->
            al = $(a)
            href = al.attr('href')
            if href and (not (':' in href)) and (not inPages(href)) and (not inPages(href, OLDS))
              PAGES.push
                url: href
                title: al.text()
              secan(find)
          )
      )
    secan(find)

$ ->
  $('#load').click(->
    $.get($('#dict').val(), (txt)->
      DICT = txt.split('\n')
      $('#dict_size').text(DICT.length)
    )
  )
  $('#scan').click(->
    PAGES = JSON.parse($('#pages').val())
    if DICT.length > 0 or confirm('Ignore CJK Dictionary?')
      OLDS = []
      secan()
      $('#count').attr("disabled",false)
      $('#resecan').attr("disabled",false)
  )

  $('#resecan').click(->
    OLDS = []
    PAGES = JSON.parse($('#pages').val())
    KEYWORDS={}
    secan(false)
  )

  $('#count').click(->
    temp = []
    for k,v of KEYWORDS
      temp.push(
        k:k
        v:v
      )
    DATA.dict = []
    for t in temp.sort((a, b)->
      b.v - a.v
    )
      if t.k not in IGNORED
        DATA.dict.push(t.k)
    $('#keywords').val(JSON.stringify(DATA.dict))
    $('#builder').attr("disabled",false)
  )

  $('#builder').click(->
    for d, i in DATA.dict
      KEYWORDS[d] = i
    for p in OLDS
      div = $("<div data-url='#{p.url}' data-title='#{p.title}'></div>")
      h = div.load(p.url, (html)->
        count($(this).attr('data-url'), $(this).attr('data-title'), $(this).text())
      )
    $('#download').attr("disabled",false)
  )

  $('#download').click(->
    for d in DATA.pages
      d['set'] = d['set']['set']
    a = $("<a download='mse.json' href='data:text/plain,#{JSON.stringify(DATA)}'></a>")
    evt = document.createEvent("HTMLEvents")
    evt.initEvent("click", false, false)
    a[0].dispatchEvent(evt)
  )

