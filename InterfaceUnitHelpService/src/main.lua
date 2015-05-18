--
-- Service: InterfaceUnitHelpService
-- This service just exposes properties of Interface Unit.
-- Created: 2015-05-18
--

module(..., package.seeall)

--
-- Version information (required)
--
_VERSION = "1.0.0"

--
-- Run service (required)
--
function entry()
  print(_NAME, ": service started")
  sched.delay(-1)
end

--
-- Initialize service (required)
--
function init()

end

