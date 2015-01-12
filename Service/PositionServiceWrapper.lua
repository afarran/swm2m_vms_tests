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
    ServiceWrapper:_init({sin = 20, name = "Position", mins = {}, properties = properties})
  end
