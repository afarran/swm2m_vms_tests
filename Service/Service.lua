module("Service", package.seeall)

cfg, framework, gateway, lsf, device, gps = require "TestFramework"()
require "Service/TextUtils"
require "Service/ArrayUtils"


local ServiceWrapper = {}
  ServiceWrapper.__index = ServiceWrapper
  setmetatable(ServiceWrapper, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})
  
  function ServiceWrapper:getPin(name)
    local result = self.pins_named[name]
    return result
  end

  function ServiceWrapper:getPinName(pin)
    local result = self.pins[pin]
    return result
  end
  
  function ServiceWrapper:__processProperties(properties)
    pins = {}
    pins_named = {}
    pins_types = {}
    for index, tuple in pairs(properties) do
      pins_named[tuple.name] = tuple.pin
      pins[tuple.pin] = tuple.name
      pins_types[tuple.pin] = tuple.ptype
    end
    return pins, pins_named, pins_types
  end
  
  function ServiceWrapper:_init(args)
    self.sin = args.sin
    self.name = args.name
    self.properties = args.properties
    
    self.mins = args.mins or {}
    self.pins, self.pins_named, self.pins_types = self:__processProperties(self.properties)
    printf("ServiceWrapper %s initialized. SIN %d\n", self.name, self.sin )
  end
  
  function ServiceWrapper:matchReturnMessages(expectedMins, timeout)
    if type(expectedMins) ~= "table" then 
      expectedMins = {expectedMins}
    end
    timeout = tonumber(timeout) or GATEWAY_TIMEOUT

    local msgList = {count = 0}

      local function UpdateMsgMatchingList(msg)
        if msg then   --TODO: why would this function be called with no msg?
          for idx, min in pairs(expectedMins) do
            if msg.Payload and min == msg.Payload.MIN and msg.SIN == self.sin and msgList[min] == nil then
              msgList[min] = framework.collapseMessage(msg).Payload
              msgList.count = msgList.count + 1
              break
            end
          end
        end
        return #expectedMins == msgList.count
      end
    gateway.getReturnMessage(UpdateMsgMatchingList, nil, timeout)
    return msgList
  end
  
  function ServiceWrapper:_processPinValues(pinValues)
    local result = {}
    for pin, value in pairs(pinValues) do
      --result[self.pins[pin]] = value
      result[self:getPinName(pin)] = value
    end
    return result
  end
  
  function ServiceWrapper:getProperties(pinList)
    return self:_processPinValues(propertiesToTable(lsf.getProperties(self.sin, pinList)))
  end
  
  function ServiceWrapper:getPropertiesByName(propertiesList)
    local pinList = {}
    for index, propertyName in pairs(propertiesList) do
      pinList[#pinList + 1] = self:getPin(propertyName)
    end
    return self:getProperties(pinList) 
  end
  
  -- pinValues = {pin1 = val1, pin2 = val2}
  function ServiceWrapper:setProperties(pinValues)
    local pinValueTypes = {}
    for pin, value in pairs(pinValues) do
      pinValueTypes[#pinValueTypes + 1] = {pin, value, self.pins_types[pin]}
    end
    
    return lsf.setProperties(self.sin, pinValueTypes)
  end

  -- {pinname = val1, pinname2 = val2}
  function ServiceWrapper:setPropertiesByName(propertyValues)
    local pinValues = {}
    for pinName, value in pairs(propertyValues) do
      pinValues[self:getPin(pinName)] = value
    end
    return self:setProperties(pinValues)
  end
  
--------------------------------

PositionServiceWrapper = {}
  PositionServiceWrapper.__index = PositionServiceWrapper
  setmetatable(PositionServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function PositionServiceWrapper:_init()
    local properties = {{name = "latitude", pin = 6},
                  {name = "longitude", pin = 7},
                  {name = "heading", pin = 10, ptype="unsignedint"},
                  {name = "continuous", pin = 15, ptype="unsignedint"},
                 }
    ServiceWrapper:_init({sin = 20, name = "Position", mins = {}, properties = properties})
  end



-- test
position = PositionServiceWrapper()
-- a = service:getPropertiesByName({"latitude", "longitude"})

a = position:getPropertiesByName({"latitude", "longitude"})
position:setPropertiesByName({latitude = 1, continuous = 1})
a = position:getPropertiesByName({"latitude", "continuous"})
print(a)


