loveTask = {}

loveTask.all = async(function(...)
    local args = { ... }
    local co = coroutine.running()
    local left = #args
    local res = {}
    for i, v in ipairs(args) do
        fireAndForget(function()
            res[i] = await(v)
            left = left - 1
            if left == 0 then
                assert(coroutine.resume(co, res))
            end
        end)
    end

    return coroutine.yield()
end)

loveTask.any = async(function(...)
    local args = { ... }
    local co = coroutine.running()
    local left = 0
    for i, v in ipairs(args) do
        fireAndForget(function()
            local res = await(v)
            left = left + 1
            if left == 1 then
                assert(coroutine.resume(co, i, res))
            end
        end)
    end

    return coroutine.yield()
end)