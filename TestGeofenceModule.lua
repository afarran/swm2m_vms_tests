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

--- Set two geofence zones.
-- Set gps position to outside geofecne.
function suite_setup()
  geofenceSW:setPropertiesByName(geofenceSettings)
  geofenceSW:setRectangle(zone1)
  geofenceSW:setRectangle(zone0)
  geofenceSW:waitForRefresh()
  GPS:set({latitude = 0, longitude = 0})
  geofenceSW:waitForRefresh()
end

--- Disable two geofence zones
function suite_teardown()
  geofenceSW:disableFence(0)
  geofenceSW:disableFence(1)
end

--- setup function
function setup()
  gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- Exit all geofences
function teardown()
  GPS:set({latitude = 0, longitude = 0})
  geofenceSW:waitForRefresh()
end

-------------------------
-- Test Cases
-------------------------

--- Checks if StandardReport message is sent with correct StatusBitmap when terminal is inside and outside geofence zone
-- 1. Set StandardReport configuration
-- 2. Terminal is outside geofence zone, wait for StandardReport and check if statusbitmap.insidegeofence is false
-- 3. Go inside geofence zone,
-- 4. Wait for StandardReport and check if statusbitmap.insidegeofence is true
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

--- Check if InsideGeofenceState property is set correctly when inside and outside geofence zone
-- 1. Terminal is outside geofence zone, Check if InsideGeofenceState is set to false
-- 2. Go inside geofence zone
-- 3. Check if InsideGeofenceState is set to true
function test_GeofenceFeatures_WhenInsideGeofenceZone_VMSPropertyInsideGeofenceIsSetToTrue()
  GPS:set({latitude = 0, longitude = 0})
  local status, properties = vmsSW:waitForProperties({InsideGeofenceState = false})
  assert_false(properties.InsideGeofenceState, "Property InsideGeofenceState incorreclty remains set to true while terminal is not in geofence zone")
  
  GPS:set({latitude = zone0.centerLatitude, longitude = zone0.centerLongitude})
  status, properties = vmsSW:waitForProperties({InsideGeofenceState = true})
  assert_true(properties.InsideGeofenceState, "Property InsideGeofenceState incorreclty remains set to false while terminal entered Geofence zone") 
  
end

