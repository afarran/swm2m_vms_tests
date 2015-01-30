-- Helm Panel Device base class definition
HelmPanelDevice = {}
  HelmPanelDevice.__index = HelmPanelDevice
  setmetatable(HelmPanelDevice, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function HelmPanelDevice:_init(deviceSW, shellSW, systemSW)
    self.device = deviceSW
    self.shell = shellSW
    self.system = systemSW
  end

  function HelmPanelDevice:setConnected(change)
    self.shell:postEvent(
      self.device.handleName,
      self.device.events.connected,
      change
    )
  end

  function HelmPanelDevice:externalPowerConnected(change)
    self.shell:postEvent(
      self.device.handleName,
      self.device.events.external_power_connected,
      change
    )
  end

  function HelmPanelDevice:isReady()
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
    self._isReady = "HelmPanel device is not installed!"
    return self._isReady
  end

  -- abstract methods
  function HelmPanelDevice:isSateliteLedOn() end
  function HelmPanelDevice:isGpsLedOn() end
  function HelmPanelDevice:isConnectLedOn() end
