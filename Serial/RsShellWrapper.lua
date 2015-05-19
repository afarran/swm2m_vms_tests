cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

Profile =  require("Serial/ShellWrapper")

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
    D:log("RsShellWrapper start.")
    if string.match(response, ".*mail>") then
      D:log("Switching to rs shell")
      self:request("shell")
    end
  end
