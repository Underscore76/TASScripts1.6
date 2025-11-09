function Queue()
    local q = {}
    q.first = 0
    q.last = -1
    function q.pushleft(value)
        local first = q.first - 1
        q.first = first
        q[first] = value
    end

    function q.pushright(value)
        local last = q.last + 1
        q.last = last
        q[last] = value
    end

    function q.popleft()
        local first = q.first
        if first > q.last then error("queue is empty") end
        local value = q[first]
        q[first] = nil -- to allow garbage collection
        q.first = first + 1
        return value
    end

    function q.popright()
        local last = q.last
        if q.first > last then error("queue is empty") end
        local value = q[last]
        q[last] = nil -- to allow garbage collection
        q.last = last - 1
        return value
    end

    function q.empty()
        return q.first > q.last
    end

    function q.size()
        return q.last - q.first + 1
    end

    return q
end

return Queue
