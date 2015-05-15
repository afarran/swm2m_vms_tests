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
  geofenceSW:setRectangle({
      number = 1,
      centerLatitude = 40.00,
      centerLongitude = -15.00,
      latitudeDistance = 350,
      longitudeDistance = 350,})
  
  geofenceSW:setRectangle({
      number = 0,
      centerLatitude = 50.50,
      centerLongitude = 21.687,
      latitudeDistance = 350,
      longitudeDistance = 350,})
end

-- executed after each test suite
function suite_teardown()
  geofenceSW:disableFence(0)
  geofenceSW:disableFence(1)
end

--- setup function
function setup()
  gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
  GPS:set({latitude = 0, longitude = 0})
  framework.delay(geofenceSW.interval + geofenceSW.hysteresis)
end

-------------------------
-- Test Cases
-------------------------

function test_GeofenceFeatures_WhenInsideGeofenceZone_StandardReportStatusBitmapInsideGeofenceBitIsSet()
  local currentReport1Interval = vmsSW:getPropertiesByName({"StandardReport1Interval"})["StandardReport1Interval"]
  vmsSW:setPropertiesByName({StandardReport1Interval = 1})
  local receivedMessages = vmsSW:waitForMessagesByName("StandardReport1", currentReport1Interval*60)
  local standardReport = receivedMessages.StandardReport1
  
  assert_not_nil(standardReport, "Standard Report not received")
  
  local state = vmsSW:decodeBitmap(standardReport.StatusBitmap, "EventStateId")
  assert_false(state.InsigeGeofence, "Terminal incorrectly repored as inside geofence zone")
  vmsSW:setHighWaterMark()
  GPS:set({latitude = 50.50, longitude = 21.687})
  receivedMessages = vmsSW:waitForMessagesByName("StandardReport1", 60)
  standardReport = receivedMessages.StandardReport1
  
  assert_not_nil(standardReport, "Standard Report not received")
  
  state = vmsSW:decodeBitmap(standardReport.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone")  
end

function test_GeofenceFeatures_WhenInsideGeofenceZone_VMSPropertyInsideGeofenceIsSetToTrue()
  GPS:set({latitude = 0, longitude = 0})
  local status, properties = vmsSW:waitForProperties({InsideGeofenceState = false})
  assert_false(properties.InsideGeofenceState, "Property InsideGeofenceState incorreclty remains set to true while terminal is not in geofence zone")
  
  GPS:set({latitude = 50.50, longitude = 21.687})
  status, properties = vmsSW:waitForProperties({InsideGeofenceState = true})
  assert_true(properties.InsideGeofenceState, "Property InsideGeofenceState incorreclty remains set to false while terminal entered Geofence zone") 
  
end

function test_GeofenceFeatures_WhenInsideGeofenceZone_AcceleratedReportStatusBitmapInsideGeofenceBitIsSet()
  local Report1Properties = vmsSW:getPropertiesByName({"StandardReport1Interval", "AcceleratedReport1Rate"})
  local currentStandardReport1Interval = Report1Properties["StandardReport1Interval"]
  local currentAcceleratedReport1Rate = Report1Properties["AcceleratedReport1Rate"]
  local newAcceleratedReport1Rate = 2
  local newStandardReport1Interval = 2
  local stdInterval = newStandardReport1Interval
  if currentStandardReport1Interval > newStandardReport1Interval then
    local stdInterval = currentStandardReport1Interval
  end
  vmsSW:setPropertiesByName({StandardReport1Interval = newStandardReport1Interval,
                             AcceleratedReport1Rate = newAcceleratedReport1Rate})
  
  local receivedMessages = vmsSW:waitForMessagesByName("StandardReport1", 5 + stdInterval*60)
  local standardReport = receivedMessages.StandardReport1
  assert_not_nil(standardReport, "First Standard report not received")
  
  -- accelerated report should be send before next standard report
  receivedMessages = vmsSW:waitForMessagesByName("AcceleratedReport1", 5 + newStandardReport1Interval*60) 
  local acceleratedReport = receivedMessages.AcceleratedReport1
  
  assert_not_nil(acceleratedReport, "First accelerated report not received")
  
  local state = vmsSW:decodeBitmap(acceleratedReport.StatusBitmap, "EventStateId")
  assert_false(state.InsigeGeofence, "Terminal incorrectly repored as inside geofence zone")
  vmsSW:setHighWaterMark()
  GPS:set({latitude = 50.50, longitude = 21.687})
  
  -- accelerated report should be send before next standard report
  receivedMessages = vmsSW:waitForMessagesByName("AcceleratedReport1", 5 + newStandardReport1Interval*60)
  acceleratedReport = receivedMessages.AcceleratedReport1
  
  assert_not_nil(acceleratedReport, "Second accelerated report not received")
  
  state = vmsSW:decodeBitmap(acceleratedReport.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone") 
end

-- TODO: test geofence message from VMS service - not implemented
-- TODO: test when terminal inside more than one geofence
-- TODO: test inside geofence LED? 