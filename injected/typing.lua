function createType(constructor)
    constructor = constructor or function() end
    local newType = {}
    setmetatable(newType, newType)
    function newType:__index(k)
        --print("__index", k)
        return rawget(self, "__"..k) or rawget(newType, "__"..k)
    end
    function newType:__newindex(k, v)
        --print("__newindex", k, v)
        if self == newType then
            local _, _, method = k:find("(.+)Async")
            if method then
                k = method
                v = async(v)
            end
        end
        rawset(self, "__"..k, v)
    end

    function newType:new(...)
        local t = {}
        constructor(t, ...)
        return setmetatable(t, newType)
    end

    
    return newType
end

