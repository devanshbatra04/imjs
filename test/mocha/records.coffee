Fixture              = require './lib/fixture'
{prepare, eventually, always} = require './lib/utils'
should               = require 'should'

# Helper class to incapsulate the logic for tests on iteration
class Counter
  constructor: (@expN, @expT, @done) ->
    @n = 0
    @total = 0
  count: (emp) =>
    @n++
    @total += emp.age
  check: () =>
    @n.should.equal(@expN)
    @total.should.equal(@expT)
    @done()

SLOW = 100

describe 'Service', ->
  @slow SLOW

  {service, olderEmployees} = new Fixture()

  olderEmployees.select.push 'age'

  describe '#records', ->

    @beforeAll prepare -> service.records olderEmployees

    it 'promises to return a list of employee records', eventually (employees) ->
      should.exist employees
      employees.length.should.equal 46
      (e.age for e in employees).reduce((x, y) -> x + y).should.equal 2688

  describe '#eachRecord', ->

    query =
      select: ['age']
      from: 'Employee'
      where: olderEmployees.where

    it 'can yield each employee', (done) ->
      {check, count} = new Counter 46, 2688, done
      service.query(query).then (q) -> service.eachRecord q, {}, count, check, done

    it 'can yield each employee, without needing a page', (done) ->
      {check, count} = new Counter 46, 2688, done
      service.query(query).then (q) -> service.eachRecord q, count, check, done

    it 'can yield a buffered-reader for employees', (done) ->
      {check, count} = new Counter 46, 2688, done
      service.query(query).then (q) -> service.eachRecord(q).then (br) ->
        br.each count
        br.done check
        br.error done

    it 'can yield each employee, using params', (done) ->
      {check, count} = new Counter 46, 2688, done
      service.eachRecord query, {}, count, check, done

    it 'can yield each employee, without needing a page, using params', (done) ->
      {check, count} = new Counter 46, 2688, done
      service.eachRecord query, count, check, done

    it 'can yield a buffered-reader for employees, using params', (done) ->
      {check, count} = new Counter 46, 2688, done
      service.eachRecord(query).then (br) ->
        br.each count
        br.done check
        br.error done


describe 'Query', ->

  {service, olderEmployees} = new Fixture()

  olderEmployees.select.push 'age'

  describe '#records', ->

    @beforeAll prepare -> service.query(olderEmployees).then (q) -> q.records()

    it 'promises to return a list of employee records', eventually (employees) ->
      should.exist employees
      employees.length.should.equal 46
      (e.age for e in employees).reduce((x, y) -> x + y).should.equal 2688

  describe '#eachRecord', ->

    it 'promises to return an iterator over the employees', (done) ->
      service.query(olderEmployees).then( (q) -> q.eachRecord() ).then (iterator) ->
        n = sum = 0
        iterator.error done
        iterator.each (e) ->
          n++
          sum += e.age
        iterator.done ->
          n.should.equal 46
          sum.should.equal 2688
          done()



