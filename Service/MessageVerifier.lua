require "Service/VerifiableTable"

MessageVerifier = {}
  MessageVerifier.__index = MessageVerifier
  setmetatable(MessageVerifier, {
    __index = VerifiableTable, -- this is what makes the inheritance work
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  
  function MessageVerifier:_init(args)
    for key, val in pairs(args) do
      self[key] = tonumber(val) or val
    end
    VerifiableTable._init(self, args)
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