local delay = {}

function delay.seconds(s)
    local __thread
    return function()
        table.insert(tickers, { s, function()
        assert(coroutine.resume(__thread))
        end })
        coroutine.yield()
    end
end

return delay
