cfg, framework, gateway, lsf, device, gps = require "TestFramework"()
require "UtilLibs/Text"
require "UtilLibs/Array"


ServiceWrapper = {}
  ServiceWrapper.__index = ServiceWrapper
  setmetatable(ServiceWrapper, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})
  
  function ServiceWrapper:__processProperties(properties)
    properties = properties or {}
    local pins = {}
    local pins_named = {}
    local pins_types = {}
    local pins_enums = {}
    local pins_enums_named = {}
    for index, tuple in pairs(properties) do
      pins_named[tuple.name] = tuple.pin
      pins[tuple.pin] = tuple.name
      pins_types[tuple.pin] = tuple.ptype
      pins_enums[tuple.pin] = reverseMap(tuple.enums)
      pins_enums_named[tuple.pin] = tuple.enums
    end
    return pins, pins_named, pins_types, pins_enums, pins_enums_named
  end
  
  function ServiceWrapper:__processMessages(messages)
    messages = messages or {}
    local mins = {}
    local mins_named = {}
    for index, tuple in pairs(messages) do
      mins[tuple.min] = tuple.name
      mins_named[tuple.name] = tuple.min
    end
    return mins, mins_named
  end
  
  function ServiceWrapper:_init(args)
    self.sin = args.sin
    self.name = args.name
    -- ptype can be set to: unsignedint, signedint, string, boolean, enum, data
    self.properties = args.properties
    
    self.messages_to = args.messages_to or {}
    self.messages_from = args.messages_from or {}
    self.pins, self.pins_named, self.pins_types, self.pins_enums, self.pins_enums_named = self:__processProperties(self.properties)
    self.mins_to, self.mins_to_named = self:__processMessages(self.messages_to)
    self.mins_from, self.mins_from_named = self:__processMessages(self.messages_from)
    printf("ServiceWrapper %s initialized. SIN %d\n", self.name, self.sin )
  end
  
  function ServiceWrapper:__decodePinValue(pin, raw_value)
    local decoded_value = raw_value
    local pin_type = self.pins_types[pin]
    if pin_type == "enum" then
      decoded_value = self.pins_enums[pin][tonumber(raw_value)]
    elseif pin_type == "string" then
      -- do nothing
    elseif pin_type == "data" then
      -- do nothing
    elseif pin_type == "boolean" then
      -- map string to boolean
      if raw_value == "False" then 
        decoded_value = false 
      else
        decoded_value = true
      end
    else
      decoded_value = tonumber(decoded_value)
    end
    
    return decoded_value
  end
  
  function ServiceWrapper:__encodePinValue(pin, raw_value)
    local encoded_value = raw_value
    local pin_type = self.pins_types[pin]
    
    if pin_type == "enum" then
      encoded_value = self.pins_enums_named[pin][raw_value]
    end
    
    return encoded_value
  end
  
  function ServiceWrapper:__processPinValues(pinValues)
    local result = {}
    for pin, value in pairs(pinValues) do          
      result[self:getPinName(pin)] = self:__decodePinValue(pin, value)
    end
    return result
  end
  
  function ServiceWrapper:getProperties(pinList, raw)
    raw = raw or false
    if raw then
      return propertiesToTable(lsf.getProperties(self.sin, pinList))
    else
      return self:__processPinValues(propertiesToTable(lsf.getProperties(self.sin, pinList)))
    end
  end
  
  function ServiceWrapper:getPropertiesByName(propertiesList, raw)
    local pinList = {}
    for index, propertyName in pairs(propertiesList) do
      pinList[#pinList + 1] = self:getPin(propertyName)
    end
    return self:getProperties(pinList, raw) 
  end
  
  -- pinValues = {pin1 = val1, pin2 = val2}
  function ServiceWrapper:setProperties(pinValues, raw)
    raw = raw or false
    local pinValueTypes = {}
    for pin, value in pairs(pinValues) do
      if raw then
        pinValueTypes[#pinValueTypes + 1] = {pin, value, self.pins_types[pin]}
      else
        pinValueTypes[#pinValueTypes + 1] = {pin, self:__encodePinValue(pin, value), self.pins_types[pin]}
      end
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
  
    
  function ServiceWrapper:getPin(name)
    local result = self.pins_named[name]
    if not result then
      printf("Can't find pin %s\n", name)
    end
    return result
  end

  function ServiceWrapper:getPinName(pin)
    local result = self.pins[pin]
    if not result then
      printf("Can't find pin name %d\n", pin)
    end
    return result
  end
  
  function ServiceWrapper:sendMessage(min, fields)
    local message = {}
    message.SIN = self.sin
    message.MIM = min
    message.Fields = fields
    gateway.submitForwardMessage(message)
  end
  
  function ServiceWrapper:sendMessageByName(message_name, fields)
    
    local min = self.mins_named.from[message_name]
    if not message.MIN then
      printf("Can't find min %s\n", message_name)
      return nil
    end
    self:sendMessage(message_name, fields)    
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
