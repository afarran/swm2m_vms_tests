require "Service/ServiceWrapper"
IdpServiceWrapper = {}
  IdpServiceWrapper.__index = IdpServiceWrapper
  setmetatable(IdpServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function IdpServiceWrapper:_init()
    
    local properties = {
      { name="mobileID", pin=3, ptype="string"},
    }  
          
    ServiceWrapper._init(self, {
        sin = 27, 
        name = "idp", 
        messages_to = {}, 
        messages_from = {}, 
        properties = properties})
  end
  
