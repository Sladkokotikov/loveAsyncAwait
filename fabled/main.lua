love = love

require "typing"
require "async"
require "tcs"
require "delay"
require "ticking"

MouseTcs = TaskCompletionSource:new(true)
KeyboardTcs = TaskCompletionSource:new(true)

sum = async(function(a, b) 
    await(delay.seconds((a+b)/10))
    return a + b
end)

main = async(function() 
    while true do
        local idx, res = await(loveTask.any(MouseTcs:task(), KeyboardTcs:task()))
        print(idx, res[3])
    end
end)


function love.load()
    fireAndForget(main())
end

function love.update(dt)
    tick(dt)
end



function love.keypressed(...)
    KeyboardTcs:tryComplete(...)
end

function love.mousepressed(...)
    MouseTcs:tryComplete(...)
end