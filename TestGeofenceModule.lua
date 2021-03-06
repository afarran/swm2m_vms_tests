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
  vmsSW:setPropertiesByName({
      InsideGeofenceSendReport = true, 
      InsideGeofenceStartDebounceTime = 0, 
      InsideGeofenceEndDebounceTime = 0,
      StandardReport1Interval = 1,
    })
  geofenceSW:setPropertiesByName(geofenceSettings)
  geofenceSW:setRectangle(zone1)
  geofenceSW:setRectangle(zone0)
  
  geofenceSW:goOutside()
  vmsSW:setHighWaterMark()
  geofenceSW:goInside(zone1, nil, 0)
  local receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport")
  vmsSW:setPropertiesByName({InsideGeofenceSendReport = false})
  geofenceSW:goOutside(0)
  receivedMessages = vmsSW:waitForMessagesByName("GeofenceExit")
end

--- Disable two geofence zones.
-- Restore VMS Geofence properties.
function suite_teardown()
  geofenceSW:disableFence(zone0.number)
  geofenceSW:disableFence(zone1.number)
  vmsSW:setPropertiesByName({
      InsideGeofenceSendReport = false, 
      InsideGeofenceStartDebounceTime = 0, 
      InsideGeofenceEndDebounceTime = 0,
      StandardReport1Interval = 1,
    })  
end

--- setup function
function setup()
  gateway.setHighWaterMark()
  D:log("Setup complete")
end

-----------------------------------------------------------------------------------------------
--- Exit all geofences
function teardown()
  vmsSW:setPropertiesByName({InsideGeofenceSendReport = false, InsideGeofenceStartDebounceTime = 0, InsideGeofenceEndDebounceTime = 0})
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
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZone_StandardReportStatusBitmapInsideGeofenceBitIsSet()
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
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZone_VMSPropertyInsideGeofenceIsSetToTrue()
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
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZone_AcceleratedReportStatusBitmapInsideGeofenceBitIsSet()
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
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZone_GeofenceEntryIsSent()
  
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
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZoneThenGoesOutside_GeofenceExitIsSent()
  
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

--- Check if correct AbnormalReport is sent on geofence entry when InsideGeofenceSendReport is set to true
-- Verifies: EventType, StatusBitmap
-- 1. Enable InsideGeofenceSendReport
-- 2. Go inside zone A
-- 3. Wait for AbnormalReport
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZoneAndInsideGeofenceSendReportTrue_AbnormalReportIsSent()
  vmsSW:setPropertiesByName({InsideGeofenceSendReport = true})

  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  
  local receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport")
  local abnormalReport = receivedMessages.AbnormalReport
  
  assert_not_nil(abnormalReport, "AbnormalReport on Geofence entry not received")
  assert_equal(abnormalReport.EventType, "InsideGeofence", "Incorrect abnormal report event type")
  
  local state = vmsSW:decodeBitmap(abnormalReport.StatusBitmap, "EventStateId")
  assert_true(state.InsideGeofence, "Terminal incorrectly repored as NOT inside geofence zone")  
end

--- Check if correct AbnormalReport is sent on geofence exit when InsideGeofenceSendReport is set to true
-- Verifies: EventType, StatusBitmap
-- 1. Enable InsideGeofenceSendReport
-- 2. Go inside zone A
-- 3. Wait for AbnormalReport
-- 4. Go outside zone A
-- 5. Wait for AbnormalReport
function test_GeofenceFeatures_WhenTerminalGoesOutsideGeofenceZoneAndInsideGeofenceSendReportTrue_AbnormalReportIsSent()
  vmsSW:setPropertiesByName({InsideGeofenceSendReport = true})

  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  
  local receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport")
  local abnormalReportOnEnter = receivedMessages.AbnormalReport
  
  assert_not_nil(abnormalReportOnEnter, "AbnormalReport on Geofence entry not received")
  
  vmsSW:setHighWaterMark()
  GPS:set({latitude = 0, longitude = 0})
  receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport")
  local abnormalReportOnExit = receivedMessages.AbnormalReport
  
  assert_not_nil(abnormalReportOnExit, "AbnormalReport on Geofence exit not received")
  
  assert_equal(abnormalReportOnExit.EventType, "InsideGeofence", "Incorrect abnormal report event type")
  
  local state = vmsSW:decodeBitmap(abnormalReportOnExit.StatusBitmap, "EventStateId")
  assert_false(state.InsideGeofence, "Terminal incorrectly repored as inside geofence zone")  
  
end

