'use strict'

describe 'Service: API', ->

  # load the service's module
  beforeEach module 'aimprApp'

  # instantiate service
  API = {}
  beforeEach inject (_API_) ->
    API = _API_

  it 'should do something', ->
    expect(!!API).toBe true
