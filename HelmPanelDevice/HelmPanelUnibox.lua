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

