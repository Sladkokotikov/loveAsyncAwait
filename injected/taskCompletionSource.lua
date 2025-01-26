local TaskCompletionSource = createType(function(self)
    self.err = function()
        error("TaskCompletionSource was not awaited yet")
    end
    self.complete = self.err
end)



function TaskCompletionSource:task(thread)
    local __thread
    return function()
        self.complete = function(_self, ...)
            assert(coroutine.resume(thread or __thread, ...))
        end
        local res = {coroutine.yield()}
        self.complete = self.err
        return unpack(res)
    end
end

return TaskCompletionSource