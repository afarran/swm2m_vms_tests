----------- 
-- CommonReports test module
-- - contains VMS features dependant on geofence
-- @module TestGeofenceModule

module("TestGeofenceModule", package.seeall)

local zone1 = {
      number = 1,
      centerLatitude = 40.00,
      centerLongitude = -15.00,
      latitudeDistance = 350,
      longitudeDistance = 350,}
    
    
local zone0 = {
      number = 0,
      centerLatitude = 50.50,
      centerLongitude = 21.687,
      latitudeDistance = 350,
      longitudeDistance = 350,}
    
local geofenceSettings = {
  enabled = true,
  hysteresis = 0,
  interval = 10
}

function suite_setup()
  
  geofenceSW:setPropertiesByName(geofenceSettings)
  geofenceSW:setRectangle(zone1)
  geofenceSW:setRectangle(zone0)
  geofenceSW:waitForRefresh()
  GPS:set({latitude = 0, longitude = 0})
  geofenceSW:waitForRefresh()
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
  geofenceSW:waitForRefresh()
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
  GPS:set({latitude = zone0.centerLatitude, longitude = zone0.centerLongitude})
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
  
  GPS:set({latitude = zone0.centerLatitude, longitude = zone0.centerLongitude})
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
  GPS:set({latitude = zone0.centerLatitude, longitude = zone0.centerLongitude})
  
  -- accelerated report should be send before next standard report
  receivedMessages = vmsSW:waitForMessagesByName("AcceleratedReport1", 5 + newStandardReport1Interval*60)
  acceleratedReport = receivedMessages.AcceleratedReport1
  
  assert_not_nil(acceleratedReport, "Second accelerated report not received")
  
  state = vmsSW:decodeBitmap(acceleratedReport.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone") 
end

--- Chekcs if GeofenceEntry message is sent correctly.
-- Verifies: fence id, status bitmap, longitude, latitude
-- 1. Go inside geofence zone
-- 2. Wait for GeofenceEntry message
function test_GeofenceFeatures_WhenInsideGeofenceZone_GeofenceEntryIsSent()
  vmsSW:setHighWaterMark()
  
  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  
  local receivedMessages = vmsSW:waitForMessagesByName("GeofenceEntry")
  local geofecneEntry = receivedMessages.GeofenceEntry
  
  assert_not_nil(geofecneEntry, "GeofenceEntry not received")
  
  geofecneEntry:_verify({
    Timestamp =      {assert_not_nil},
    Latitude =        {assert_not_nil},
    Longitude =   {assert_not_nil},
    Speed =  {assert_not_nil},
    Course =  {assert_not_nil},
    Hdop = {assert_not_nil},
    NumSats = {assert_not_nil},
    IdpCnr = {assert_not_nil},
    StatusBitmap = {assert_not_nil},
    FenceId = {assert_not_nil}
  })
  
  geofecneEntry:_verify({
    FenceId = {assert_equal, zone1.number},
    Latitude = {assert_equal, GPS:denormalize(zone1.centerLatitude)},
    Longitude = {assert_equal, GPS:denormalize(zone1.centerLongitude)},
    Course  = {assert_equal, fix.heading},
    Speed = {assert_equal, vmsSW:speedGpsToVms(fix.speed), 1},
    })
  
  local state = vmsSW:decodeBitmap(geofecneEntry.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone")  
end


--- Check if GeofenceExit is sent correctly.
--
function test_GeofenceFeatures_WhenInsideGeofenceZoneGoesOutside_GeofenceExitIsSent()
  vmsSW:setHighWaterMark()
  
  geofenceSW:goInside(zone1)
  
  local receivedMessages = vmsSW:waitForMessagesByName("GeofenceEntry")
  local geofecneEntry = receivedMessages.GeofenceEntry
  
  assert_not_nil(geofecneEntry, "GeofenceEntry not received")
  
  geofecneEntry:_verify({
    Timestamp =      {assert_not_nil},
    Latitude =        {assert_not_nil},
    Longitude =   {assert_not_nil},
    Speed =  {assert_not_nil},
    Course =  {assert_not_nil},
    Hdop = {assert_not_nil},
    NumSats = {assert_not_nil},
    IdpCnr = {assert_not_nil},
    StatusBitmap = {assert_not_nil},
    FenceId = {assert_not_nil}
  })
  
  
  
  geofecneEntry:_verify({
    FenceId = {assert_equal, zone1.number},
    Latitude = {assert_equal, GPS:denormalize(zone1.centerLatitude)},
    Longitude = {assert_equal, GPS:denormalize(zone1.centerLongitude)},
    })
  
  local state = vmsSW:decodeBitmap(geofecneEntry.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone")  
end

-- TODO: Test HDOP, NumSats, IdpCnr - currently not supported by simulator
-- TODO: test when terminal inside more than one geofence
-- TODO: test inside geofence LED? 