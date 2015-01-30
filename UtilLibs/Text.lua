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