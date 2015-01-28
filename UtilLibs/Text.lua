module("TextUtils", package.seeall)

printf = function(string, ...)
          return io.write(s:format(...))
        end
        
string.split = function(str, separator)
    local result = {}
    for word in string.gmatch(str, '([^'.. separator .. ']+)') do
      result[#result+1] = word
    end
    return result
  end