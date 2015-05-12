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
      { pin=1, name="LogReportInterval", ptype="unsignedint"},
      { pin=2, name="StandardReport1Interval", ptype="unsignedint"},
      { pin=3, name="AcceleratedReport1Rate", ptype="unsignedint"},
      { pin=4, name="StandardReport2Interval", ptype="unsignedint"},
      { pin=5, name="AcceleratedReport2Rate", ptype="unsignedint"},
      { pin=6, name="StandardReport3Interval", ptype="unsignedint"},
      { pin=7, name="AcceleratedReport3Rate", ptype="unsignedint"},
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
      { pin=46, name="InterfaceUnitDisconnectedSendReport", ptype="boolean"},
      { pin=47, name="InterfaceUnitDisconnectedStartDebounceTime", ptype="unsignedint"},
      { pin=48, name="InterfaceUnitDisconnectedEndDebounceTime", ptype="unsignedint"},
      { pin=49, name="InterfaceUnitDisconnectedState", ptype="boolean"},
      { pin=50, name="InsideGeofenceSendReport", ptype="unsignedint"},
      { pin=51, name="InsideGeofenceStartDebounceTime", ptype="unsignedint"},
      { pin=52, name="InsideGeofenceEndDebounceTime", ptype="unsignedint"},
      { pin=53, name="InsideGeofenceState", ptype="boolean"},
      { pin=54, name="PowerDisconnectedSendReport", ptype="boolean"},
      { pin=55, name="PowerDisconnectedStartDebounceTime", ptype="unsignedint"},
      { pin=56, name="PowerDisconnectedEndDebounceTime", ptype="unsignedint"},
      { pin=57, name="PowerDisconnectedState", ptype="boolean"},
      { pin=100, name="PropertyChangeDebounceTime", ptype="unsignedint"},
      { pin=101, name="MinStandardReportLedFlashTime", ptype="unsignedint"},
      { pin=102, name="ShellTimeout", ptype="unsignedint"},
      { pin=103, name="MailSessionIdleTimeout", ptype="unsignedint"},
      { pin=104, name="GpsInEmails", ptype="boolean"},
      { pin=105, name="AllowedEmailDomains", ptype="boolean"}
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
      {name="ConfigChangeReport2", min = 11 },
      {name="ConfigChangeReport3", min = 12 },
      {name="LogReport", min = 20 },
      {name="StandardReport1", min = 21 },
      {name="AcceleratedReport1", min = 22 },
      {name="StandardReport2", min = 23 },
      {name="AcceleratedReport2", min = 24 },
      {name="StandardReport3", min = 25 },
      {name="AcceleratedReport3", min = 26 },
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
    
    local bitmaps = {
      EventStateId = {GpsJammed = 0,
                      GpsBlocked = 1,
                      IdpBlocked = 2,
                      HwClientDisconnected = 3,
                      InterfaceUnitDisconnected = 4,
                      InsideGeofence = 5,
                      PowerDisconnected = 6}
    }
    
    ServiceWrapper._init(self, {
        sin = 115, 
        name = "VMS", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties,
        bitmaps = bitmaps,
    })

    function VmsServiceWrapper:setPropertiesViaShell(shell,properties)
      D:log("Setting properties via shell")
      for key,value in pairs(properties) do
        local command = "prop set VMS "..key.." "..value
        D:log(command)
        local Fields = {{Name="data",Value=command}}
        local cmdResult = shell:requestMessageByName("executeCmd", Fields, "cmdResult")
        if cmdResult.cmdResult.success ~= "True" then
          D:log("Set properties via shell problems!!!")
        end
      end
    end
  end
