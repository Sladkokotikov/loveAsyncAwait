function injectUpvalue(fn, upvalueName, upvalue)
    for up=1, debug.getinfo (fn).nups do
        if debug.getupvalue (fn, up) == upvalueName then
            debug.setupvalue(fn, up, upvalue)
        end
    end
end
function fireAndForget(fn)
    local cor = coroutine.create(fn)
    local await
    
    await = function(innerFn, ...)
        injectUpvalue(innerFn, "await", await)
        injectUpvalue(innerFn, "__thread", cor)
        return innerFn(...)
    end

    injectUpvalue(fn, "await", await)
    injectUpvalue(fn, "__thread", cor)
    assert(coroutine.resume(cor))
end

function async(fn)
    local await
    return function(...)
        local args = {...}
        return function()
            return await(fn, unpack(args))
        end
    end
end