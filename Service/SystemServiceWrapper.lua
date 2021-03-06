require "Service/ServiceWrapper"
SystemServiceWrapper = {}
  SystemServiceWrapper.__index = SystemServiceWrapper
  setmetatable(SystemServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function SystemServiceWrapper:_init()
    local ledControlEnums = { Terminal = 0, User = 1 }
    
    local properties = {{ name="executionWatchdogTimeout", pin=1, ptype="unsignedint"},
                        { name="autoGCIdleTimeout", pin=2, ptype="unsignedint"},
                        { name="autoGCMemThreshold", pin=3, ptype="unsignedint"},
                        { name="powerSave", pin=4, ptype="boolean"},
                        { name="timeSyncRetry", pin=5, ptype="unsignedint"},
                        { name="ledControl", pin=6, ptype="enum", enums=ledControlEnums},
                        { name="ledStatusTimeout", pin=7, ptype="unsignedint"},
                        { name="systemTime", pin=10, ptype=""},
                        { name="terminalUptime", pin=11, ptype=""},
                        { name="LSFUptime", pin=12, ptype=""},
                        { name="timeSyncInterval", pin=15, ptype=""},
                        { name="timeSyncThreshold", pin=16, ptype=""},
                        { name="powerLedMode", pin=17, ptype=""},
                       }  
          
    local messages_from = { { name ="terminalInfo", min=1},
                            { name ="terminalStatus", min=2},
                            { name ="serviceList", min=3},
                            { name ="serviceInfo", min=4},
                            { name ="propertyValues", min=5},
                            { name ="termReset", min=6},
                            { name ="timeSync", min=7},
                            { name ="terminalRegistration", min=8},
                            { name ="setPasswordResult", min=9},
                            { name ="disableServiceResult", min=10},
                          }
    
    local messages_to = { { name ="getTerminalInfo", min=1},
                          { name ="getTerminalStatus", min=2},
                          { name ="getServiceList", min=3},
                          { name ="getServiceInfo", min=4},
                          { name ="restartService", min=5},
                          { name ="resetTerminal", min=6},
                          { name ="getTerminalMetrics", min=7},
                          { name ="getProperties", min=8},
                          { name ="setProperties", min=9},
                          { name ="resetProperties", min=10},
                          { name ="saveProperties", min=11},
                          { name ="revertProperties", min=12},
                          { name ="restartFramework", min=13},
                          { name ="setPassword", min=14},
                          { name ="disableService", min=15},
                          { name ="setEnabledServices", min=16},
                          { name ="setFactoryPassword", min=247},
                        }
                        
    ServiceWrapper._init(self, {
        sin = 16, 
        name = "System", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties})
  end
  
  function SystemServiceWrapper:resetProperties(sinList)
    local Fields = {}
    local list_elements = {}
    
    for index, sin in pairs(sinList) do
      list_elements[index] = {Index = index-1, Fields = {{Name="sin", Value=sin}}}
    end
    
    Fields[1] = {Name = "list", Elements = list_elements}
    self:sendMessageByName("resetProperties", Fields)
  end
  
  function SystemServiceWrapper:restartService(sinOrService)
    local sin = self:_sinOrSinFromService(sinOrService)
    local Fields = {{Name="sin",Value=sin}}
    self:sendMessageByName("restartService", Fields)
  end
  
  function SystemServiceWrapper:restartFramework(waitForTerminalRegistration)
    self:sendMessageByName("restartFramework")
    if waitForTerminalRegistration then
      self:waitForMessagesByName("terminalRegistration", 240)
    end
  end

  function SystemServiceWrapper:getTerminalId() 
    self:sendMessageByName("getTerminalInfo")
    local receivedMessages = self:waitForMessagesByName({"terminalInfo"})
    local terminalInfo = receivedMessages.terminalInfo
    return terminalInfo.hardwareManufacturingID
  end

  function SystemServiceWrapper:getTerminalHardwareVersion(resolveHW)

    -- if we are not resolving variant (for example when only 690 is available)
    if not resolveHW then
      return 1
    end

    gateway.setHighWaterMark() -- to get the newest messages
    
    self:sendMessageByName("getTerminalInfo")
    local receivedMessages = self:waitForMessagesByName({"terminalInfo"})
    local terminalInfo = receivedMessages.terminalInfo
    
    if terminalInfo.hardwareVariant == "IDP-6XX" then return 1
    elseif terminalInfo.hardwareVariant == "IDP-7XX" then return 2
    elseif terminalInfo.hardwareVariant == "IDP-8XX" then return 3
    end
    
  end

  function SystemServiceWrapper:getServiceInfo(sinOrService)
    local sin
    if type(sinOrService) == "table" then
      sin = sinOrService.sin
    else
      sin = sinOrService
    end
    local fields = {{Name="sin",Value=sin}}
    
    return self:requestMessageByName("getServiceInfo", fields, "serviceInfo")["serviceInfo"]
    
  end
  
  function SystemServiceWrapper:disableService(sinOrService)
    local sin = self:_sinOrSinFromService(sinOrService)
    local fields = {{Name="sin",Value=sin},{Name="disable",Value=true}}
    self:sendMessageByName("disableService", fields)
  end
  
  function SystemServiceWrapper:enableService(sinOrService)
    local sin = self:_sinOrSinFromService(sinOrService)
    local fields = {{Name="sin",Value=sin},{Name="disable",Value=false}}
    self:sendMessageByName("disableService", fields)
  end
  
  function SystemServiceWrapper:_sinOrSinFromService(sinOrService)
    local sin
    if type(sinOrService) == "table" then
      sin = sinOrService.sin
    else
      sin = sinOrService
    end
    return sin
  end