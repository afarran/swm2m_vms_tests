--- Function converts property list to table
-- e.g. propList = {{pin = pin1, value = val1}, {pin = pin2, value = val2}}
-- is converted into result = {pin1 = val1, pin2 = val2}
-- @tparam propertyList - list of properties received from getProperties method ({{pin, value}, {pin, value}})
-- @treturn - table of properties where pin determines index and value determines pin value, table of pins
function propertiesToTable(propertyList)
  result = {}
  pins = {}
  for index, property in ipairs(propertyList) do
    result[tonumber(property.pin)] = property.value
    pins[index] = tonumber(property.pin)
  end
  return result, pins
end

function reverseMap(map)
  result = {}
  for key, value in pairs(map) do
    result[value] = key
  end
  return result
end