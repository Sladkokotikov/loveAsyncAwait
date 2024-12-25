# LÖVE2D async / await

My naive implementation of async / await syntax with LÖVE2D and Lua with no dependencies, in just 32 lines of code, along with the thoughts and interesting things I discovered during the process.

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

# Here be downsides.

- To make method `async`, you need to add **first** argument called `a` 
(in order to use beautiful `a:wait` syntax, of course), and forget / a:wait them without parentheses 👻


    There are some ugly ways to use `a:` as an upvalue or as a local variable, but they use `debug` table, which is too tricky even for me. Also I play fair, and there is no file preprocessing. This is pure Lua for LÖVE2D (tested for version 11.5 with Lua 5.1).


- Also, if you are planning to a:waitSeconds (and a:waitFrames, which is easy to implement as well) you need a ticker. I provided the simplest one in [async.lua](async.lua) file


- There is no support for `a:waitAll` or `a:waitAny` at the moment, I just didn't need them, but I think it's easy to implement.


- This is more of a "proof of concept" thing, minimal but working implementation that looks good enough.


- I don't know if it affects optimization at a large scale! New coroutine is created every `fireAndForget` call, so don't recommend it as often as `update`, for example.


# Why though?

I fell in LÖVE with Lua, but I missed `async` keyword so much! I looked up and found [this repository](https://github.com/ms-jpq/lua-async-await), got scared and closed the tab. And in few months I took my own attempt, and it seems like I succeeded


# I hope you know how to use...
[Lua coroutines](https://www.lua.org/manual/5.1/manual.html#5.2) and other languages `async/await` syntax.

# Core idea

I remember thinking "_What if a coroutine resumed itself, but at the right moment?_". 

That's it!


Let's start with `fireAndForget`:

```lua
function fireAndForget(fn, ...) -- 1
    local asyncState = setmetatable({}, A) -- 2
    local args = {...}
    asyncState.co = -- 5
        coroutine.create( -- 4
            function() -- 3
                fn(asyncState, unpack(args))
            end
    )
    coroutine.resume(asyncState.co) -- 6
end
```

1. It accepts a callback and any number of arguments to be called with
2. First, it creates a new async state (just a table) and ensures it has all the required `:wait` methods - thanks to the metatable
3. Next, it creates a thunk - a function that will call given callback with given arguments, also passing async state as the first argument
4. Next, we create a coroutine from a thunk...
5. and cache it in async state!
6. Finally, we resume the coroutine


Magic! ✨

If a function doesn't use `a:wait`, it is just called synchronously. Boring.

But if it uses...

Let's have a look at `a:waitSeconds` implementation.

```lua
function A:waitSeconds(delaySeconds) -- 1
    table.insert(tickers, {delaySeconds, function() -- 3
        coroutine.resume(self.co) -- 2
    end})
    coroutine.yield() -- 4
end -- 5
```
1. Quite self explanatory
2. We ensure that coroutine of current async state is resumed ...
3. after some delay.
Remember the core idea? Coroutine resumes itself at the right moment - in some seconds!
4. And we yield. 
5. When given amount of seconds has passed, coroutine will be resumed, and we will exit from function


Magic! ✨


In simple words, coroutines allow to stop execution and then go back to the stopping point, _nice of them_, so we will use exactly that.

Next in line, `a:waitSource`. This allows us to resume the asynchronous function from another function, for example, on click.

```lua
function A:waitSource()
    self.complete = function(...)
        coroutine.resume(self.co, ...)
    end
    return coroutine.yield()
end
```

The idea remains the same: coroutine resumes itself at the right moment, in this case - whenever `complete` is called. When that happens, execution is resumed from `coroutine.yield` point, and we also return arguments of `complete` as completionSource result. 

Voilà!

The last one. The most intriguing one! `a:wait`

```lua
function A:wait(fn, ...)
    return fn(self, ...)
end
```

What? _Just one line?_
**Yes**. It just calls a function, passing all of the arguments and ensuring that the first argument is beautiful `asyncState`.


This is more than magic. 


Sorcery! 🔮


# The end!

### Thanks for reading! I'm glad if you found it helpful.


