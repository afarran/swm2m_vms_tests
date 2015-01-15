require "Service/LogServiceWrapper"

LogServiceWrapper = {}
  LogServiceWrapper.__index = LogServiceWrapper
  setmetatable(LogServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function LogServiceWrapper:_init()
    
    -- Possible types: "unsignedint"  "signedint"  "enum"  "string"  "boolean"  "data"
    
    local properties = {
    }
    
    local messages_from = {
    }
    local messages_to = {
    }
    
    ServiceWrapper._init(self, {
        sin = 23, 
        name = "Log", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties,
        bitmaps = bitmaps,
    })
  end
