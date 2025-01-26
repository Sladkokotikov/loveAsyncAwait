TaskCompletionSource = createType(function(self, pack) 
    self.pack = true
end)

function TaskCompletionSource:taskAsync()
    self.thread = coroutine.running()
    local res = {coroutine.yield()}
    self.thread = nil
    if self.pack then
        return res
    end
    return unpack(res)
end

function TaskCompletionSource:complete(...)
    assert(self.thread, "Task completion source was not awaited yet!")
    coroutine.resume(self.thread, ...)
end

function TaskCompletionSource:tryComplete(...)
    if not self.thread then
        return false
    end
    self:complete(...)
    return true
end