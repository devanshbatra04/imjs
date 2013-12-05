Fixture = require './lib/fixture'
{always, prepare, eventually} = require './lib/utils'
should = require 'should'

describe 'Service#register', ->

  {service} = new Fixture
  service.errorHandler = ->

  removeMrFoo = ->
    service.login('mr foo', 'passw0rd')
            .then (fooService) ->
              p = fooService.getDeregistrationToken()
              p.then (token) -> fooService.deregister token.uuid

  @beforeAll always removeMrFoo

  describe 'registering a new user', ->

    @beforeAll prepare -> service.register 'mr foo', 'passw0rd'
    @afterAll always removeMrFoo

    it 'should be able to register a new user', eventually (s) ->
      s.fetchUser().then (user) -> user.username.should.eql 'mr foo'

  describe 'deregistering a user', ->

    @beforeAll prepare -> service.register 'mr foo', 'passw0rd'
    @afterAll always removeMrFoo

    it 'should be able to deregister a user', eventually (s) ->
      accessToken = s.token
      tokP = s.getDeregistrationToken()
      tokP.then((token) ->
            token.secondsRemaining.should.be.above 0
            s.deregister token.uuid)
          .then(-> s.fetchUser())
          .then(
            (-> throw new Error "Token is still valid" ),
            ((err) -> err.should.match new RegExp accessToken ))