--- Checks if AcceleratedReport message is sent with correct StatusBitmap when terminal is inside and outside geofence zone
-- 1. Set Accelerated report configuration
-- 2. Terminal is outside geofence zone, wait for AcceleratedReport and check if statusbitmap.insidegeofence is false
-- 3. Go inside geofence zone,
-- 4. Wait for AcceleratedReport and check if statusbitmap.insidegeofence is true
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
-- Verifies: fence id, status bitmap, longitude, latitude, speed, course.
-- 1. Go inside geofence zone
-- 2. Wait for GeofenceEntry message
function test_GeofenceFeatures_WhenInsideGeofenceZone_GeofenceEntryIsSent()
  
  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  
  local receivedMessages = vmsSW:waitForMessagesByName("GeofenceEntry")
  local geofenceEntry = receivedMessages.GeofenceEntry
  
  assert_not_nil(geofenceEntry, "GeofenceEntry not received")
  
  geofenceEntry:_verify({
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
  
  geofenceEntry:_verify({
    FenceId = {assert_equal, zone1.number},
    Latitude = {assert_equal, GPS:denormalize(zone1.centerLatitude)},
    Longitude = {assert_equal, GPS:denormalize(zone1.centerLongitude)},
    Course  = {assert_equal, fix.heading},
    Speed = {assert_equal, vmsSW:speedGpsToVms(fix.speed), 1},
    })
  
  local state = vmsSW:decodeBitmap(geofenceEntry.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone")  
end


--- Check if GeofenceExit is sent correctly.
-- Verifies: fence id, status bitmap, longitude, latitude, speed, course.
-- 1. Enter geofence
-- 2. Exit geofence
-- 3. Wait for GoefenceExit message
function test_GeofenceFeatures_WhenInsideGeofenceZoneGoesOutside_GeofenceExitIsSent()
  
  geofenceSW:goInside(zone1)
  
  local receivedMessages = vmsSW:waitForMessagesByName("GeofenceEntry")
  local geofenceEntry = receivedMessages.GeofenceEntry
  assert_not_nil(geofenceEntry, "GeofenceEntry not received")
  
  
  vmsSW:setHighWaterMark()
  local geofenceExitFix = {latitude = 1, longitude = 2}
  GPS:set(geofenceExitFix)
  receivedMessages = vmsSW:waitForMessagesByName("GeofenceExit")
  local geofenceExit = receivedMessages.GeofenceExit
  assert_not_nil(geofenceExit, "GeofenceExit not received")
    
  geofenceExit:_verify({
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

  geofenceExit:_equal(geofenceEntry, nil, {"Timestamp", "Latitude", "Longitude", "StatusBitmap", "MIN", "Name"})
  
  geofenceExit:_verify({
    Latitude = {assert_equal, GPS:denormalize(geofenceExitFix.latitude)},
    Longitude = {assert_equal, GPS:denormalize(geofenceExitFix.longitude)},
  })
  
  local state = vmsSW:decodeBitmap(geofenceExit.StatusBitmap, "EventStateId")
  assert_false(state.InsideGeofence, "Terminal incorrectly repored as inside geofence zone")  
end

--- Check if correct sequence of GeofenceEntry and GeofenceExit messages are sent when terminal goes inside zone1 then inside zone2 then outside
-- Verifies: fence id, status bitmap, longitude, latitude, speed, course.
-- 1. Go inside zone A
-- 2. Verify GeofenceEntry message
-- 3. Go inside zone B
-- 4. Verify GeofenceExit for zone A
-- 5. Verify GeofenceEntry for zone B
-- 6. Go outside zones
-- 7. Verify GeofenceExit for zone B
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofence1ThenInsideGeofence2_GeofenceEnterGeofenceExitMessagesAreSentCorrectly()
  -- 1. Go inside zone A
  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  local receivedMessages = vmsSW:waitForMessagesByName("GeofenceEntry")
  local geofenceEntry = receivedMessages.GeofenceEntry
  -- 2. Verify GeofenceEntry message
  assert_not_nil(geofenceEntry, "GeofenceEntry not received")
  
  -- Enter second geofence, GeofenceEntry and GeofenceExit messages should be received
  -- 3. Go inside zone B
  vmsSW:setHighWaterMark()
  geofenceSW:goInside(zone0)
  
  -- 4. Verify GeofenceExit for zone A
  receivedMessages = vmsSW:waitForMessagesByName({"GeofenceExit", "GeofenceEntry"})
  local geofenceExit = receivedMessages.GeofenceExit
  assert_not_nil(geofenceExit, "GeofenceExit not received")

  geofenceExit:_equal(geofenceEntry, nil, {"Timestamp", "Latitude", "Longitude", "MIN", "Name"})
  
  geofenceExit:_verify({
    Latitude = {assert_equal, GPS:denormalize(zone0.centerLatitude)},
    Longitude = {assert_equal, GPS:denormalize(zone0.centerLongitude)},
  })

  local state = vmsSW:decodeBitmap(geofenceExit.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as outside geofence zone") 
  
  -- 5. Verify GeofenceEntry for zone B
  local geofenceEntry2 = receivedMessages.GeofenceEntry
  assert_not_nil(geofenceEntry, "GeofenceEntry2 not received")
    
  geofenceEntry2:_verify({
    FenceId = {assert_equal, zone0.number},
    Latitude = {assert_equal, GPS:denormalize(zone0.centerLatitude)},
    Longitude = {assert_equal, GPS:denormalize(zone0.centerLongitude)},
    Course  = {assert_equal, fix.heading},
    Speed = {assert_equal, vmsSW:speedGpsToVms(fix.speed), 1},
  })
  
  state = vmsSW:decodeBitmap(geofenceEntry2.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as outside geofence zone") 
  
  -- Exit second geofence
  -- 6. Go outside zones
  vmsSW:setHighWaterMark()
  local geofenceExitFix = {latitude = 1, longitude = 2}
  GPS:set(geofenceExitFix)
  
  -- 7. Verify GeofenceExit for zone B
  receivedMessages = vmsSW:waitForMessagesByName("GeofenceExit")
  local geofenceExit2 = receivedMessages.GeofenceExit
  assert_not_nil(geofenceExit2, "GeofenceExit not received")

  geofenceExit2:_equal(geofenceEntry2, nil, {"Timestamp", "Latitude", "Longitude", "StatusBitmap", "MIN", "Name"})
  
  geofenceExit2:_verify({
    Latitude = {assert_equal, GPS:denormalize(geofenceExitFix.latitude)},
    Longitude = {assert_equal, GPS:denormalize(geofenceExitFix.longitude)},
  })
  
  state = vmsSW:decodeBitmap(geofenceExit2.StatusBitmap, "EventStateId")
  assert_false(state.InsideGeofence, "Terminal incorrectly repored as inside geofence zone")  
  
end

-- TODO: Test HDOP, NumSats, IdpCnr - currently not supported by simulator
-- TODO: test when terminal inside more than one geofence