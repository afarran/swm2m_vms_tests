cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

require("Serial/ShellWrapper")

Pop3Wrapper = {}
  Pop3Wrapper.__index = Pop3Wrapper
  setmetatable(Pop3Wrapper, {
    __index = ShellWrapper, -- this is what makes the inheritance work
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function Pop3Wrapper:start()
    local response = self:request("")
    if not string.match(response, ".*mail>") then
      self:request("mail")
    end
    self:execute("pop3")
  end
