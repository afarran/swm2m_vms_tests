require "Serial/SerialWrapper"
require "Serial/ul_serial"

RealSerialWrapper = {}
  RealSerialWrapper.__index = RealSerialWrapper
  setmetatable(RealSerialWrapper, {
    __index = SerialWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })

  function RealSerialWrapper:_init(args)
    SerialWrapper._init(self, args)
  end
  
  function RealSerialWrapper:open(args)
    SerialWrapper.open(self, args)
    self.port = io.Serial{
      port = self.args.name, 
      baud = self.args.baud,}
    
    return self.port
  end
    
  function RealSerialWrapper:close()
    return self.port:close()
  end
  
  function RealSerialWrapper:getPorts()
    return io.Serial:getPorts()
  end
  
  function RealSerialWrapper:write(data)
    return self.port:write(data)
  end
  
  function RealSerialWrapper:read()
    return self.port:read()
  end
  
  function RealSerialWrapper:opened()
    return self.port.opened
  end
  
  function RealSerialWrapper:available()
    return self.port:available()
  end
  

    
    
    