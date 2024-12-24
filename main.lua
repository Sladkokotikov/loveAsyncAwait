require "async"

function love.update(dt)
    tick(dt)
end

-- Example 1. Delaying something.

function printMessageAsync(a, delay, message)
    a:waitSeconds(delay)
    print(message)
end

fireAndForget(printMessageAsync, 1, "My! My! Time Flies!") -- prints "My! My! Time Flies!" in one second

-- Example 2. Awaiting other functions, anonymous included

function doubleNumberAsync(a, num)
    a:waitSeconds(0.2)
    return num * 2
end

function multiplyByFourAsync(a, num)
    local x2 = a:wait(doubleNumberAsync, num)
    local x4 = a:wait(doubleNumberAsync, x2)
    return x4
end

fireAndForget(function(a) 
    print(a:wait(multiplyByFourAsync, 4)) 
end)

-- Example 3. Completion source.

function waitForClickAsync(a)
    completionSource = a
    local button, x, y = a:waitSource()
    print(button, x, y)
    completionSource = nil
end

function love.mousepressed(x, y, button)
    if completionSource then
        completionSource.complete(x, y, button)
    end
end

fireAndForget(waitForClickAsync)