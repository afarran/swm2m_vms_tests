Profile =  require("Profile/Profile")

----------------------------------------------------------------------
-- Profile for device 690
----------------------------------------------------------------------
Profile690 = {}
  Profile690.__index = Profile690
  setmetatable(Profile690, {
    __index = Profile, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })

