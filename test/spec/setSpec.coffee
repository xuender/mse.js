###
setSpec.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
describe 'Set', ->
  it 'equal', ->
    expect(Set.equal([1],[1])).toEqual(true)
    expect(Set.equal([],[])).toEqual(true)
    expect(Set.equal([1],[])).toEqual(false)
    expect(Set.equal([0],[])).toEqual(true)
    expect(Set.equal([0, 2],[null,2])).toEqual(true)
  it 'add', ->
    s = new Set([1])
    s.add(2)
    expect(s.set).toEqual([5])
    s.add([0,3])
    expect(s.set).toEqual([5,3])
    s.add([0,2])
    expect(s.set).toEqual([5,3])
    s.add([0,7])
    expect(s.set).toEqual([5,7])
    s.add(4)
    expect(s.set).toEqual([21,7])

  describe 'in', ->
    s = new Set()
    s.add(4)
    s.add(9)
    s.add(3)
    it 'in', ->
      t = new Set()
      t.add(9)
      t.add(3)
      expect(s.in(t.set)).toEqual(true)
    it 'not in', ->
      t = new Set()
      t.add(5)
      expect(s.in(t.set)).toEqual(false)
      f = new Set()
      f.add(400)
      expect(s.in(f.set)).toEqual(false)

