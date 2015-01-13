require "Service/EioServiceWrapper"
require "Service/PositionServiceWrapper"
require "Service/VmsServiceWrapper"
require "Service/SystemServiceWrapper"

--eio = EioServiceWrapper()
-- a = service:getPropertiesByName({"latitude", "longitude"})

--a = eio:getPropertiesByName({"port1Config"}, false)
--position:setPropertiesByName({latitude = 1, continuous = 1})
--a = position:getPropertiesByName({"latitude", "continuous"})

--a = eio:setPropertiesByName({port1Config = "Disabled"})

--a = eio:getPropertiesByName({"port1Config"})

position = PositionServiceWrapper()
--r = position:waitForProperties({latitude = 180000}, 10)
print(r)
vms = VmsServiceWrapper()
systemSW = SystemServiceWrapper()

systemSW:restartService(vms.sin)
systemSW:resetProperties({21,20,22})
a = systemSW:getPropertiesByName({"ledControl"})
position:sendMessageByName("getPosition", {{Name="fixType",Value="2D"},})

msg = position:waitForMessagesByName("position")

print(position.pins)
