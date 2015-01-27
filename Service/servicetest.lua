require "Service/EioServiceWrapper"
require "Service/PositionServiceWrapper"
require "Service/VmsServiceWrapper"
require "Service/SystemServiceWrapper"
require "Service/FilesystemServiceWrapper"
require "Service/LogServiceWrapper"
require "Service/GeofenceServiceWrapper"
require "Debugger/Debugger"
require("Serial/RealSerialWrapper")

serial = RealSerialWrapper({
    name = "COM3",
    open = false})

serial:getPorts()
serial:readLine()
ports = io.Serial:getPorts()

geo = GeofenceServiceWrapper()

geo:setRectangle({
    centerLatitude = 50.776533333333333,
    centerLongitude = 10.64575,
    latitudeDistance = 600,
    longitudeDistance = 700,})
D = Debugger()


vms = VmsServiceWrapper()
s = vms:getServicePath()

local a = vms:requestMessageByName("PollRequest1", nil, "PollResponse1")
print("s")

eio = EioServiceWrapper()
fs = FilesystemServiceWrapper()
s = vms:decodeBitmap(1234, "EventStateId")
v = vms:encodeBitmap({"GpsBlocked", "GpsJammed"}, "EventStateId")

local Fields = {}
Fields = {{Name="path",Value="/data/svc/VMS/version2.dat"},
          {Name="offset",Value=0},
          {Name="flags",Value="Overwrite"},
          {Name="data",Value=framework.base64Encode("test test")}}

fs:sendMessageByName("write", Fields)
print("S")
-- "VntIZWxtUGFuZWxJbnRlcmZhY2U9IiIsTWVzc2FnZURlZkhhc2g9NTM1MjIsUHJvcERlZkhhc2g9NTEzOTksU291cmNlQ29kZUhhc2g9NDI0NjUsVm1zQWdlbnQ9IjEuMi4wIixJZHBQYWNrYWdlPSI1LjAuNy44ODc3Iix9Cg=="
--a = eio:getPropertiesByName({"port4Config", "port4EdgeDetect"})
--print(a)
--a = eio:getPropertiesByName({"port1Config"}, false)
--position:setPropertiesByName({latitude = 1, continuous = 1})
--a = position:getPropertiesByName({"latitude", "continuous"})

a = eio:setPropertiesByName({port1Config = "Disabled"})

--a = eio:getPropertiesByName({"port1Config"})

position = PositionServiceWrapper()
s = position:getPropertiesByName({"fixType"})
--r = position:waitForProperties({latitude = 180000}, 10)
print(r)

systemSW = SystemServiceWrapper()

systemSW:restartService(vms.sin)
systemSW:resetProperties({21,20,22})
a = systemSW:getPropertiesByName({"ledControl"})
position:sendMessageByName("getPosition", {{Name="fixType",Value="2D"},})

msg = position:waitForMessagesByName("position")

print(position.pins)
