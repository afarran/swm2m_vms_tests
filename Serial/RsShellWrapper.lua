cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

RsShellWrapper = {}
  RsShellWrapper.__index = RsShellWrapper
  setmetatable(RsShellWrapper, {
    __index = ShellWrapper, -- this is what makes the inheritance work
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})
  
  function RsShellWrapper:start()
    local response = self:request("")
    if string.match(response, ".*mail>") then
      self:request("shell")
    end
  end
