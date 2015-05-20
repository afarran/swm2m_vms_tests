require "Service/VerifiableTable"

PropertiesVerifier = {}
  PropertiesVerifier.__index = PropertiesVerifier
  setmetatable(PropertiesVerifier, {
    __index = VerifiableTable, -- this is what makes the inheritance work
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  
  function PropertiesVerifier:_init(args)
    for key, val in pairs(args) do
      self[key] = tonumber(val) or val
    end
    VerifiableTable._init(self, args)
  end
  