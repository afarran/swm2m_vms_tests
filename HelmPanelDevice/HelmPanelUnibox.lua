require("HelmPanelDevice/HelmPanelDevice")

HelmPanelUnibox = {}
  HelmPanelUnibox.__index = HelmPanelUnibox
  setmetatable(HelmPanelUnibox, {
    __index = HelmPanelDevice, -- extends base class
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })

  function HelmPanelUnibox:isSateliteLedOn()
    local properties = self.device:getPropertiesByName({"led3State"})
    local state = properties.led3State
    D:log("Sat LED state is "..state)
    if state == 'OFF' then
      return false
    end
    return true
  end

  function HelmPanelUnibox:isGpsLedOn()
    local properties = self.device:getPropertiesByName({"led2State"})
    local state = properties.led2State
    D:log("GPS LED state is "..state)
    if state == 'OFF' then
      return false
    end
    return true
  end

  function HelmPanelUnibox:isConnectLedOn()
    local properties = self.device:getPropertiesByName({"led1State"})
    local state = properties.led1State
    D:log("IDP connect LED state is "..state)
    if state == 'OFF' then
      return false
    end
    return true
  end

  function HelmPanelUnibox:isConnectLedFlashing()
    local properties = self.device:getPropertiesByName({"led1State"})
    local state = properties.led1State
    D:log("IDP connect LED state is "..state)
    if state == 'SLOW_FLASH' or state == 'FAST_FLASH' then
      return true
    end
    return false
  end

  --TODO: should be in HelmPanelDevice but there were problems with reflection in Dependency Resolver
  function HelmPanelUnibox:isReady()
    if self._isReady ~= nill then
      return self._isReady
    end
    local serviceList = self.system:requestMessageByName("getServiceList",nil,"serviceList")
    local disabledList = framework.base64Decode(serviceList.serviceList.disabledList)
    local sinList = framework.base64Decode(serviceList.serviceList.sinList)
 
    local enabled = false
    for i,v in ipairs(sinList) do
      if tonumber(v) == tonumber(self.device.sin) then
        enabled = true
        break
      end
    end
    for i,v in ipairs(disabledList) do
      if tonumber(self.device.sin) == tonumber(v) then
        enabled = false
      end
    end 
    if enabled then
      self._isReady = enabled 
      return true
    end
    self._isReady = "Unibox is not installed!"
    return self._isReady
  end


