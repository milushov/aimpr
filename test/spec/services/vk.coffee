'use strict'

describe 'Service: VK', ->

  # load the service's module
  beforeEach module 'aimprApp'

  # instantiate service
  VK = {}
  beforeEach inject (_VK_) ->
    VK = _VK_

  it 'should do something', ->
    expect(!!VK).toBe true
