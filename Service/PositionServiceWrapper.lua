require "Service/ServiceWrapper"
PositionServiceWrapper = {}
  PositionServiceWrapper.__index = PositionServiceWrapper
  setmetatable(PositionServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function PositionServiceWrapper:_init()
    local sourceEnum = {IDPModem = 0}
    local fixTypeEnum = {"2D" = 0, "3D" = 1}
    local fixModeEnum = {GPS = 0, GLONASS = 1}
    local modeEnum = {GPS = 0, GLONASS = 1}
    local jammingIndEnum = {Unknown = 0, OK = 1, Warning = 2, Critical = 3}
    
    local properties = {
      { name ="source", pin=1, ptype="enum"},
      { name ="fixValid", pin=2, ptype="boolean"},
      { name ="fixType", pin=3, ptype="enum"},
      { name ="reserved1", pin=4, ptype="signedint"},
      { name ="reserved2", pin=5, ptype="signedint"},
      { name ="latitude", pin=6, ptype="signedint"},
      { name ="longitude", pin=7, ptype="signedint"},
      { name ="altitude", pin=8, ptype="signedint"},
      { name ="speed", pin=9, ptype="unsignedint"},
      { name ="heading", pin=10, ptype="unsignedint"},
      { name ="fixTime", pin=11, ptype="signedint"},
      { name ="fixAge", pin=12, ptype="unsignedint"},
      { name ="fixMode", pin=13, ptype="enum"},
      { name ="mode", pin=14, ptype="enum"},
      { name ="continuous", pin=15, ptype="unsignedint"},
      { name ="jammingInd", pin=16, ptype="enum"},
      { name ="jammingFlag", pin=17, ptype="boolean"},
      { name ="jammingRaw", pin=18, ptype="unsignedint"},
      { name ="acquireTimeout", pin=19, ptype="unsignedint"},
      { name ="maxFixTimeout", pin=20, ptype="unsignedint"},
      { name ="metricSpeed", pin=21, ptype="unsignedint"},
      { name ="hdop", pin=24, ptype="unsignedint"},
      { name ="numSats", pin=25, ptype="unsignedint"},
    }
          
    local messages_from = {{ name ="position", min=1},
                           { name ="sources", min=2},
                          }
    
    local messages_to = { { name ="getPosition", min=1},
                          { name ="getLastPosition", min=2},
                          { name ="getSources", min=3},
                        }
      
    ServiceWrapper._init(self, {
        sin = 20, 
        name = "Position", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties
    })
  end
