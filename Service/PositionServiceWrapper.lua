require "Service/ServiceWrapper"
PositionServiceWrapper = {}
  PositionServiceWrapper.__index = PositionServiceWrapper
  setmetatable(PositionServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function PositionServiceWrapper:_init()
    local properties = {{name = "latitude", pin = 6},
                  {name = "longitude", pin = 7},
                  {name = "heading", pin = 10, ptype="unsignedint"},
                  {name = "continuous", pin = 15, ptype="unsignedint"},
                 }
          
    local messages_from = {{name="position", min = 1 }}
    local messages_to = {{name="getPosition", min = 1}}
    ServiceWrapper:_init({sin = 20, name = "Position", messages_to = messages_to, messages_from = messages_from, properties = properties})
  end
