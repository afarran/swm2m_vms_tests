require "Service/ServiceWrapper"

VmsServiceWrapper = {}
  VmsServiceWrapper.__index = VmsServiceWrapper
  setmetatable(VmsServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function VmsServiceWrapper:_init()
    
    -- Possible types: "unsignedint"  "signedint"  "enum"  "string"  "boolean"  "data"
    
    local properties = {
      { pin=1, name="StandardReport1Interval", ptype="unsignedint"},
      { pin=2, name="AcceleratedReport1Rate", ptype="unsignedint"},
      { pin=3, name="LogReport1Rate", ptype="unsignedint"},
      { pin=11, name="StandardReport2Interval", ptype="unsignedint"},
      { pin=12, name="AcceleratedReport2Rate", ptype="unsignedint"},
      { pin=13, name="LogReport2Rate", ptype="unsignedint"},
      { pin=21, name="StandardReport3Interval", ptype="unsignedint"},
      { pin=22, name="AcceleratedReport3Rate", ptype="unsignedint"},
      { pin=23, name="LogReport3Rate", ptype="unsignedint"},
      { pin=30, name="GpsJammedSendReport", ptype="boolean"},
      { pin=31, name="GpsJammedStartDebounceTime", ptype="unsignedint"},
      { pin=32, name="GpsJammedEndDebounceTime", ptype="unsignedint"},
      { pin=33, name="GpsJammedState", ptype="boolean"},
      { pin=34, name="GpsBlockedSendReport", ptype="boolean"},
      { pin=35, name="GpsBlockedStartDebounceTime", ptype="unsignedint"},
      { pin=36, name="GpsBlockedEndDebounceTime", ptype="unsignedint"},
      { pin=37, name="GpsBlockedState", ptype="boolean"},
      { pin=38, name="IdpBlockedSendReport", ptype="boolean"},
      { pin=39, name="IdpBlockedStartDebounceTime", ptype="unsignedint"},
      { pin=40, name="IdpBlockedEndDebounceTime", ptype="unsignedint"},
      { pin=41, name="IdpBlockedState", ptype="boolean"},
      { pin=42, name="HwClientDisconnectedSendReport", ptype="boolean"},
      { pin=43, name="HwClientDisconnectedStartDebounceTime", ptype="unsignedint"},
      { pin=44, name="HwClientDisconnectedEndDebounceTime", ptype="unsignedint"},
      { pin=45, name="HwClientDisconnectedState", ptype="boolean"},
      { pin=50, name="HelmPanelDisconnectedSendReport", ptype="boolean"},
      { pin=51, name="HelmPanelDisconnectedStartDebounceTime", ptype="unsignedint"},
      { pin=52, name="HelmPanelDisconnectedEndDebounceTime", ptype="unsignedint"},
      { pin=53, name="HelmPanelDisconnectedState", ptype="boolean"},
      { pin=54, name="ExtPowerDisconnectedSendReport", ptype="boolean"},
      { pin=55, name="ExtPowerDisconnectedStartDebounceTime", ptype="unsignedint"},
      { pin=56, name="ExtPowerDisconnectedEndDebounceTime", ptype="unsignedint"},
      { pin=57, name="ExtPowerDisconnectedState", ptype="boolean"},
      { pin=58, name="PowerDisconnectedSendReport", ptype="boolean"},
      { pin=59, name="PowerDisconnectedStartDebounceTime", ptype="unsignedint"},
      { pin=60, name="PowerDisconnectedEndDebounceTime", ptype="unsignedint"},
      { pin=61, name="PowerDisconnectedState", ptype="boolean"},
      { pin=65, name="InsideGeofenceState", ptype="boolean"},
      { pin=100, name="PropertyChangeDebounceTime", ptype="unsignedint"},
      { pin=101, name="MinStandardReportLedFlashTime", ptype="unsignedint"},
      { pin=102, name="SessionIdleTimeout", ptype="unsignedint"},
    }
    
    local messages_from = {
      {name="PollResponse1", min = 1 },
      {name="PollResponse2", min = 2 },
      {name="PollResponse3", min = 3 },
      {name="ConfigReport1", min = 4 },
      {name="ConfigReport2", min = 5 },
      {name="ConfigReport3", min = 6},
      {name="Properties", min = 7 },
      {name="Version", min = 8 },
      {name="ConfigChangeReport1", min = 10 },
      {name="ConfigChangeReport1", min = 11 },
      {name="ConfigChangeReport3", min = 12 },
      {name="StandardReport1", min = 20 },
      {name="AcceleratedReport1", min = 21 },
      {name="LogReport1", min = 22 },
      {name="StandardReport2", min = 30 },
      {name="AcceleratedReport2", min = 31 },
      {name="LogReport2", min = 32 },
      {name="StandardReport3", min = 40 },
      {name="AcceleratedReport3", min = 41 },
      {name="LogReport3", min = 42 },
      {name="AbnormalReport", min = 50 }, 
    }
    local messages_to = {
      {name="PollRequest1", min = 1},
      {name="PollRequest2", min = 2},
      {name="PollRequest3", min = 3},
      {name="GetConfigReport1", min = 4},
      {name="GetConfigReport2", min = 5},
      {name="GetConfigReport3", min = 6},
      {name="GetProperties", min = 7},
      {name="GetVersion", min = 8},
      {name="SetConfigReport1", min = 10},
      {name="SetConfigReport2", min = 11},
      {name="SetConfigReport3", min = 12},
      {name="SetProperties", min = 13},
    }
    
    ServiceWrapper:_init({sin = 115, name = "VMS", mins = {}, properties = properties})
  end