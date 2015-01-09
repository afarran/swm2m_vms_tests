require "Service/Service"

EioServiceWrapper = {}
  EioServiceWrapper.__index = EioServiceWrapper
  setmetatable(EioServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function EioServiceWrapper:_init()
    local portConfigEnums = {Disabled = 0,
                             Analog = 1,
                             InputWeakPullDown = 2,
                             InputPullUp = 3,
                             InputPullDown = 4,
                             OpenDrainOutputLow = 5,
                             OpenDrainOutputHigh = 6,
                             PushPullOutputLow = 7,
                             PushPullOutputHigh = 8,}
    
    local properties = {{name = "port1Config", pin = 1, ptype="enum", enums=portConfigEnums},
                        {name = "port1AlarmMsg", pin = 2, ptype="boolean"},
                        {name = "port2Config", pin = 12, ptype="enum", enums=portConfigEnums}
                 }
    ServiceWrapper:_init({sin = 25, name = "EIO", mins = {}, properties = properties})
  end