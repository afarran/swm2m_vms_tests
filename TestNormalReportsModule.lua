-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestNormalReportModule

module("TestNormalReportsModule", package.seeall)

function suite_setup()
  -- reset of properties 
  systemSW:resetProperties(vmsSW.sin)

  -- debounce
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
  generic_test_StandardReportContent(
    "StandardReport1", 
    "StandardReport1", 
    {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    1, 
    1
  )
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
  generic_test_StandardReportContent(
    "StandardReport2", 
    "StandardReport2", 
    {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    1, 
    1
  )
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
  generic_test_StandardReportContent(
    "StandardReport3", 
    "StandardReport3", 
    {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    1, 
    1
  )
end

function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport1", 
    "AcceleratedReport1", 
    {StandardReport1Interval=2, AcceleratedReport1Rate=2},
    2, 
    1
  )
end

function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport2IsSentWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport2", 
    "AcceleratedReport2", 
    {StandardReport2Interval=2, AcceleratedReport2Rate=2},
    2, 
    1
  )
end

function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport3IsSentWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport3", 
    "AcceleratedReport3", 
    {StandardReport3Interval=2, AcceleratedReport3Rate=2},
    2, 
    1
  )
end

function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport1IsSent()
  generic_test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReportIsSent(
   "ConfigChangeReport1",
   {"StandardReport1Interval", "AcceleratedReport1Rate"}
  )
end

function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()
  generic_test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReportIsSent(
   "ConfigChangeReport2",
   {"StandardReport2Interval", "AcceleratedReport2Rate"}
  )
end

function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent()
  generic_test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReportIsSent(
   "ConfigChangeReport3",
   {"StandardReport3Interval", "AcceleratedReport3Rate"}
  )
end

-- This is generic function for configure and test reports (StandardReport,AcceleratedReport)
function generic_test_StandardReportContent(firstReportKey,reportKey,properties,firstReportInterval,reportInterval)
 
  -- reports setup 
  vmsSW:setPropertiesByName(properties)
  
  -- fetching current position info 
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
  -- and to synchronize report sequence
  D:log("Waiting for first report "..firstReportKey)
  local preReportMessage = vmsSW:waitForMessagesByName(
    {firstReportKey},
    firstReportInterval*60 + 10
  )
  assert_not_nil(
    preReportMessage,
    "First Report not received"
  )
  assert_not_nil(
    preReportMessage[firstReportKey],
    "First Report not received!"
  )
  local timestampStart = preReportMessage[firstReportKey].Timestamp 
  
  -- new position setup
  local newPosition = {
    latitude  = GPS:normalize(initialPosition.latitude)   + 1,
    longitude = GPS:normalize(initialPosition.longitude)  + 1,
    speed =  GPS:normalizeSpeed(initialPosition.speed) -- km/h
  }
  GPS:set(newPosition)

  -- wait for next report
  D:log("Waiting for second report "..reportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey}, 
    reportInterval*60 + 10
  )
  assert_not_nil(
    reportMessage,
    "Second Report not received"
  )
  assert_not_nil(
    reportMessage[reportKey],
    "Second Report not received"
  )

  -- calculate time diff
  local timestampEnd = reportMessage[reportKey].Timestamp 
  local timestampDiff = timestampEnd - timestampStart
  assert_equal(
    reportInterval*60,
    timestampDiff,
    5,
    "Wrong time diff between raports"
  )

  -- check values
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
  
  -- some of values are being checked just for their existance
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

-- this is generic function for testing Config Change Reports
function generic_test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReportIsSent(messageKey,propertiesToChange)
  -- get properties
  propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))
  
  propertiesToChangeValues = {}

  for i=1, #propertiesToChange do
    propertiesToChangeValues[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 1
  end

  -- change config to trigger ConfigChange message
  vmsSW:setPropertiesByName( propertiesToChangeValues)
  local configChangeMessage = vmsSW:waitForMessagesByName(
    {messageKey},
    30
  )
  assert_not_nil(
    configChangeMessage,
    "No "..messageKey
  )
  assert_not_nil(
    configChangeMessage[messageKey],
    "No "..messageKey
  )
  --D:log(framework.dump(configChangeMessage))

  -- checking if raported values are correct
  for i=1, #propertiesToChange do
    assert_equal(
      tonumber(configChangeMessage[messageKey][propertiesToChange[i]]),   
      tonumber(propertiesToChangeValues[propertiesToChange[i]]),
      0,
      "Property " .. propertiesToChange[i] .. " has not changed!"
    )
  end
end

