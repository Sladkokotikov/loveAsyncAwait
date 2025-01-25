local TaskCompletionSource = require "taskCompletionSource"
local loveTask = {}
local await
require "runInParallel"

loveTask.all = async(function(...)
    local args = { ... }
    local left = {#args}
    local res = {}
    local tcs = TaskCompletionSource:new()

    for i, v in ipairs(args) do
        runInParallel(i,v,res, left, tcs)
    end

    await(tcs:task())
    return unpack(res)
end)

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
