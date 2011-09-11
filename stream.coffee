nonce=[]
class Stream
    constructor: (@_head=nonce, @_tail) ->
        if not @empty() and not @_tail?
            @_tail = new Stream()
    empty: -> @_head == nonce
    @make: (head=nonce, rest...) ->
        if head != nonce
            new Stream(head, Stream.make(rest...))
        else
            new Stream()
    tie: ->
        if @empty()
            throw error: "end of stream"
    head: ->
        @tie()
        @_head
    tail: ->
        @tie()
        if @_tail not instanceof Stream
            @_tail = @_tail()
        @_tail
    item: (n) ->
        if n==0 then @head() else @tail().item(n-1)
    @range: (min=1, max='never') ->
        if min == max
            Stream.make(min)
        else new Stream min, ->
            Stream.range(min+1, max)
    walk: (f) ->
        return if @empty()
        f @head()
        @tail().walk f
    print: ->
        @walk console.log
    map: (f) ->
        if @empty()
            return new Stream()
        else
            new Stream f(@head()), =>
                @tail().map f
    filter: (f) ->
        if @empty()
            return new Stream()
        if f(@head())
            new Stream @head(), =>
                @tail().filter f
        else
            @tail().filter(f)
    take: (n) ->
        if n==0
            return new Stream()
        new Stream @head(), =>
            if n==1
                return new Stream()
            @tail().take n-1
    scale: (factor) ->
        scaleone = (n) -> factor*n
        @map(scaleone)
    add: (s) ->
        return this if s.empty()
        return s if @empty()
        new Stream (@head() + s.head()), =>
            @tail().add s.tail()
    length: ->
        if @empty()
            0
        else
            1 + @tail().length()
exports.Stream = Stream
    
        
    



