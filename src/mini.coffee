###
mini.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###

class Mini
  constructor: (config)->
    @dict = config.dict
    @pages = config.pages
    for p, i in @pages
      if p.set instanceof Array
        np = new Set()
        np.set = p.set
        @pages[i].set = np

  search: (kw, cb)=>
    searchSet = new Set()
    w = /\w+/
    nw = /\W+/
    for s in kw.split(w)
      for d, i in @dict
        if nw.test(d)
          if s.indexOf(d) >= 0
            searchSet.add(i)
            break
    for s in kw.split(nw)
      if s and w.test(s)
        for d, i in @dict
          if s.toLowerCase() == d
            searchSet.add(i)
            break
    ret = []
    if searchSet.set.length == 0
      cb(ret)
      return
    for p in @pages
      if p.set.in(searchSet.set)
        ret.push p
    cb(ret)

MSE = null

search = (kw, cb)->
  if MSE
    MSE.search(kw, cb)
  else
    $.getJSON('/mse.json', (config)->
      MSE = new Mini(config)
      MSE.search(kw, cb)
    )

