###
spider.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
DICT = []
PAGES = []
OLDS = []
TEMP = []
KEYWORDS = {}
DATA =
  dict: []
  pages: []

IGNORED = [
  'be'
  'a'
  'to'
  'for'
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
  console.info 'count:',url

read = (html)->
  w = /\w+/
  for d in DICT
    if d and html.indexOf(d)>=0
      addStr(d)
  for s in html.split(/\W+/)
    if s and w.test(s)
      addStr(s.toLowerCase())
  1

addPage = (url)->
  if ':' in url
    return
  for p in TEMP
    if url == p.url
      return
  for p in OLDS
    if url == p.url
      return
  for p in PAGES
    if url == p.url
      return
  PAGES.push
    url: url
    title: ''

scan = (find=true) ->
  if PAGES.length > 0
    page= PAGES.pop()
    if page.url
      TEMP.push page
      div = $("<div></div>")
      div.data('page', page)
      h = div.load(page.url, (html, status)->
        if status !='success'
          return
        $(this).find('script').remove()
        read($(this).text())
        page = $(this).data('page')
        console.info 'read:',page.url
        page['title'] = $(this).find('title').text()
        if page
          OLDS.push page
          $('#pages').val(JSON.stringify(OLDS))
        if not find
          return
        $(this).find('a').each((i, a)->
          al = $(a)
          href = Mini.getUrl(page.url, al.attr('href'))
          if href
            addPage(href)
            scan(find)
        )
      )
    scan(find)

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
      TEMP = []
      scan()
      $('#count').attr("disabled",false)
      $('#rescan').attr("disabled",false)
  )

  $('#rescan').click(->
    OLDS = []
    TEMP = []
    PAGES = JSON.parse($('#pages').val())
    KEYWORDS={}
    scan(false)
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
      div = $("<div></div>")
      div.data('page', p)
      h = div.load(p.url, (html)->
        $(this).find('script').remove()
        page = $(this).data('page')
        count(page.url, page.title, $(this).text())
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

