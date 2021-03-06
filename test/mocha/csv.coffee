Fixture                = require './lib/fixture'
{prepare, eventually, shouldFail}  = require './lib/utils'
{invokeWith, invoke, defer, get, flatMap} = Fixture.funcutils
should = require 'should'

ROWS = 87
ROW = '"10","EmployeeA1"'
SUM = 2688
SLOW = 100

toRows = (text) -> text.split /\n/

describe 'CSV results', ->

  @slow SLOW
  {service, youngerEmployees} = new Fixture()

  query =
    select: ['age', 'name']
    from: 'Employee'
    where: youngerEmployees.where

  @beforeAll prepare ->
    service.query(query)
           .then (q) -> service.post 'query/results', format: 'csv', query: q.toXML()
           .then toRows
  
  describe '#post(path, format: "csv")', ->

    it "should return #{ ROWS } rows", eventually (rows) ->
      rows.length.should.eql ROWS

    it 'should return things that look like tab separated values', eventually ([row]) ->
      should.exist row
      row.should.equal ROW

