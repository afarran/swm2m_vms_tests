require "Service/EioServiceWrapper"

eio = EioServiceWrapper()
-- a = service:getPropertiesByName({"latitude", "longitude"})

--a = eio:getPropertiesByName({"port1Config"}, false)
--position:setPropertiesByName({latitude = 1, continuous = 1})
--a = position:getPropertiesByName({"latitude", "continuous"})
a = eio:setPropertiesByName({port1Config = "Disabled"})
a = eio:getPropertiesByName({"port1Config"}, false)
print(eio.pins)
