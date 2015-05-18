require "Service/ServiceWrapper"

InterfaceUnitHelpServiceWrapper = {}
  InterfaceUnitHelpServiceWrapper.__index = InterfaceUnitHelpServiceWrapper
  setmetatable(InterfaceUnitHelpServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })

  function InterfaceUnitHelpServiceWrapper:_init()

    local statesSet1 = {
      OFF = 0,
      SLOW_FLASH  = 1,
      FAST_FLASH = 2,
      ON = 3
    }

    local properties = {
      { name ="led1State", pin=2, ptype="enum", enums=statesSet1},
      { name ="led2State", pin=3, ptype="enum", enums=statesSet1},
      { name ="led3State", pin=4, ptype="enum", enums=statesSet1},
      { name ="led4State", pin=5, ptype="enum", enums=statesSet1},
      { name ="uniboxConnected", pin=12, ptype="boolean"},

    }

    ServiceWrapper._init(self, {
        sin = 162,
        name = "InterfaceUnitHelpService",
        properties = properties
    })


  end
