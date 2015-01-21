require "Service/ServiceWrapper"

ShellServiceWrapper = {}
  ShellServiceWrapper.__index = ShellServiceWrapper
  setmetatable(ShellServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function ShellServiceWrapper:_init()
    local properties = {
      { name ="attach", pin=1, ptype="boolean"},
      { name ="tracebackOnError", pin=2, ptype="boolean"},
      { name ="executionTimeout", pin=3, ptype="unsignedint"},
      { name ="accessLevel", pin=4, ptype="unsignedint"},
    }
    local messages_to = {
      { name ="executeCmd", min=1},
      { name ="executeLua", min=2},
      { name ="executePrivilegedCmd", min=3},
      { name ="executePrivilegedLua", min=4},
      { name ="getAccessInfo", min=5},
      { name ="setAccessLevel", min=6},
      { name ="changeAccessPassword", min=7},
    }
    
    local messages_from = {
      { name ="cmdResult", min=1},
      { name ="accessInfo", min=2},
      { name ="accessSetChangeResult", min=3},
    }
    
    ServiceWrapper._init(self, {
        sin = 26, 
        name = "Shell", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties
    })
  end

  function ShellServiceWrapper:eval(code)
    local Fields = {{Name="data",Value=code}}
    self:sendMessageByName("executeLua", Fields)
  end