--- Check if correct AbnormalReport sequence is sent on Geofence A enter, then Geofence B enter, then Geofence Exit when InsideGeofenceSendReport is set to true
-- Verifies: EventType, StatusBitmap
-- 1. Enable InsideGeofenceSendReport
-- 2. Go inside zone A
-- 3. Wait for AbnormalReport
-- 4. Go inside zone B
-- 5. Wait for AbnormalReport - should not be received
-- 6. Go outside zone B
-- 7. Wait for AbnormalReport
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZoneThenInsideOtherGeofenceZoneAndInsideGeofenceSendReportTrue_AbnormalReportIsSent()
  vmsSW:setPropertiesByName({InsideGeofenceSendReport = true})

  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  
  local receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport")
  local abnormalReportOnEnter1 = receivedMessages.AbnormalReport
  assert_not_nil(abnormalReportOnEnter1, "AbnormalReport on Geofence A entry not received")
  
  vmsSW:setHighWaterMark()
  geofenceSW:goInside(zone0)
  receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport", 10)
  local abnormalReportOnEnter2 = receivedMessages.AbnormalReport
  assert_nil(abnormalReportOnEnter2, "AbnormalReport received on Geofence B entry")
  
  vmsSW:setHighWaterMark()
  GPS:set({latitude = 0, longitude = 0})
  receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport")
  local abnormalReportOnExit = receivedMessages.AbnormalReport
  
  assert_not_nil(abnormalReportOnExit, "AbnormalReport on Geofence exit not received")
  
  assert_equal(abnormalReportOnExit.EventType, "InsideGeofence", "Incorrect abnormal report event type")
  
  local state = vmsSW:decodeBitmap(abnormalReportOnExit.StatusBitmap, "EventStateId")
  assert_false(state.InsideGeofence, "Terminal incorrectly repored as inside geofence zone")  
  
end

--- Check if correct AbnormalReport is not sent on geofence entry/exit when InsideGeofenceSendReport is set to false
-- Verifies: EventType, StatusBitmap
-- 1. Disable InsideGeofenceSendReport
-- 2. Go inside zone A
-- 3. Wait for AbnormalReport
-- 4. Go outside zone A
-- 5. Wait for AbnormalReport
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZoneThenOutsideGeofenceZoneAndInsideGeofenceSendReportFalse_AbnormalReportIsNotSent()
  vmsSW:setPropertiesByName({InsideGeofenceSendReport = false})

  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix)
  
  local receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport", 10)
  local abnormalReportOnEnter = receivedMessages.AbnormalReport

  assert_nil(abnormalReportOnEnter, "AbnormalReport on Geofence entry received")
  
  GPS:set({latitude = 0, longitude = 0})
  
  receivedMessages = vmsSW:waitForMessagesByName("AbnormalReport", 10)
  local abnormalReportOnExit = receivedMessages.AbnormalReport
  
  assert_nil(abnormalReportOnExit, "AbnormalReport on Geofence exit received")
  
end

--- Check if InsideGeofenceState property is set correctly and 
-- StatusBitmap indicates Inside Geofence after debounce time when entered geofence
-- 1. Set InsideGeofenceStartDebounceTime to 20-25 sec, and InsideGeofenceSendReport to true
-- 2. Go inside Geofence zone and wait for GeofenceEntry
-- 3. Check if InsideGeofenceState property remains false
-- 4. Wait for AbnormalReport which will be sent after debounce time
-- 5. Check if time difference between GeofenceEntry and AbnormalReport matches debounce time
-- 6. Check if status bitmap indicates that terminal is in geofence zone
-- 7. Check if InsideGeofenceState property was set to true
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZoneWithInsideGeofenceStartDebounceTime_InsideGeofenceStateIsSetAfterDebounce()
  -- 1. Set InsideGeofenceStartDebounceTime to 20-25 sec, and InsideGeofenceSendReport to true  
  local startDebounce = lunatest.random_int(20, 25)
  vmsSW:setPropertiesByName({InsideGeofenceStartDebounceTime = startDebounce, InsideGeofenceSendReport = true})

  -- 2. Go inside Geofence zone and wait for GeofenceEntry
  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix, 0)
  local geofenceEntry = vmsSW:waitForMessagesByName("GeofenceEntry")["GeofenceEntry"]
  assert_not_nil(geofenceEntry, "GeofenceEntry message not received")

  -- 3. Check if InsideGeofenceState property remains false
  local properties = vmsSW:getProperties()
  properties:_verify({InsideGeofenceState = false})
  local insideGeofence = vmsSW:decodeBitmap(geofenceEntry.StatusBitmap, "EventStateId").InsideGeofence
  assert_false(insideGeofence, "InsideGeofence in status bitmap is incorrect")

  -- 4. Wait for AbnormalReport which will be sent after debounce time
  local abnormalReport = vmsSW:waitForMessagesByName("AbnormalReport")["AbnormalReport"]
  assert_not_nil(abnormalReport, "AbnormalReport not received")
  
  -- 5. Check if time difference between GeofenceEntry and AbnormalReport matches debounce time
  assert_equal(abnormalReport.Timestamp - startDebounce, geofenceEntry.Timestamp, 10, "Timestamp of AbnormalReport indicates incorrect Debounce time")
  
  -- 6. Check if status bitmap indicates that terminal is in geofence zone
  insideGeofence = vmsSW:decodeBitmap(abnormalReport.StatusBitmap, "EventStateId").InsideGeofence
  assert_true(insideGeofence, "InsideGeofence in status bitmap is incorrect")  
  
  -- 7. Check if InsideGeofenceState property was set to true
  properties = vmsSW:getProperties()
  properties:_verify({InsideGeofenceState = true})
