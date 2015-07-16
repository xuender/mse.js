###
miniSpec.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
describe 'getUrl', ->
  it 'default', ->
    expect(Mini.getUrl('a.html', 'b.html')).toEqual('b.html')
    expect(Mini.getUrl('doc/a.html', 'b.html')).toEqual('doc/b.html')
    expect(Mini.getUrl('doc/a.html', '/b.html')).toEqual('b.html')
    expect(Mini.getUrl('a.html', './b.html')).toEqual('b.html')
    expect(Mini.getUrl('doc/a.html', '../b.html')).toEqual('b.html')
    expect(Mini.getUrl('doc/tt/a.html', '../b.html')).toEqual('doc/b.html')
    expect(Mini.getUrl('doc/tt/a.html', '../../b.html')).toEqual('b.html')
    expect(Mini.getUrl('doc/tt/a.html', 'b.html')).toEqual('doc/tt/b.html')

