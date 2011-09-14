nonce=[]
class Stream
    constructor: (@_head=nonce, @_tail) ->
        if not @empty() and not @_tail?
            @_tail = new Stream()
    empty: -> @_head == nonce
    @make: (head=nonce, rest...) ->
        if head != nonce
            new Stream head, ->
                Stream.make rest...
        else
            new Stream()
    throw_if_empty: ->
        if @empty()
            throw error: "end of stream"
    head: ->
        @throw_if_empty()
        @_head
    tail: ->
        @throw_if_empty()
        if @_tail not instanceof Stream
            @_tail = @_tail()
        @_tail
    item: (n) -> @skip(n).head()
    skip: (n) ->
        if n==0 then this else @tail().skip(n-1)
    @range: (min=1, max='never') ->
        if min == max
            Stream.make(min)
        else new Stream min, ->
            Stream.range(min+1, max)
    walk: (f) ->
        return if @empty()
        f @head()
        @tail().walk f
    print: -> @walk console.log
    map: (f) ->
        if @empty()
            new Stream()
        else
            new Stream f(@head()), =>
                @tail().map f
    filter: (f) ->
        if @empty()
            new Stream()
        else if f(@head())
            new Stream @head(), =>
                @tail().filter f
        else
            @tail().filter(f)
    take: (n) ->
        return new Stream() if n==0
        new Stream @head(), =>
            return new Stream() if n==1
            @tail().take n-1
    scale: (factor) ->
        scaleone = (n) -> factor*n
        @map(scaleone)
    zip: (zipper, otherstream) ->
        mismatch = ->
            throw error: "length mismatch"
        if @empty()
            if otherstream.empty()
                new Stream()
            else
                mismatch()
        else if otherstream.empty()
            mismatch()
        else
            new Stream zipper(@head(), otherstream.head()), =>
                @tail().zip(zipper, otherstream.tail())
    add: (otherstream) ->
        sum = (a,b) -> a+b
        @zip sum, otherstream
    reduce: (reducer, initial) ->
        if @empty()
            initial
        else
            @tail().reduce(reducer, reducer(initial, @head()))
    length: ->
        ag = (sum, entry) -> sum+1
        @reduce ag, 0
    list: ->
        out = []
        @walk (n) ->
            out.push n
        out
    equal: (s) ->
        return s.empty() if @empty()
        return false if s.empty()
        return false if s.head() != @head()
        return @tail().equal(s.tail())

output = exports or window
output.Stream = Stream

primeStream = Stream.range(2).filter (n) ->
    if n==2
        return true
    try
        primeStream.walk (p) ->
            if p*p > n
                throw true
            if n%p == 0
                throw false
    catch res
        return res
output.primeStream = primeStream
        
    