end


--- Check if InsideGeofenceState property is set correctly and 
-- StatusBitmap indicates Inside Geofence false after debounce time when exit geofence
-- 1. Set InsideGeofenceEndDebounceTime to 20-25 sec, and InsideGeofenceSendReport to true
-- 2. Go inside Geofence zone and wait for GeofenceEntry
-- 3. Check if InsideGeofenceState property is set to true
-- 4. Go outside Geofence zone and wait for GeofenceExit
-- 5. Check if InsideGeofenceStarte property is set to true and GeofenceExit.StatusBitmap indicates InsideGeofence true
-- 6. Wait for AbnormalReport
-- 7. Check if time difference between GeofenceExit and AbnormalReport matches debounce time
-- 8. Check if InsideGeofenceStarte property is set to false and AbnormalReport.StatusBitmap indicates InsideGeofence false
function test_GeofenceFeatures_WhenTerminalGoesInsideGeofenceZoneWithOutsideGeofenceEndDebounceTime_InsideGeofenceStateIsSetAfterDebounce()
  -- 1. Set InsideGeofenceEndDebounceTime to 20-25 sec, and InsideGeofenceSendReport to true
  local endDebounce = lunatest.random_int(20, 25)
  vmsSW:setPropertiesByName({InsideGeofenceEndDebounceTime = endDebounce, InsideGeofenceSendReport = true})


  -- 2. Go inside Geofence zone and wait for GeofenceEntry
  local fix = GPS:getRandom()
  geofenceSW:goInside(zone1, fix, 0)
  local geofenceEntry = vmsSW:waitForMessagesByName("GeofenceEntry")["GeofenceEntry"]
  assert_not_nil(geofenceEntry, "GeofenceEntry message not received")
  
  -- 3. Check if InsideGeofenceState property is set to true
  local properties = vmsSW:getProperties()
  properties:_verify({InsideGeofenceState = true})
  local insideGeofence = vmsSW:decodeBitmap(geofenceEntry.StatusBitmap, "EventStateId").InsideGeofence
  assert_true(insideGeofence, "InsideGeofence in status bitmap is incorrect")
    
  -- 4. Go outside Geofence zone and wait for GeofenceExit
  vmsSW:setHighWaterMark()
  geofenceSW:goOutside(0)
  local geofenceExit = vmsSW:waitForMessagesByName("GeofenceExit")["GeofenceExit"]
  assert_not_nil(geofenceExit, "GeofenceExit message not received")
  
  -- 5. Check if InsideGeofenceStarte property is set to true and GeofenceExit.StatusBitmap indicates InsideGeofence true
  properties = vmsSW:getProperties()
  properties:_verify({InsideGeofenceState = true})
  insideGeofence = vmsSW:decodeBitmap(geofenceExit.StatusBitmap, "EventStateId").InsideGeofence
  assert_true(insideGeofence, "InsideGeofence in status bitmap is incorrect")
  
  -- 6. Wait for AbnormalReport
  local abnormalReport = vmsSW:waitForMessagesByName("AbnormalReport")["AbnormalReport"]
  assert_not_nil(abnormalReport, "AbnormalReport not received")
  
  -- 7. Check if time difference between GeofenceExit and AbnormalReport matches debounce time
  assert_equal(abnormalReport.Timestamp - endDebounce, geofenceExit.Timestamp, 10, "Timestamp of AbnormalReport indicates incorrect Debounce time")
  
  -- 8. Check if InsideGeofenceStarte property is set to false and AbnormalReport.StatusBitmap indicates InsideGeofence false
  insideGeofence = vmsSW:decodeBitmap(abnormalReport.StatusBitmap, "EventStateId").InsideGeofence
  assert_false(insideGeofence, "InsideGeofence in status bitmap is incorrect")
  
end




-- TODO: Test HDOP, NumSats, IdpCnr - currently not supported by simulator
-- TODO: GeofenceEntry/Exit with debounce time tests