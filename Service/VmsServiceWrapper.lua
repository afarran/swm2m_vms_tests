require "Service/Service"

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
    
    -- "unsignedint"  "signedint"  "enum"  "string"  "boolean"  "data"
    
    local properties = {
      { pin=1, name="StandardReport1Interval", ptype=""},
      { pin=2, name="AcceleratedReport1Rate", ptype=""},
      { pin=3, name="LogReport1Rate", ptype=""},
      { pin=11, name="StandardReport2Interval", ptype=""},
      { pin=12, name="AcceleratedReport2Rate", ptype=""},
      { pin=13, name="LogReport2Rate", ptype=""},
      { pin=21, name="StandardReport3Interval", ptype=""},
      { pin=22, name="AcceleratedReport3Rate", ptype=""},
      { pin=23, name="LogReport3Rate", ptype=""},
      { pin=30, name="GpsJammedSendReport", ptype=""},
      { pin=31, name="GpsJammedStartDebounceTime", ptype=""},
      { pin=32, name="GpsJammedEndDebounceTime", ptype=""},
      { pin=33, name="GpsJammedState", ptype=""},
      { pin=34, name="GpsBlockedSendReport", ptype=""},
      { pin=35, name="GpsBlockedStartDebounceTime", ptype=""},
      { pin=36, name="GpsBlockedEndDebounceTime", ptype=""},
      { pin=37, name="GpsBlockedState", ptype=""},
      { pin=38, name="IdpBlockedSendReport", ptype=""},
      { pin=39, name="IdpBlockedStartDebounceTime", ptype=""},
      { pin=40, name="IdpBlockedEndDebounceTime", ptype=""},
      { pin=41, name="IdpBlockedState", ptype=""},
      { pin=42, name="HwClientDisconnectedSendReport", ptype=""},
      { pin=43, name="HwClientDisconnectedStartDebounceTime", ptype=""},
      { pin=44, name="HwClientDisconnectedEndDebounceTime", ptype=""},
      { pin=45, name="HwClientDisconnectedState", ptype=""},
      { pin=50, name="HelmPanelDisconnectedSendReport", ptype=""},
      { pin=51, name="HelmPanelDisconnectedStartDebounceTime", ptype=""},
      { pin=52, name="HelmPanelDisconnectedEndDebounceTime", ptype=""},
      { pin=53, name="HelmPanelDisconnectedState", ptype=""},
      { pin=54, name="ExtPowerDisconnectedSendReport", ptype=""},
      { pin=55, name="ExtPowerDisconnectedStartDebounceTime", ptype=""},
      { pin=56, name="ExtPowerDisconnectedEndDebounceTime", ptype=""},
      { pin=57, name="ExtPowerDisconnectedState", ptype=""},
      { pin=58, name="PowerDisconnectedSendReport", ptype=""},
      { pin=59, name="PowerDisconnectedStartDebounceTime", ptype=""},
      { pin=60, name="PowerDisconnectedEndDebounceTime", ptype=""},
      { pin=61, name="PowerDisconnectedState", ptype=""},
      { pin=65, name="InsideGeofenceState", ptype=""},
      { pin=100, name="PropertyChangeDebounceTime", ptype=""},
      { pin=101, name="MinStandardReportLedFlashTime", ptype=""},
      { pin=102, name="SessionIdleTimeout", ptype=""},
    }
    ServiceWrapper:_init({sin = 115, name = "VMS", mins = {}, properties = properties})
  end