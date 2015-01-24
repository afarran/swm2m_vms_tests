-- Helm Panel Device interface definition
IHelmPanelDevice = {}
  IHelmPanelDevice.__index = IHelmPanelDevice
  setmetatable(IHelmPanelDevice, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function IHelmPanelDevice:_init()
  end

  function IHelmPanelDevice:setConnected() end



