-- This class encapsulates logic of interfering with gps via simulator api
-- and logic of gps manipulation , for example moving along given track etc..

GpsFrontend = {}
  GpsFrontend.__index = GpsFrontend
  setmetatable(GpsFrontend, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function GpsFrontend:_init()
    -- default config
    self.GPS_PROCESS_TIME = 1
    self.GPS_READ_INTERVAL = 1
    -- if external config exists
    if GPS_PROCESS_TIME ~=nil then 
      self.GPS_PROCESS_TIME = GPS_PROCESS_TIME 
    end 
    if GPS_READ_INTERVAL ~=nil then
      self.GPS_READ_INTERVAL = GPS_READ_INTERVAL
    end
  end
  
  function GpsFrontend:setProcessTime(gpsProcessTime)
    self.GPS_PROCESS_TIME = gpsProcessTime
  end
  
  function GpsFrontend:setReadInterval(gpsReadInterval)
    self.GPS_READ_INTERVAL = gpsReadInterval
  end
  
  function GpsFrontend:set(position, delay)
    gps.set(position)    
    if delay == nil then
      framework.delay(self.GPS_PROCESS_TIME + self.GPS_READ_INTERVAL)
    end
  end
  
  function GpsFrontend:simulateTrack(trackInfo)
    --TODO
  end
  
  function GpsFrontend:normalize(value)
    return tonumber(value) / 60000
  end
  
  function GpsFrontend:denormalize(value)
    return tonumber(value) * 60000
  end
  
  -- from km/h to knots 
  function GpsFrontend:denormalizeSpeed(value)
    return tonumber(value) * 5.39957
  end
  
  -- from knots to km/h
  function GpsFrontend:normalizeSpeed(value)
    return tonumber(value) * 0.1852
  end