require "UtilLibs/Text"
require "UtilLibs/Table"
require "lunatest"

VerifiableTable = {}
  VerifiableTable.__index = VerifiableTable
  setmetatable(VerifiableTable, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  
  function VerifiableTable:_init(args)
    
  end
  
  --- fields is table of pairs
  -- {fieldname = fieldvalue, fieldname = {assertfunction, fieldvalue, tolerance}}
  function VerifiableTable:_verify(fields)
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
  function VerifiableTable:_equal(comparedTable, compareFields, exceptFields)
    if exceptFields then
      exceptFields = table.trueList(exceptFields)
    end
    if compareFields then
      compareFields = table.trueList(compareFields)
    end
    
    local compared = {}
    local callerInfo = debug.getinfo(2)
    local callerMsg = ", at line " .. callerInfo.currentline .. " in " .. callerInfo.short_src
    
    for fieldName, fieldValue in pairs(self) do
      if ((compareFields and compareFields[fieldName]) or (compareFields == nil and (exceptFields == nil or exceptFields[fieldName] ~= true))) then
        if fieldValue ~= comparedTable[fieldName] then
          assert_true(false, "Incorrect value of " .. fieldName .. " = " .. string.safe(comparedTable[fieldName]) .. ", expected = " .. string.safe(fieldValue) .. callerMsg)
        end
      end
      compared[fieldName] = true
    end
    
    for fieldName, fieldValue in pairs(comparedTable) do
      if not compared[fieldName] and ((compareFields and compareFields[fieldName]) or (compareFields == nil and (exceptFields == nil or exceptFields[fieldName] ~= true))) then
        if fieldValue ~= self[fieldName] then
          assert_true(false, "Incorrect value of " .. fieldName .. " = " .. string.safe(self[fieldName]) .. ", expected = " .. string.safe(fieldValue) .. callerMsg)
        end
        compared[fieldName] = true
      end
    end
    
    if compareFields then
      for fieldName, _ in pairs(compareFields) do
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