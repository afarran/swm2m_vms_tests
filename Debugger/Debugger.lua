-- Debugg features

DEBUG_MODE = 1

Debugger = {}
  Debugger.__index = Debugger
  setmetatable(Debugger, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function Debugger:_init()
  end
 
  -- if will be more sophisticated soon .. 
  function Debugger:log(info,tag)
    if type(info) == "table" or type(info) == "boolean" then 
      info = framework.dump(info) 
    elseif type(info) == "function" then
      info = "function"
    end
    if info == nil then info = "nil" end
    if not tag then tag="info" end
    if DEBUG_MODE == 1 then
      print(tag.." | "..info)
    end 
  end
