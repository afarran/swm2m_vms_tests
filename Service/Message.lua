require "UtilLibs/Text"
require "UtilLibs/Table"
require "lunatest"

Message = {}
  Message.__index = Message
  setmetatable(Message, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  
  function Message:_init(args)
    for key, val in pairs(args) do
      self[key] = tonumber(val) or val
    end
  end
  
  --- fields is table of pairs
  -- {fieldname = fieldvalue, fieldname = {assertfunction, fieldvalue, tolerance}}
  
  function Message:_verify(fields)
    local callerInfo = debug.getinfo(2)
    local callerMsg = ", in " .. callerInfo.short_src .. ":" .. callerInfo.currentline
    if fields then
      for fieldName, fieldValue in pairs(fields) do
        if type(fieldValue) == "table" then
          -- first element is assert function
          -- the rest of elements are assert function arguments
          local assertFunc, assertFuncArgs = table.split(fieldValue, 1)
          assertFunc = assertFunc[1]
          assert_true(assertFunc)
          local assertInfo = debug.getinfo(assertFunc)
          if assertFuncArgs[1] ~= nil then
            local msg = "Unexpected value of " .. fieldName .. " = " .. string.safe(self[fieldName]) .. callerMsg
            table.insert(assertFuncArgs, msg)
            assertFunc(self[fieldName], unpack(assertFuncArgs))
          else
            local msg = "Unexpected value of " .. fieldName .. " = " .. string.safe(self[fieldName]) .. callerMsg
            table.insert(assertFuncArgs, msg)
            assertFunc(self[fieldName], unpack(assertFuncArgs))
          end        
        else
          if fieldValue ~= self[fieldName] then
            assert_true(false, "Unexpected value of " .. fieldName .. " = " .. string.safe(self[fieldName]) .. ", expected = " .. string.safe(fieldValue) .. callerMsg)
          end
        end
      end
    else
      return true
    end
  end

  -- compares two messages
  -- compare = {"field1", "field"} limits fields to compare if specified
  -- except = {"field1", "field2"} compare fields except those defined here, explicit to compare
  function Message:_equal(message, compare, except)
    if except then
      except = table.trueList(except)
    end
    if compare then
      compare = table.trueList(compare)
    end
    
    local compared = {}
    local callerInfo = debug.getinfo(2)
    local callerMsg = ", at line " .. callerInfo.currentline .. " in " .. callerInfo.short_src
    
    for fieldName, fieldValue in pairs(self) do
      if ((compare and compare[fieldName]) or (compare == nil and (except == nil or except[fieldName] ~= true))) then
        if fieldValue ~= message[fieldName] then
          assert_true(false, "Incorrect value of " .. fieldName .. " = " .. string.safe(message[fieldName]) .. ", expected = " .. string.safe(fieldValue) .. callerMsg)
        end
      end
      compared[fieldName] = true
    end
    
    for fieldName, fieldValue in pairs(message) do
      if not compared[fieldName] and ((compare and compare[fieldName]) or (compare == nil and (except == nil or except[fieldName] ~= true))) then
        if fieldValue ~= self[fieldName] then
          assert_true(false, "Incorrect value of " .. fieldName .. " = " .. string.safe(self[fieldName]) .. ", expected = " .. string.safe(fieldValue) .. callerMsg)
        end
        compared[fieldName] = true
      end
    end
    
    if compare then
      for fieldName, _ in pairs(compare) do
        if compared[fieldName] ~= true then
          assert_true(false, "Compare field " .. fieldName .. " is missing" .. callerMsg)
        end
      end
    end    
  end

--[[
function assertff(...) 
  print(...)
end

local m = Message({a = "", b =2})
--local asserf(
m:_verify(
  {a= {assert_equal, "s"}
})


local m = Message({a = "", b =2})
local n = Message({a = "", b =34, c=5})
m:_equal(n)

--]]