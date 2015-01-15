require "Service/ServiceWrapper"

LogServiceWrapper = {}
  LogServiceWrapper.__index = LogServiceWrapper
  setmetatable(LogServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function LogServiceWrapper:_init()
    
    -- Possible types: "unsignedint"  "signedint"  "enum"  "string"  "boolean"  "data"
    
    local properties = {
      { name ="dataLogEnabled", pin=1, ptype="boolean"},
      { name ="maxDataLogSize", pin=2, ptype="unsignedint"},
      { name ="maxDataLogFiles", pin=3, ptype="unsignedint"},
      { name ="debugLogEnabled", pin=4, ptype="boolean"},
      { name ="maxDebugLogSize", pin=5, ptype="unsignedint"},
      { name ="maxDebugLogFiles", pin=6, ptype="unsignedint"},
      { name ="debugLogLevelsMask", pin=7, ptype="unsignedint"},
      { name ="uploadDataLogEnabled", pin=8, ptype="boolean"},
      { name ="uploadDebugLogEnabled", pin=9, ptype="boolean"},
      { name ="uploadTransport1", pin=10, ptype="unsignedint"},
      { name ="uploadTimeout1", pin=11, ptype="unsignedint"},
      { name ="uploadTransport2", pin=12, ptype="unsignedint"},
      { name ="uploadTimeout2", pin=13, ptype="unsignedint"},
      { name ="uploadRetryInterval", pin=14, ptype="unsignedint"},
      { name ="uploadRetryMultiplier", pin=15, ptype="unsignedint"},
      { name ="logSuppress2", pin=16, ptype="data"},
      { name ="logSuppress3", pin=17, ptype="data"},
      { name ="logSuppress4", pin=18, ptype="data"},
      { name ="logSuppress5", pin=19, ptype="data"},
      { name ="logSuppress6", pin=20, ptype="data"},
      { name ="logSuppress7", pin=21, ptype="data"},
      { name ="logSuppress8", pin=22, ptype="data"},
      { name ="logSuppress9", pin=23, ptype="data"},
      { name ="logSuppress10", pin=24, ptype="data"},
      { name ="logSuppress11", pin=25, ptype="data"},
      { name ="logSuppress12", pin=26, ptype="data"},
      { name ="logSuppress13", pin=27, ptype="data"},
      { name ="logSuppress14", pin=28, ptype="data"},
      { name ="logSuppress15", pin=29, ptype="data"},
      { name ="traceSuppress2", pin=30, ptype="data"},
      { name ="traceSuppress3", pin=31, ptype="data"},
      { name ="traceSuppress4", pin=32, ptype="data"},
      { name ="traceSuppress5", pin=33, ptype="data"},
      { name ="traceSuppress6", pin=34, ptype="data"},
      { name ="traceSuppress7", pin=35, ptype="data"},
      { name ="traceSuppress8", pin=36, ptype="data"},
      { name ="traceSuppress9", pin=37, ptype="data"},
      { name ="traceSuppress10", pin=38, ptype="data"},
      { name ="traceSuppress11", pin=39, ptype="data"},
      { name ="traceSuppress12", pin=40, ptype="data"},
      { name ="traceSuppress13", pin=41, ptype="data"},
      { name ="traceSuppress14", pin=42, ptype="data"},
      { name ="traceSuppress15", pin=43, ptype="data"},
      { name ="uploadDebugLogFormat", pin=44, ptype="enum"},

    }
    
    local messages_from = {
      { name ="dataLogFilter", min=1},
      { name ="debugLogFilter", min=2},
      { name ="dataLogCount", min=3},
      { name ="debugLogCount", min=4},
      { name ="dataLogEntries", min=5},
      { name ="debugLogEntries", min=6},
      { name ="uploadDataLogFilter", min=7},
      { name ="uploadDebugLogFilter", min=8},
      { name ="uploadDataLogCount", min=9},
      { name ="uploadDebugLogCount", min=10},
      { name ="uploadDataLogEntries", min=11},
      { name ="uploadDebugLogEntries", min=12},
      { name ="debugLogFilter2", min=13},
      { name ="debugLogEntries2", min=14},
      { name ="uploadDebugLogFilter2", min=15},
      { name ="uploadDebugLogEntries2", min=16},
    }
    local messages_to = {
      { name ="setDataLogFilter", min=1},
      { name ="setDebugLogFilter", min=2},
      { name ="getDataLogCount", min=3},
      { name ="getDebugLogCount", min=4},
      { name ="getDataLogEntries", min=5},
      { name ="getDebugLogEntries", min=6},
      { name ="clearLogs", min=7},
      { name ="setUploadDataLogFilter", min=8},
      { name ="setUploadDebugLogFilter", min=9},
      { name ="getUploadDataLogCount", min=10},
      { name ="getUploadDebugLogCount", min=11},
      { name ="setDebugLogFilter2", min=12},
      { name ="getDebugLogEntries2", min=13},
      { name ="setUploadDebugLogFilter2", min=14},

    }

    function LogServiceWrapper:setLogFilter(sin, minList, loggingStartTime, loggingEndTime, reverse)

      local minListEncoded = framework.base64Encode(minList)
    
      self:sendMessageByName(
        "setDataLogFilter",
        {
          {Name="timeStart",Value=loggingStartTime},
          {Name="timeEnd",Value=loggingEndTime},
          {Name="reverse",Value=reverse},
          {Name="list",Elements={
             { Index=0,
               Fields={{Name="sin",Value=sin},{Name="minList",Value=minListEncoded}}}
             }
          },
        }
      )

    end

    ServiceWrapper._init(self, {
        sin = 23, 
        name = "Log", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties,
        bitmaps = bitmaps,
    })
  end
