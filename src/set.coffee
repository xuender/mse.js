###
set.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
class Set
  constructor: (@arr=[])->

  # 交集
  @intersection: (x, y)->
    ret = []
    for t, i in x
      if y[i]
        ret[i] = y[i] & t
    ret

  # 比较
  @equal: (x, y)->
    for t, i in x
      if t and y[i]
        if y[i] != t
          return false
      else if t or y[i]
        return false
    true
