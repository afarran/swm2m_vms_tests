module("TextUtils", package.seeall)

printf = function(string, ...)
          return io.write(s:format(...))
        end
  
string.split = function(str, separator)
  local remaining_str = str
  local result = {}

  while string.len(remaining_str) > 0 do
    local first, last = string.find(remaining_str, separator)
    if not first then 
      result[#result+1] = remaining_str 
      break
    end
    local substr = string.sub(remaining_str, 0, first-1)
    result[#result+1] = substr
    remaining_str = string.sub(remaining_str, last+1)
  end
  return result
end

string.safe = function(str)
  if str == nil then
    return "nil"
  elseif type(str) == "function" then
    return "function"
  elseif type(str) == "table" then
    return "table"
  elseif str == true then
    return "true"
  elseif str == false then
    return "false"
  else
    return str
  end
end

string.tableAsList = function(inTable)
  local msg = ""
  if inTable then
    for key, val in pairs(inTable) do
      msg = msg .. "[" .. key .. "] = " .. string.safe(val) .. " "
    end
  end
  return msg
end

string.listAsRow = function(inList)
  local msg = ""
  if inList then
    for index, val in pairs(inList) do
      msg = msg .. string.safe(val) .. " "
    end
  end
  return msg
end