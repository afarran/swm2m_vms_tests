cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

require("Serial/ShellWrapper")

SmtpWrapper = {}
  SmtpWrapper.__index = SmtpWrapper
  setmetatable(SmtpWrapper, {
    __index = ShellWrapper, -- this is what makes the inheritance work
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function SmtpWrapper:start()
    local response = self:request("")
    if not string.match(response, ".*mail>") then
      self:request("mail")
    else
      self:execute("smtp")
    end
  end
