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
      { name ="serviceActive", pin=1, ptype="boolean"},
      { name ="led1State", pin=2, ptype="enum"},
      { name ="led2State", pin=3, ptype="enum"},
      { name ="led3State", pin=4, ptype="enum"},
      { name ="led4State", pin=5, ptype="enum"},
      { name ="buzzerState", pin=6, ptype="enum"},
      { name ="sendPower", pin=7, ptype="boolean"},
      { name ="externalPower", pin=8, ptype="boolean"},
      { name ="sendButtonPressed", pin=9, ptype="boolean"},
      { name ="buttonPressed", pin=10, ptype="boolean"},
      { name ="buttonInterval", pin=11, ptype="unsignedint"},
      { name ="uniboxConnected", pin=12, ptype="boolean"},

    }
    local messages_to = {
      { name ="statusRequest", min=1},
    }
    
    local messages_from = {
      { name ="uniboxEvent", min=1},
      { name ="uniboxStatus", min=2},
    }
    
    ServiceWrapper._init(self, {
        sin = 162, 
        name = "Unibox", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties
    })
  end
