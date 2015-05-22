cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

ShellWrapper = {}
  ShellWrapper.__index = ShellWrapper
  setmetatable(ShellWrapper, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function ShellWrapper:_init(serialPort)
    self.port = serialPort
    self.timeout = 60
  end

  function ShellWrapper:execute(command, newline)
    self.port:writeLine(command, newline)
  end
  
  function ShellWrapper:request(command, newline, timeout, delay)
    self:execute(command, newline)
    return self:getResponse(timeout, delay)
  end
  
  function ShellWrapper:ready()
    return self.port:opened()
  end
  
  function ShellWrapper:getResponse(timeout, delay)
    local timeout = timeout or self.timeout
    local delay = delay or 0.2
    local startTime = os.time()
    local startAvailable = self.port:available()
    while (os.time() - startTime < timeout) do
    
      local currentAvailable = self.port:available()
      if (currentAvailable > 0) and (currentAvailable == startAvailable) then
        return self.port:read(), os.time() - startTime
      end
      startAvailable = currentAvailable
      framework.delay(delay)
    end
    return "", os.time() - startTime
  end
  
  function ShellWrapper:setTimeout(timeout)
    self.timeout = timeout
  end
