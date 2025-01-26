delay = {}

delay.seconds = async(function(sec)
    local co = coroutine.running()
    table.insert(tickers, { sec, function()
        assert(coroutine.resume(co))
    end })
    coroutine.yield()
end)
