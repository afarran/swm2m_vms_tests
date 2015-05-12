cfg, framework, gateway, lsf, device, gps = require "TestFramework"()
require "UtilLibs/Text"
require "UtilLibs/Array"
require "UtilLibs/Number"
require "Service/Message"


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

  -- args is a table of named arguments,
  -- args.sin - service SIN
  -- args.name - service name
  -- args.properties - property definition
  -- args.messages_to - TO-MOBILE message definitions
  -- args.messages_from - FROM-MOBILE message definitions
  function ServiceWrapper:_init(args)
    self.sin = args.sin
    self.name = args.name
    -- ptype can be set to: unsignedint, signedint, string, boolean, enum, data
    self.properties = args.properties
    self.bitmaps = self:__processBitmaps(args.bitmaps)
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
    if pin_type == "boolean" then
      if raw_value then
        encoded_value = "True"
      else
        encoded_value = "False"
      end
    end

    return encoded_value
  end

  function ServiceWrapper:__processBitmaps(bitmaps)
    if not bitmaps then return {} end
    local result = {}
    for bitmap_name, bitmap in pairs(bitmaps) do
      result[bitmap_name] = {}
      result[bitmap_name].names = bitmap
      result[bitmap_name].bits = reverseMap(bitmap)
    end
    return result
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
  function ServiceWrapper:setProperties(pinValues, raw, save)
    raw = raw or false
    local pinValueTypes = {}
    for pin, value in pairs(pinValues) do
      if raw then
        pinValueTypes[#pinValueTypes + 1] = {pin, value, self.pins_types[pin]}
      else
        pinValueTypes[#pinValueTypes + 1] = {pin, self:__encodePinValue(pin, value), self.pins_types[pin]}
      end
    end

    return lsf.setProperties(self.sin, pinValueTypes, save)
  end

  -- {pinname = val1, pinname2 = val2}
  function ServiceWrapper:setPropertiesByName(propertyValues, raw, save)
    local pinValues = {}
    for pinName, value in pairs(propertyValues) do
      pinValues[self:getPin(pinName)] = value
    end
    return self:setProperties(pinValues, raw, save)
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

  function ServiceWrapper:getMinTo(name)
    local min = self.mins_to_named[name]
    if not min then
      printf("Can't find min %s\n", name)
    end
    return min
  end

  function ServiceWrapper:getMinToName(min)
    local min_name = self.mins_to[min]
    if not min_name then
      printf("Can't find min %d\n", min)
    end
    return min_name
  end

    function ServiceWrapper:getMinFrom(name)
    local min = self.mins_from_named[name]
    if not min then
      printf("Can't find min %s\n", name)
    end
    return min
  end

  function ServiceWrapper:getMinFromName(min)
    local min_name = self.mins_from[min]
    if not min_name then
      printf("Can't find min %d\n", min)
    end
    return min_name
  end

  function ServiceWrapper:sendMessage(min, fields)
    local message = {}
    message.SIN = self.sin
    message.MIN = min
    message.Fields = fields
    gateway.submitForwardMessage(message)
  end

  function ServiceWrapper:sendMessageByName(message_name, fields)
    local min = self:getMinTo(message_name)
    self:sendMessage(min, fields)
  end

  -- e.g. usage ("PollRequest1", nil, "PollResponse1")
  function ServiceWrapper:requestMessageByName(request_message_name, fields, response_message_names, timeout)
    local previous_watermark = self:getHighWaterMark()
    
    self:setHighWaterMark()
    self:sendMessageByName(request_message_name, fields)
    
    local response
    if type(response_message_names) ~= "table" then
      response_message_names = {response_message_names}
    end
    response = self:waitForMessagesByName(response_message_names, timeout)
    self:setHighWaterMark(previous_watermark)
    return response
  end

  --retrieved message list can be accessed via indexes - list[min] or by message name list.getByName("min_name")
  function ServiceWrapper:waitForMessages(expectedMins, timeout)
    if type(expectedMins) ~= "table" then
      expectedMins = {expectedMins}
    end
    timeout = tonumber(timeout) or GATEWAY_TIMEOUT

    local msgList = {count = 0}

      local function UpdateMsgMatchingList(msg)
        if msg then   --TODO: why would this function be called with no msg?
          for idx, min in pairs(expectedMins) do
            if msg.Payload and min == msg.Payload.MIN and msg.SIN == self.sin and msgList[min] == nil then
              msgList[self:getMinFromName(min)] = Message(framework.collapseMessage(msg).Payload)
              msgList.count = msgList.count + 1
              break
            end
          end
        end
        return #expectedMins == msgList.count
      end
    gateway.getReturnMessage(UpdateMsgMatchingList, nil, timeout)

    msgList.getByMin = function(id)
        local min_name = self:getMinFromName(id)
        if min_name then
          return msgList[min_name]
        else
          printf("Received message has unknown min %s (missing min from mins_from?)\n", min_name)
          return nil
        end
      end

    return msgList
  end

  function ServiceWrapper:waitForMessagesByName(expectedMessages, timeout)
    local expectedMins = {}
    if type(expectedMessages) == "table" then
      for idx, name in pairs(expectedMessages) do
        expectedMins[idx] = self:getMinFrom(name)
      end
    else
      expectedMins = self:getMinFrom(expectedMessages)
    end
    return self:waitForMessages(expectedMins, timeout)
  end

  function ServiceWrapper:waitForProperties(property_values, timeout, sleep)
    sleep = sleep or 1
    timeout = timeout or DEFAULT_TIMEOUT or 60
    local current_properties = {}
    local valid = false
    local request_properties = {}
    for property_name, property_value in pairs(property_values) do
      request_properties[#request_properties+1] = property_name
    end

    local start_time = os.time()
    current_properties = self:getPropertiesByName(request_properties)
    while not valid do
      valid = true
      for property_name, property_value in pairs(property_values) do
        if property_value ~= current_properties[property_name] then
          valid = false
          break
        end
      end
      if not valid then
        framework.delay(sleep)
        current_properties = self:getPropertiesByName(request_properties)
      end
      if (os.time() - start_time) >  timeout then break end
    end
    return valid, current_properties
  end

  function ServiceWrapper:decodeBitmap(value, bitmap)
    local bitmap_name = "Undefined"
    if type(bitmap) == "string" then
      bitmap_name = bitmap
      bitmap = self.bitmaps[bitmap_name]
    end
    if type(value) == "string" then
      value = tonumber(value)
    end
    local bitset = decimalToBinary(value)
    local result = {}

    for index, value in pairs(bitset) do
      if value == 1 then
        local state = bitmap.bits[index-1]
        if not state then
          printf("Missing bit definition %d in bitmap %s", index-1, bitmap_name)
        end
        -- if adequate state cant be find in bitmap, save it as bit index inestead of state name
        if not state then state = index-1 end
        result[state] = true
      end
    end
    return result
  end

  function ServiceWrapper:encodeBitmap(values, bitmap)
    local bitmap_name = "Undefined"
    if type(bitmap) == "string" then
      bitmap_name = bitmap
      bitmap = self.bitmaps[bitmap_name]
    end
    local bitset = {}
    for idx, bit_name in pairs(values) do
      local bit_position = bitmap.names[bit_name]
      if not bit_position then
        printf("Bit name %s not present in bitmap %s configuration!", bit_name, bitmap_name)
        return nil
      end
      bitset[bit_position+1] = 1
    end
    return binaryToDecimal(bitset)
  end
  
  function ServiceWrapper:setHighWaterMark(_date)
    return gateway.setHighWaterMark(_date)    
  end
  
  function ServiceWrapper:getHighWaterMark()
    return gateway.getHighWaterMark()
  end

  function ServiceWrapper:getServicePath()
    if self.sin > 128 then
      return "/act/user/" .. self.name .. "/"
    else
      return "/act/svc/" .. self.name .. "/"
    end
  end

