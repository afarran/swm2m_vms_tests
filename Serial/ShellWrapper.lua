cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

ShellWrapper = {}
  ShellWrapper.__index = ShellWrapper
  setmetatable(ShellWrapper, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function ShellWrapper:_init(serialPort, silent)
    self.silent = silent
    self.name = self.name or "ShellWrapper"
    self.port = serialPort
    self.timeout = 60 -- default Shell response timeout
  end

  function ShellWrapper:execute(command, newline)
    self:log("Executing command: " .. command)
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
    timeout = timeout or self.timeout
    delay = delay or 0.2
    local startTime = os.time()
    local startAvailable = self.port:available()
    while (os.time() - startTime < timeout) do
    
      local currentAvailable = self.port:available()
      if (currentAvailable > 0) and (currentAvailable == startAvailable) then
        local response = self.port:read()
        local timediff = os.time() - startTime
        self:log("Response received in " .. timediff .. "s. : " .. response)
        return response, timediff
      end
      startAvailable = currentAvailable
      framework.delay(delay)
    end
    local timediff = os.time() - startTime
    self:log("Response not received after " .. timediff .. "s.")
    return "", timediff
  end
  
  function ShellWrapper:setTimeout(timeout)
    self.timeout = timeout
  end

  function ShellWrapper:log(data)
    if self.silent then return end
    local lines = string.split(data, "\r\n")
    for _, line in pairs(lines) do
      D:log(self.name .. ": " .. line)
    end
  end