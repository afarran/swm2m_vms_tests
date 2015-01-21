require "Service/ServiceWrapper"

UniboxServiceWrapper = {}
  UniboxServiceWrapper.__index = UniboxServiceWrapper
  setmetatable(UniboxServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function UniboxServiceWrapper:_init()
    local properties = {
    }
    local messages_to = {
    }
    
    local messages_from = {
    }
    
    ServiceWrapper._init(self, {
        sin = 162, 
        name = "Unibox", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties
    })
  end
