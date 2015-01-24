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
    --TODO: is it realy LED 2 ?
    local properties = self.device:getPropertiesByName({"led2State"})
    local state = properties.led2State
    D:log("LED 2 state is "..state)
    if state == 'OFF' then 
      return false
    end
    return true
  end

