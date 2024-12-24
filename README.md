# LÖVE2D async / await

My implementation of async / await syntax with LÖVE2D and Lua with no dependencies, along with the thoughts and interesting things I discovered during the process.

# Spoilers

### Fire and forget, Delay
```lua
function printMessageAsync(a, delay, message)
    a:waitSeconds(delay)
    print(message)
end

fireAndForget(printMessageAsync, 1, "My! My! Time Flies!") -- prints "My! My! Time Flies!" in one second
```

### Await other async operations and get results, create anonymous async functions
```lua
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
```

### Awaiting completion source with result
```lua
function waitForClickAsync(a)
    completionSource = a
    local x, y, button = a:waitSource()
    print("Clicked!")
    completionSource = nil
end

function love.mousepressed(x, y, button)
    if completionSource then
        completionSource.complete(x, y, button)
    end
end

fireAndForget(waitForClickAsync)
```

# Restrictions

To make method `async`, you need to add first argument called `a` 
(in order to use beautiful `a:wait` syntax, of course)



