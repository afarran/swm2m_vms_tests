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
    
    local properties = {
        { name="1", pin=StandardReport1Interval, ptype=""},
        { name="2", pin=AcceleratedReport1Rate, ptype=""},
        { name="3", pin=LogReport1Rate, ptype=""},
        { name="11", pin=StandardReport2Interval, ptype=""},
        { name="12", pin=AcceleratedReport2Rate, ptype=""},
        { name="13", pin=LogReport2Rate, ptype=""},
        { name="21", pin=StandardReport3Interval, ptype=""},
        { name="22", pin=AcceleratedReport3Rate, ptype=""},
        { name="23", pin=LogReport3Rate, ptype=""},
        { name="30", pin=GpsJammedSendReport, ptype=""},
        { name="31", pin=GpsJammedStartDebounceTime, ptype=""},
        { name="32", pin=GpsJammedEndDebounceTime, ptype=""},
        { name="33", pin=GpsJammedState, ptype=""},
        { name="34", pin=GpsBlockedSendReport, ptype=""},
        { name="35", pin=GpsBlockedStartDebounceTime, ptype=""},
        { name="36", pin=GpsBlockedEndDebounceTime, ptype=""},
        { name="37", pin=GpsBlockedState, ptype=""},
        { name="38", pin=IdpBlockedSendReport, ptype=""},
        { name="39", pin=IdpBlockedStartDebounceTime, ptype=""},
        { name="40", pin=IdpBlockedEndDebounceTime, ptype=""},
        { name="41", pin=IdpBlockedState, ptype=""},
        { name="42", pin=HwClientDisconnectedSendReport, ptype=""},
        { name="43", pin=HwClientDisconnectedStartDebounceTime, ptype=""},
        { name="44", pin=HwClientDisconnectedEndDebounceTime, ptype=""},
        { name="45", pin=HwClientDisconnectedState, ptype=""},
        { name="50", pin=HelmPanelDisconnectedSendReport, ptype=""},
        { name="51", pin=HelmPanelDisconnectedStartDebounceTime, ptype=""},
        { name="52", pin=HelmPanelDisconnectedEndDebounceTime, ptype=""},
        { name="53", pin=HelmPanelDisconnectedState, ptype=""},
        { name="54", pin=ExtPowerDisconnectedSendReport, ptype=""},
        { name="55", pin=ExtPowerDisconnectedStartDebounceTime, ptype=""},
        { name="56", pin=ExtPowerDisconnectedEndDebounceTime, ptype=""},
        { name="57", pin=ExtPowerDisconnectedState, ptype=""},
        { name="58", pin=PowerDisconnectedSendReport, ptype=""},
        { name="59", pin=PowerDisconnectedStartDebounceTime, ptype=""},
        { name="60", pin=PowerDisconnectedEndDebounceTime, ptype=""},
        { name="61", pin=PowerDisconnectedState, ptype=""},
        { name="65", pin=InsideGeofenceState, ptype=""},
        { name="100", pin=PropertyChangeDebounceTime, ptype=""},
        { name="101", pin=MinStandardReportLedFlashTime, ptype=""},
        { name="102", pin=SessionIdleTimeout, ptype=""},
    }
    ServiceWrapper:_init({sin = 115, name = "VMS", mins = {}, properties = properties})
  end