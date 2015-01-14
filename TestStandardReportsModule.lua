-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestReportingModule

module("TestStandardReportsModule", package.seeall)


function suite_setup()
  -- reset of properties _ 
  -- restarting VMS agent ?
  
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  
  -- gps setup
  pos = {
    latitude  = 0,
    longitude = 0,
    speed =  0
  }
  GPS:set(pos)
  
end

-- executed after each test suite
function suite_teardown()
end

--- setup function
function setup()
  
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
  
end

-------------------------
-- Test Cases
-------------------------

--- TC checks if StandardReport 1 is sent periodically and its values are correct.
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  --
  -- Steps:
  --
  -- 1. Position "getPosition" message is sent.
  -- 2. Test set of gps values is prepared.
  -- 3. Waiting for Status Report is performed.
  -- 4. Report Values are checked.
  --
  -- Results:
  --
  -- 1. Positon "position" message is received and its value checked
  -- 2. GPS is set.
  -- 3. Status Report is received
  -- 4. Report Values are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent("StandardReport1", {StandardReport1Interval=1})
end

--- TC checks if StandardReport 2 is sent periodically and its values are correct.
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  --
  -- Steps:
  --
  -- 1. Position "getPosition" message is sent.
  -- 2. Test set of gps values is prepared.
  -- 3. Waiting for Status Report is performed.
  -- 4. Report Values are checked.
  --
  -- Results:
  --
  -- 1. Positon "position" message is received and its value checked
  -- 2. GPS is set.
  -- 3. Status Report is received
  -- 4. Report Values are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent("StandardReport2", {StandardReport2Interval=1})
end

--- TC checks if StandardReport 3 is sent periodically and its values are correct.
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  --
  -- Steps:
  --
  -- 1. Position "getPosition" message is sent.
  -- 2. Test set of gps values is prepared.
  -- 3. Waiting for Status Report is performed.
  -- 4. Report Values are checked.
  --
  -- Results:
  --
  -- 1. Positon "position" message is received and its value checked
  -- 2. GPS is set.
  -- 3. Status Report is received
  -- 4. Report Values are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent("StandardReport3", {StandardReport3Interval=1})
  --framework.delay(30)
end

function generic_test_StandardReportContent(reportKey,properties)
  
  vmsSW:setPropertiesByName(properties)
   
  positionSW:sendMessageByName(
    "getPosition",
    {fixType = "3D"}
  )
  
  local positionMessage = positionSW:waitForMessagesByName({"position"}) 
  local initialPosition = positionMessage.position
  
  assert_not_nil(
    initialPosition.longitude,
    "No longitude in position messsage."
  )
  assert_not_nil(
    initialPosition.latitude,
    "No latitude in position messsage."
  )
  assert_not_nil(
    initialPosition.speed,
    "No speed in position messsage."
  )
  
  -- wait for raport to ensure that values will be fetched from current gps changes
  vmsSW:waitForMessagesByName({reportKey})
  
  local newPosition = {
    latitude  = GPS:normalize(initialPosition.latitude)   + 1,
    longitude = GPS:normalize(initialPosition.longitude)  + 1,
    speed =  GPS:normalizeSpeed(initialPosition.speed) -- km/h
  }
  GPS:set(newPosition)

  local reportMessage = vmsSW:waitForMessagesByName({reportKey})
  assert_equal(
    GPS:denormalize(newPosition.latitude), 
    tonumber(reportMessage[reportKey].Latitude), 
    "Wrong latitude in " .. reportKey
  )
  assert_equal(
    GPS:denormalize(newPosition.longitude), 
    tonumber(reportMessage[reportKey].Longitude), 
    "Wrong longitude in " .. reportKey
  )
  assert_equal(
    GPS:denormalizeSpeed(newPosition.speed), 
    tonumber(reportMessage[reportKey].Speed), 
    1,
    "Wrong speed in " .. reportKey
  )
  
  assert_not_nil(
    reportMessage[reportKey].Timestamp,
    "No timestamp in " .. reportKey
  )
  
  assert_not_nil(
    reportMessage[reportKey].Course,
    "No Course in " .. reportKey
  )
  
  assert_not_nil(
    reportMessage[reportKey].Hdop,
    "No Hdop in " .. reportKey
  )
  
  assert_not_nil(
    reportMessage[reportKey].NumSats,
    "No NumSats in " .. reportKey
  )
  
  assert_not_nil(
    reportMessage[reportKey].IdpCnr,
    "No IdpCnr in " .. reportKey
  )
  
  assert_not_nil(
    reportMessage[reportKey].StatusBitmap,
    "No StatusBitmap in " .. reportKey
  )
  
end

--TODO: timeout, accelerated reports 
