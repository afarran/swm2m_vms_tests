-- Helm Panel Device base class definition
HelmPanelDevice = {}
  HelmPanelDevice.__index = HelmPanelDevice
  setmetatable(HelmPanelDevice, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function HelmPanelDevice:_init(deviceSW, shellSW)
    self.device = deviceSW
    self.shell = shellSW
  end

  function HelmPanelDevice:setConnected(change)
    self.shell:postEvent(
      self.device.handleName,
      self.device.events.connected,
      change
    )
  end