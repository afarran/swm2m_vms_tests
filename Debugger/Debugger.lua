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
    if not tag then tag="info" end
    if DEBUG_MODE == 1 then
      print(tag.." | "..info)
    end 
  end
