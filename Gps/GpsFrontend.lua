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
  
  --- Generatos random GPS fix
  -- @treturn table position
  function GpsFrontend:getRandom()
    local result = {}
    
    result.latitude = lunatest.random_float(-90, 90)
    result.longitude = lunatest.random_float(-180, 180)
    result.heading = lunatest.random_int(0, 359)
    result.speed = lunatest.random_int(0, 200)
    
    return result
  end
  
  function GpsFrontend:set(position, delay)
    D:log("New GPS position: " .. string.tableAsList(position))
    gps.set(position)    
    if delay then
      framework.delay(delay)
    else
      framework.delay(self.GPS_PROCESS_TIME + self.GPS_READ_INTERVAL)
    end
  end

  function GpsFrontend:setRandom(delay)
    local gpsPosition = {
      latitude  = lunatest.random_int (1, 9),
      longitude = lunatest.random_int (1, 9),
      speed =  lunatest.random_int (1, 9)
    }
    self:set(gpsPosition,delay)
    return gpsPosition
  end
  
  --- Returns a sum of all GPS delays.
  -- Including position service read interval
  -- @treturn number sum of GPS delays
  function GpsFrontend:getFullDelay(additionalDelay)
    local processTime = self.GPS_PROCESS_TIME or 0
    local readInterval = self.GPS_READ_INTERVAL or 0
    additionalDelay = additionalDelay or 0
    
    return processTime + readInterval + additionalDelay
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
  
  function GpsFrontend:miliMinutes2Degrees(value)
    return tonumber(value) / 60000
  end
  
  function GpsFrontend:degrees2MiliMinutes(value)
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
  
  function GpsFrontend:geoDistance(lat1, lon1, lat2, lon2)
    if lat1 == nil or lon1 == nil or lat2 == nil or lon2 == nil then
      return nil
    end
    local dlat = math.rad(lat2-lat1)
    local dlon = math.rad(lon2-lon1)
    local sin_dlat = math.sin(dlat/2)
    local sin_dlon = math.sin(dlon/2)
    local a = sin_dlat * sin_dlat + math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) * sin_dlon * sin_dlon
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    -- To get miles, use 3963 as the constant (equator again)
    local d = 6378 * c
    return d
  end
