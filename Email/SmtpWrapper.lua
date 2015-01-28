cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

SmtpWrapper = {}
  SmtpWrapper.__index = SmtpWrapper
  setmetatable(SmtpWrapper, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function SmtpWrapper:_init(serialPort)
    self.port = serialPort
    self.timeout = 60 -- default SMTP timeout
  end

  function SmtpWrapper:execute(command, newline)
    self.port:writeLine(command, newline)
  end
  
  function SmtpWrapper:start()
    self:execute("SMTP")
  end
  
  function SmtpWrapper:ready()
    return self.port:opened()
  end
  
  function SmtpWrapper:getResponse(timeout)
    local timeout = timeout or self.timeout
    local startTime = os.time()
    local startAvailable = self.port:available()
    while (os.time() - startTime < timeout) do
    
      local currentAvailable = self.port:available()
      if (currentAvailable > 0) and (currentAvailable == startAvailable) then
        return self.port:read()
      end
      startAvailable = currentAvailable
      framework.delay(0.2)
    end
  end
  
  function SmtpWrapper:setTimeout(timeout)
    self.timeout = timeout
  end