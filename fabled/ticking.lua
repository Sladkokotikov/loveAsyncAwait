tickers = {}

function tick(dt)
    for i,v in ipairs(tickers) do
        v[1] = v[1] - dt
        if v[1] <= 0 then
            v[2]()
            table.remove(tickers, i)
        end
    end
end