require "injectedAsync"
require "ticking"
require "typing"

local loveTask = require "loveTask"
local TaskCompletionSource = require "taskCompletionSource"

local await
delay = require("delay")

local Human = createType(function(_self, name) 
    _self.name = name 
end)

local mouseTcs = TaskCompletionSource:new()

function Human:sleepAsync(sec)
    await(delay.seconds(sec))
    return self.name .. tostring(sec)
end
-- nested all don't return results

gameLoop = async(function()
    local m = Human:new("Maksim")
    local a,b = await(loveTask.any(m:sleep(1), m:sleep(2)))
    print(a, b)
end)

function love.load()
    fireAndForget(gameLoop())
end

function love.update(dt)
    tick(dt)
end
function love.mousepressed(...)
    --mouseTcs:complete(...)
end