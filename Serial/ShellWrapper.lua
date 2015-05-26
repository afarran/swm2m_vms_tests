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
  
  --- This function listens on serial port to get data until it receives bytes or timeout
  function ShellWrapper:getResponse(timeout, samplingDelay)
    local startTime = os.time()
    timeout = timeout or self.timeout
    samplingDelay = self.samplingDelay or samplingDelay or 0.2    
    local response = ""
    local dataReceived
    
    while ((os.time() - startTime) < timeout) do
    
      local availableBytes = self.port:available()
      if (availableBytes > 0) then
        response = response .. self.port:read()
        -- some data was received, try to receive more and finish - change timeout
        timeout = (os.time() - startTime) + 1
        framework.delay(0.1) -- wait for 100ms, algorithm will try to receive next chunk of data, if not available it will break the loop
        dataReceived = true
      else
        -- we already got some data and 
        if dataReceived then 
          break 
        end
        framework.delay(samplingDelay)
      end
      
      
    end
    local timediff = os.time() - startTime
    if (string.len(response) > 0) then
      self:log("Response received in " .. timediff .. "s. : " .. response)
    else
      self:log("Response not received after " .. timediff .. "s.")
    end
    return response, timediff
  end
  
  function ShellWrapper:clear()
    local silent = self.silent
    self.silent = true
    self:getResponse(0.5, 0.5)
    self.silent = silent    
  end
  
  function ShellWrapper:setTimeout(timeout)
    self.timeout = timeout
  end
  
  function ShellWrapper:setSamplingDelay(delay)
    self.samplingDelay = delay
  end

  function ShellWrapper:log(data)
    if self.silent then return end
    local lines = string.split(data, "\r\n")
    for _, line in pairs(lines) do
      D:log(self.name .. ": " .. line)
    end
  end