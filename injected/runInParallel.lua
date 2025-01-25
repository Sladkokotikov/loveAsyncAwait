
runInParallel = function(i,v,res, left, tcs)
    local await

    fireAndForget(function()
        res[i] = await(v)
        left[1] = left[1] - 1
        if left[1] == 0 then
            tcs:complete()
        end
    end)
end

runAnyInParallel = function(i,v, left, tcs)
    local await

    fireAndForget(function()
        local res = await(v)
        left[1] = left[1] + 1
        if left[1] == 1 then
            tcs:complete(i, res)
        end
    end)
end