-----------
-- CommonReports test module
-- - contains VMS features dependant on geofence
-- @module TestGeofenceModule

module("TestGeofenceModule", package.seeall)

function suite_setup()
  GPS:set({latitude = 0, longitude = 0})
  geofenceSW:setPropertiesByName({enabled = true,
                                  hysteresis = 0,
                                  interval = 10})
end

-- executed after each test suite
function suite_teardown()

end

--- setup function
function setup()
  gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
end

-------------------------
-- Test Cases
-------------------------

function test_WhenInsideGeofenceZone_StandardReportStatusBitmapInsideGeofenceBitIsSet()

end