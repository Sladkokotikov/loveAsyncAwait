local A = {}

A.__index = A

function fireAndForget(fn, ...)
    local a = setmetatable({}, A)
    local args = {...}
    a.co = coroutine.create(
        function()
            fn(a, unpack(args))
        end
    )
    coroutine.resume(a.co)
    return a
end

function A:wait(fn, ...)
    return fn(self, ...)
end

function A:waitSeconds(delaySeconds)
    table.insert(tickers, {delaySeconds, function() 
        coroutine.resume(self.co) 
    end})
    coroutine.yield()
end

function A:waitSource()
    self.complete = function(...)
        coroutine.resume(self.co, ...)
    end
    return coroutine.yield()
end

tickers = {}

function tick(dt)
    for i,v in ipairs(tickers) do
        v[1] = v[1] - dt
        if v[1] <= 0 then
            v[2]()
            table.remove(tickers, i)
        end
    end
end