###
set.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
class Set
  constructor: (@set=[])->

  add: (arg)=>
    if arg instanceof Array
      for t, i in arg
        if @set[i]
          @set[i] = @set[i] | t
        else
          @set[i] = t
    else
      this.add(Set.toArray(arg))

  in: (array)=>
    for s, i in array
      if s
        t = s & @set[i]
        if t != s
          return false
    true

  @toArray: (num)=>
    array = []
    x = Math.floor(num / 32)
    y = 1 << (num % 32)
    if array[x]
      array[x] = array[x] | y
    else
      array[x] = y
    array

  @equal: (x, y)->
    for t, i in x
      if t and y[i]
        if y[i] != t
          return false
      else if t or y[i]
        return false
    true

  @intersection: (x, y)->
    ret = []
    for t, i in x
      if y[i]
        ret[i] = y[i] & t
    ret

