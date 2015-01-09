require "Service/EioServiceWrapper"

eio = EioServiceWrapper()
-- a = service:getPropertiesByName({"latitude", "longitude"})

a = eio:getPropertiesByName({"port2Config"}, false)
--position:setPropertiesByName({latitude = 1, continuous = 1})
--a = position:getPropertiesByName({"latitude", "continuous"})
print(eio.pins)
