function createType(constructor)
    constructor = constructor or function() end
    local constructor2 = function(t)
        constructor(t)
        return t
    end
    local newType = {}
    setmetatable(newType, newType)
    function newType:__index(k)
        return rawget(self, "__"..k) or rawget(newType, "__"..k)
    end
    function newType:__newindex(k, v)
        if self == newType then
            local _, _, method = k:find("(.+)Async")
            if method then
                k = method
                v = async(v)
            end
        end
        if k:sub(1, 2) == "__" then
            rawset(self, k, v)
        else
            rawset(self, "__"..k, v)
        end
    end

    function newType:new(...)
        return setmetatable(constructor2({}, ...), newType)
    end

    
    return newType
end

