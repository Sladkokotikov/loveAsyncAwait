function fireAndForget(fn)
    assert(coroutine.resume(coroutine.create(fn)))
end

function await(fn, ...)
    return fn(...)
end

function async(fn)
    return function(...)
        local args = { ... }
        return function()
            return await(fn, unpack(args))
        end
    end
end