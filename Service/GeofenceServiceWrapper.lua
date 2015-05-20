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
  
  function GeofenceServiceWrapper:_init(gpsConversion, distanceConversion)
    -- Check if dependencies are met
    self:_addDependency("GPS")
    
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
    
    -- default values, may be incorrect, will be overwritten if setProperties is called
    self.interval = 300
    self.hysteresis = 60
    self.gpsConversion = gpsConversion or 60000
    self.distanceConversion = distanceConversion or 1000
  end
    
  function GeofenceServiceWrapper:getProcessTime()
    return self.interval + self.hysteresis + 1
  end
  
  function GeofenceServiceWrapper:setProperties(pinValues, raw, save)
    local interval_pin = self:getPin("interval")
    local hysteresis_pin = self:getPin("hysteresis")
    if pinValues[interval_pin] then
      self.interval = pinValues[interval_pin]
    end
    if pinValues[hysteresis_pin] then
      self.hysteresis = pinValues[hysteresis_pin]
    end
    return ServiceWrapper.setProperties(self, pinValues, raw, save)
  end
  
  function GeofenceServiceWrapper:__normalizeGPS(value)
    return value * self.gpsConversion
  end
  
  function GeofenceServiceWrapper:__normalizeDistance(value)
    return value * self.distanceConversion
  end
  
  --- Sets new fence in geofence module. 
  -- Uses setRectangle message
  -- @tparam table zone
  -- @param zone.number id number of fence
  -- @param zone.centerLatitude center latitude in degrees
  -- @param zone.centerLongitude center longitude in degrees
  -- @param zone.latitudeDistance distance from center latitude in kilomenters
  -- @param zone.longitudeDistance distance from center longitude in kilomenters
  -- @tparam boolean zone.enabled disable or enable fence
  -- @tparam string zone.alarm when to alarm, enum Both
  function GeofenceServiceWrapper:setRectangle(zone)
    local number = zone.number or 0
    local centerLatitude = self:__normalizeGPS(zone.centerLatitude)
    local centerLongitude = self:__normalizeGPS(zone.centerLongitude)
    local latitudeDistance = self:__normalizeDistance(zone.latitudeDistance)
    local longitudeDistance = self:__normalizeDistance(zone.longitudeDistance)
    local enabled = zone.enabled or true
    local alarm = zone.alarm or "Both" --(both - on entry alarm and on exit alarm)
    
    local Fields = {{Name="number",Value=number},
                    {Name="enabled",Value=enabled},
                    {Name="alarmCondition",Value=alarm},
                    {Name="centreLatitude",Value=centerLatitude},
                    {Name="centreLongitude",Value=centerLongitude},
                    {Name="latitudeDistance",Value=latitudeDistance},
                    {Name="longitudeDistance",Value=longitudeDistance}}
                  
    self:sendMessageByName("setRectangle", Fields)
    self:log("New zone set " .. string.tableAsList(zone))
  end

  function GeofenceServiceWrapper:enableFence(number)
    local Fields = {{Name="number",Value=number},{Name="enable",Value=true}}
    self:sendMessageByName("enableFence", Fields)
    self:log("Fence " .. number .. " enabled")
  end

  function GeofenceServiceWrapper:disableFence(number)
    local Fields = {{Name="number",Value=number},{Name="enable",Value=false}}
    self:sendMessageByName("enableFence", Fields)
    self:log("Fence " .. number .. " disabled")
  end
  
  --- Sets GPS position to inside geofence zone.
  -- @{zone} - @{setRectangle}
  -- @tparam zone zone
  -- @tparam table gpsInfo 
  -- @tparam number gpsInfo.speed
  -- @tparam number gpsInfo.heading
  -- @tparam number delay in seconds
  function GeofenceServiceWrapper:goInside(zone, gpsInfo, delay)
    self:log("Going inside geofence zone " .. zone.number)
    gpsInfo = gpsInfo or {}
    GPS:set({latitude = zone.centerLatitude, longitude = zone.centerLongitude, heading = gpsInfo.heading, speed = gpsInfo.speed})
    geofenceSW:waitForRefresh(delay)
  end
  
  function GeofenceServiceWrapper:getDelay()
    return self.hysteresis + self.interval    
  end
  
  function GeofenceServiceWrapper:goOutside(delay)
    -- assume that this is point outside all defined geofences
    self:log("Going outside all geofences")
    GPS:set({latitude = -89, longitude = -179})
    self:waitForRefresh(delay)
  end
  
  --- Waits till all geofence calculations are completed
  -- including gps setting and processing time
  function GeofenceServiceWrapper:waitForRefresh(delay)
    delay = delay or GPS:getFullDelay(self:getDelay())
    self:log("Waiting " .. delay .. "s for geofence refresh")
    framework.delay(delay)
  end