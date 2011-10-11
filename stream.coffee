plus = (a,b) -> a+b
mirror = (x) -> x
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
    @repeat: (x) ->
        s=new Stream x, -> s
    @recursive: (f, inits...) ->
        n = inits.length
        helper = (s, index=0) ->
            if inits.length > index
                new Stream inits[index], ->
                    helper s, index+1
            else
                midstreamhelper s
        midstreamhelper = (s) ->
            next = f(s.take(n).list()...)
            new Stream next, ->
                midstreamhelper s.tail()
        result = new Stream inits[0], ->
            helper result, 1

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
        s = this
        while n != 0
            n--
            s = s.tail()
        s
    @range: (min=1, max='never') ->
        if min == max
            Stream.make(min)
        else new Stream min, ->
            Stream.range(min+1, max)
    walk: (f) ->
        s = this
        until s.empty()
            f s.head()
            s = s.tail()
        null
    print: -> @walk console.log
    force: -> @walk ->
    map: (f) ->
        if @empty()
            new Stream()
        else
            new Stream f(@head()), =>
                @tail().map f
    filter: (f) ->
        s = this
        until s.empty() or f s.head()
            s = s.tail()
        return new Stream() if s.empty()
        new Stream s.head(), ->
            s.tail().filter f
    any: (f=mirror) ->
        not @filter(f).empty()
    all: (f=mirror) ->
        negated = (x) -> not f x
        not @any(negated)
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
    append: (s) ->
        if @empty()
            s
        else
            new Stream @head(), =>
                @tail().append(s)
    cycle: ->
        if @empty()
            throw error: "zero times infinity"
        s = new Stream @head(), =>
            @tail().append(s)
    add: (otherstream) -> @zip plus, otherstream
    reduce: (reducer, initial) ->
        @walk (element) ->
            initial = reducer initial, element
        initial
    sum: -> @reduce(plus, 0)
    length: ->
        l = 0
        @walk -> l++
        l
    list: ->
        out = []
        @walk (n) ->
            out.push n
        out
    until: (f) ->
        return new Stream() if @empty() or f @head()
        new Stream @head(), =>
            @tail().until f
    up_until: (f) ->
        return new Stream() if @empty()
        new Stream @head(), =>
            if f @head()
                new Stream()
            else
                @tail().up_until f
    equal: (s) ->
        eq = (a,b) -> a==b
        try
            bstream = @zip eq, s
            bstream.all()
        catch err
            if err.error != "length mismatch"
                throw err
            false
    member: (x) -> @any((m) -> m==x)

output = exports or window
output.Stream = Stream

primeStream = new Stream 2, ->
    Stream.range(3).filter (primeCandidate) ->
        primeStream.until((prime)->
            prime*prime > primeCandidate
        ).all (prime)->
            primeCandidate%prime != 0
output.primeStream = primeStream

#in general, it is not possible to tell if a stream is finite.
paradoxicalStream = new Stream 1, ->
    if paradoxicalStream.is_finite()
        Stream.repeat(1)
    else
        new Stream()
