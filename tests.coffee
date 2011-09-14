{Stream, primeStream} = require "./stream"

assert = (b) ->
  if not b
    console.log 'FUCK'
    throw 'fuck'

eq = (a,b) ->
  assert a==b

eqList = (s,l) ->
  assert s.equal Stream.make l...


#before we start, make sure this equal thing works
one_to_five = Stream.range(1,5)
one_to_ten = Stream.range(1,10)
assert not one_to_five.equal one_to_ten

s = Stream.make(10, 20, 30)
eqList s, [10,20,30]
eq s.length(), 3
eq s.head(), 10
eq s.item(0), 10
eq s.item(1), 20
eq s.item(2), 30

t = s.tail()
eq t.head(), 20
u = t.tail()
eq u.head(), 30
v = u.tail()
assert v.empty()


s = Stream.range(10, 20)
eqList s, [10..20]


doubleNumber = (x) ->
  2 * x

numbers = Stream.range(10, 15)
doubles = numbers.map(doubleNumber)
eqList doubles, [20,22,24,26,28,30]

checkIfOdd = (x) ->
  if x % 2 == 0
    false
  else
    true
numbers = Stream.range(10, 15)
onlyOdds = numbers.filter(checkIfOdd)
eqList onlyOdds, [11,13,15]

printItem = (x) ->
  console.log "The element is: " + x
numbers = Stream.range(10, 12)
#test this better
numbers.walk printItem

numbers = Stream.range(10, 100)
fewerNumbers = numbers.take(10)
eqList fewerNumbers, [10..19]
numbers = Stream.range(1, 3)
multiplesOfTen = numbers.scale(10)
eqList multiplesOfTen, [10,20,30]
eqList numbers.add(multiplesOfTen), [11,22,33]

naturalNumbers = Stream.range()
oneToTen = naturalNumbers.take(10)
eqList oneToTen, [1..10]

evenNumbers = naturalNumbers.map((x) ->
  2 * x
)
oddNumbers = naturalNumbers.filter((x) ->
  x % 2 != 0
)
eqList evenNumbers.take(3), [2,4,6]
eqList oddNumbers.take(3), [1,3,5]

s = new Stream(10, ->
  new Stream()
)
eqList s, [10]
t = new Stream(10, ->
  new Stream(20, ->
    new Stream(30, ->
      new Stream()
    )
  )
)
eqList t, [10,20,30]

ones = ->
  new Stream(1, ones)

s = ones()
eqList s.take(3), [1,1,1]


naturalNumbers = ->
  new Stream(1, ->
    ones().add naturalNumbers()
  )

eqList naturalNumbers().take(5), [1..5]



sieve = (s) ->
  h = s.head()
  new Stream(h, ->
    sieve s.tail().filter((x) ->
      x % h != 0
    )
  )
eqList sieve(Stream.range(2)).take(10), [2,3,5,7,11,13,17,19,23,29]
