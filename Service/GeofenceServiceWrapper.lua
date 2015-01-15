require "Service/ServiceWrapper"

GeofenceServiceWrapper = {}
  GeofenceServiceWrapper.__index = GeofenceServiceWrapper
  setmetatable(GeofenceServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function GeofenceServiceWrapper:_init()
    
    -- Possible types: "unsignedint"  "signedint"  "enum"  "string"  "boolean"  "data"
    
    local properties = {
      { name ="enabled", pin=1, ptype="boolean"},
      { name ="interval", pin=2, ptype="unsignedint"},
      { name ="hysteresis", pin=3, ptype="unsignedint"},
      { name ="sendAlarm", pin=4, ptype="boolean"},
      { name ="logAlarm", pin=5, ptype="boolean"},
      { name ="fileName", pin=6, ptype="string"},
      { name ="reserved1", pin=7, ptype="boolean"},
      { name ="reserved2", pin=8, ptype="unsignedint"},
      { name ="reserved3", pin=9, ptype="unsignedint"},
      { name ="reserved4", pin=10, ptype="unsignedint"},
      { name ="reserved5", pin=11, ptype="unsignedint"},
      { name ="reserved6", pin=12, ptype="unsignedint"},
      { name ="reserved7", pin=13, ptype="unsignedint"},
      { name ="reserved8", pin=14, ptype="unsignedint"},
      { name ="reserved9", pin=15, ptype="unsignedint"},
      { name ="entryHysteresis", pin=16, ptype="unsignedint"},
      { name ="exitHysteresis", pin=17, ptype="unsignedint"},
      { name ="combineMessages", pin=18, ptype="boolean"},
      { name ="combineEvents", pin=19, ptype="boolean"},
      { name ="maxAge", pin=20, ptype="unsignedint"},
      { name ="timeout", pin=21, ptype="unsignedint"},
      { name ="cacheFences", pin=22, ptype="boolean"},
      { name ="checkDoneEvents", pin=23, ptype="boolean"},
    }
    
    local messages_from = {
      { name ="alarm", min=1},
      { name ="fenceStatus", min=2},
      { name ="allFencesStatus", min=3},
      { name ="alarms", min=4},
    }
    local messages_to = {
      { name ="setCircle", min=1},
      { name ="setPolygon", min=2},
      { name ="enableFence", min=3},
      { name ="updateAlarmCond", min=4},
      { name ="getStatus", min=5},
      { name ="getAllStatus", min=6},
      { name ="setRectangle", min=7},
    }
    
    local bitmaps = {}
    
    ServiceWrapper._init(self, {
        sin = 21, 
        name = "Geofence", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties,
        bitmaps = bitmaps,
    })
  end
