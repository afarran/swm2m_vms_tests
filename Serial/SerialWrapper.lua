cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

SerialWrapper = {}
  SerialWrapper.__index = SerialWrapper
  setmetatable(SerialWrapper, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function SerialWrapper:_init(args)
    self.buffer = ""
    if args.open then
      self:open(args)
    else
      self:configure(args)
    end
      
  end
  
  function SerialWrapper:configure(args)
    args.baud = args.baud or 9600
    args.bits = args.bits or 8
    args.stops = args.stops or 0
    args.parity = args.parity or 'n'
    self.args = args
    self.name = args.name
  end
  
  function SerialWrapper:open(args)
    if args then 
      self:configure(args)
    end
  end
  
  function SerialWrapper:write(data)
    print "Not implemented"
  end
  
  function SerialWrapper:close()
    print "Not implemented"
  end
  
  function SerialWrapper:readLine(newline, timeout)
    
    if not self:isOpened() then
      return nil
    end
    local timeout = timeout or 60
    local newline = newline or "\r"
    local startTime = os.time()
        
    while (os.time() - startTime) < timeout do
      if string.len(self.buffer) > 0 then
        local newlinePosition = string.find(self.buffer, newline)
        if newlinePosition then
          local data = string.sub(self.buffer, 0, newlinePosition)
          self.buffer = string.sub(self.buffer, newlinePosition+1) -- check what if newline is last
        end
      end
      if self:available()>0 then
        self.buffer = self.buffer .. self:read()
      end
      framework.delay(1)
    end
    
  end