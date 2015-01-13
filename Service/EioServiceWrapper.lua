require "Service/ServiceWrapper"

EioServiceWrapper = {}
  EioServiceWrapper.__index = EioServiceWrapper
  setmetatable(EioServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function EioServiceWrapper:_init()
    local portConfigEnums = {Disabled = 0,
                             Analog = 1,
                             InputWeakPullDown = 2,
                             InputPullUp = 3,
                             InputPullDown = 4,
                             OpenDrainOutputLow = 5,
                             OpenDrainOutputHigh = 6,
                             PushPullOutputLow = 7,
                             PushPullOutputHigh = 8,}
    local portEdgeDetect = {Disabled = 0,
                            Rising = 1,
                            Falling = 2,
                            Both = 3,
                           }
    local properties = {
                        { name ="port1Config", pin=1, ptype="enum", enums=portConfigEnums},
                        { name ="port1AlarmMsg", pin=2, ptype="boolean"},
                        { name ="port1AlarmLog", pin=3, ptype="boolean"},
                        { name ="port1EdgeDetect", pin=4, ptype="enum", enums=portEdgeDetect},
                        { name ="port1EdgeSampleCount", pin=5, ptype="unsignedint"},
                        { name ="port1EdgeSampleError", pin=6, ptype="unsignedint"},
                        { name ="port1AnalogSampleRate", pin=7, ptype="unsignedint"},
                        { name ="port1AnalogSampleFilter", pin=8, ptype="unsignedint"},
                        { name ="port1AnalogLowThreshold", pin=9, ptype="unsignedint"},
                        { name ="port1AnalogHighThreshold", pin=10, ptype="unsignedint"},
                        { name ="port1Value", pin=11, ptype="unsignedint"},
                        { name ="port2Config", pin=12, ptype="enum", enums=portConfigEnums},
                        { name ="port2AlarmMsg", pin=13, ptype="boolean"},
                        { name ="port2AlarmLog", pin=14, ptype="boolean"},
                        { name ="port2EdgeDetect", pin=15, ptype="enum", enums=portEdgeDetect},
                        { name ="port2EdgeSampleCount", pin=16, ptype="unsignedint"},
                        { name ="port2EdgeSampleError", pin=17, ptype="unsignedint"},
                        { name ="port2AnalogSampleRate", pin=18, ptype="unsignedint"},
                        { name ="port2AnalogSampleFilter", pin=19, ptype="unsignedint"},
                        { name ="port2AnalogLowThreshold", pin=20, ptype="unsignedint"},
                        { name ="port2AnalogHighThreshold", pin=21, ptype="unsignedint"},
                        { name ="port2Value", pin=22, ptype="unsignedint"},
                        { name ="port3Config", pin=23, ptype="enum", enums=portConfigEnums},
                        { name ="port3AlarmMsg", pin=24, ptype="boolean"},
                        { name ="port3AlarmLog", pin=25, ptype="boolean"},
                        { name ="port3EdgeDetect", pin=26, ptype="enum", enums=portEdgeDetect},
                        { name ="port3EdgeSampleCount", pin=27, ptype="unsignedint"},
                        { name ="port3EdgeSampleError", pin=28, ptype="unsignedint"},
                        { name ="port3AnalogSampleRate", pin=29, ptype="unsignedint"},
                        { name ="port3AnalogSampleFilter", pin=30, ptype="unsignedint"},
                        { name ="port3AnalogLowThreshold", pin=31, ptype="unsignedint"},
                        { name ="port3AnalogHighThreshold", pin=32, ptype="unsignedint"},
                        { name ="port3Value", pin=33, ptype="unsignedint"},
                        { name ="port4Config", pin=34, ptype="enum", enums=portConfigEnums},
                        { name ="port4AlarmMsg", pin=35, ptype="boolean"},
                        { name ="port4AlarmLog", pin=36, ptype="boolean"},
                        { name ="port4EdgeDetect", pin=37, ptype="enum", enums=portEdgeDetect},
                        { name ="port4EdgeSampleCount", pin=38, ptype="unsignedint"},
                        { name ="port4EdgeSampleError", pin=39, ptype="unsignedint"},
                        { name ="port4AnalogSampleRate", pin=40, ptype="unsignedint"},
                        { name ="port4AnalogSampleFilter", pin=41, ptype="unsignedint"},
                        { name ="port4AnalogLowThreshold", pin=42, ptype="unsignedint"},
                        { name ="port4AnalogHighThreshold", pin=43, ptype="unsignedint"},
                        { name ="port4Value", pin=44, ptype="unsignedint"},
                        { name ="temperatureAlarmMsg", pin=45, ptype="boolean"},
                        { name ="temperatureAlarmLog", pin=46, ptype="boolean"},
                        { name ="temperatureSampleRate", pin=47, ptype="unsignedint"},
                        { name ="temperatureSampleFilter", pin=48, ptype="unsignedint"},
                        { name ="temperatureLowThreshold", pin=49, ptype="signedint"},
                        { name ="temperatureHighThreshold", pin=50, ptype="signedint"},
                        { name ="temperatureValue", pin=51, ptype="signedint"},
                        { name ="powerAlarmMsg", pin=52, ptype="boolean"},
                        { name ="powerAlarmLog", pin=53, ptype="boolean"},
                        { name ="powerSampleRate", pin=54, ptype="unsignedint"},
                        { name ="powerSampleFilter", pin=55, ptype="unsignedint"},
                        { name ="powerLowThreshold", pin=56, ptype="unsignedint"},
                        { name ="powerHighThreshold", pin=57, ptype="unsignedint"},
                        { name ="powerValue", pin=58, ptype="unsignedint"},
                        { name ="outputSink5Default", pin=60, ptype="data"}, -- no enums provided
                        { name ="outputSink5Value", pin=61, ptype="unsignedint"},
                        { name ="outputSink6Default", pin=62, ptype="data"}, -- no enums provided
                        { name ="outputSink6Value", pin=63, ptype="unsignedint"},
                        { name ="port1StrongPullDown", pin=65, ptype="boolean"},
                 }
    local messages_to = {
                          { name ="readPort", min=1},
                          { name ="writePort", min=2},
                          { name ="pulsePort", min=3},
                        }
    
    local messages_from = {
                            { name ="portValue", min=1},
                            { name ="portAlarm", min=2},
                          }
    
    ServiceWrapper._init(self, {
        sin = 25, 
        name = "EIO", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties
    })
  end