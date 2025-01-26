local TaskCompletionSource = require "taskCompletionSource"
local loveTask = {}

require "runInParallel"

loveTask.all = function(...)
    local args = { ... }
    local await, __thread

    return function()
        print(".all await fn:", await)
        local left = #args
        local res = {}
        local tcs = TaskCompletionSource:new()
        for i, v in ipairs(args) do
            fireAndForget(function() 
                res[i] = await(v)
                left = left - 1
                if left == 0 then
                    tcs:complete()
                end
            end)
        end
        await(tcs:task(__thread))
        print("returning from all")
        return unpack(res)
    end
end

loveTask.any = async(function(...)
    local args = { ... }
    local left = {0}
    local tcs = TaskCompletionSource:new()

    for i, v in ipairs(args) do
        runAnyInParallel(i,v, left, tcs)
    end

    local result, winIndex = await(tcs:task())
    return result, winIndex
end)

return loveTask
