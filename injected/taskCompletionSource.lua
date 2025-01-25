local TaskCompletionSource = createType(function(self)
    self.err = function()
        error("TaskCompletionSource was not awaited yet")
    end
    self.complete = self.err
end)

local __thread

function TaskCompletionSource:taskAsync()
    self.complete = function(_self, ...)
        assert(coroutine.resume(__thread, ...))
    end
    local res = {coroutine.yield()}
    self.complete = self.err
    return unpack(res)
end

return TaskCompletionSource