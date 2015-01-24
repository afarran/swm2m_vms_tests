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

