-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestNormalReportModule

module("TestNormalReportsModule", package.seeall)
DEBUG_MODE = 1

function suite_setup()
  -- reset of properties 
  systemSW:resetProperties({vmsSW.sin})

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

  -- get properties
  local propertiesToChange = {"StandardReport1Interval", "AcceleratedReport1Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport1",
    propertiesToChange ,
    propertiesBeforeChange,
    false
  )
end

function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()
  
  -- get properties
  local propertiesToChange = {"StandardReport2Interval", "AcceleratedReport2Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport2",
   propertiesToChange,
   propertiesBeforeChange,
   false
  )
end

function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent()
  
  -- get properties
  local propertiesToChange = {"StandardReport3Interval", "AcceleratedReport3Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport3",
   propertiesToChange ,
   propertiesBeforeChange,
   false
  )
end

function test_ConfigChangeReport_WhenSetConfigReport1MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()
  
  -- get properties
  local propertiesToChange = {"StandardReport1Interval", "AcceleratedReport1Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport1",
   propertiesToChange,
   propertiesBeforeChange,
   "SetConfigReport1"
  )
end

function test_ConfigChangeReport_WhenSetConfigReport2MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()
  
  -- get properties
  local propertiesToChange = {"StandardReport2Interval", "AcceleratedReport2Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport2",
   propertiesToChange,
   propertiesBeforeChange,
   "SetConfigReport2"
  )
end

function test_ConfigChangeReport_WhenSetConfigReport2MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()
  
  -- get properties
  local propertiesToChange = {"StandardReport3Interval", "AcceleratedReport3Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport3",
   propertiesToChange,
   propertiesBeforeChange,
   "SetConfigReport3"
  )
end

function test_LogReport1_WhenGpsPositionIsSetAndLogFilterEstablished_LogEntriesShouldCollectCorrectDataInCorrectInterval()
  local LOG_REPORT_RATE = 4
  local STANDARD_REPORT_INTERVAL = 4
  local LOG_REPORT_INTERVAL = STANDARD_REPORT_INTERVAL / LOG_REPORT_RATE
  local ITEMS_IN_LOG = 2

  local logReportXKey = "LogReport1"
  local standardReportXKey = "StandardReport1"
  local properties = {}

  local properties = {
    LogReport1Rate = LOG_REPORT_RATE,
    StandardReport1Interval = STANDARD_REPORT_INTERVAL
  }

  local filterTimeout = LOG_REPORT_INTERVAL*60+60
  local timeForLogging = ITEMS_IN_LOG*LOG_REPORT_INTERVAL*60+20
  local itemsInLog = ITEMS_IN_LOG

  generic_test_LogReports(logReportXKey, standardReportXKey, properties, filterTimeout, timeForLogging, itemsInLog, LOG_REPORT_INTERVAL)
end

function test_LogReport2_WhenGpsPositionIsSetAndLogFilterEstablished_LogEntriesShouldCollectCorrectDataInCorrectInterval()
  local LOG_REPORT_RATE = 4
  local STANDARD_REPORT_INTERVAL = 4
  local LOG_REPORT_INTERVAL = STANDARD_REPORT_INTERVAL / LOG_REPORT_RATE
  local ITEMS_IN_LOG = 2

  local logReportXKey = "LogReport2"
  local standardReportXKey = "StandardReport2"
  local properties = {}

  local properties = {
    LogReport2Rate = LOG_REPORT_RATE,
    StandardReport2Interval = STANDARD_REPORT_INTERVAL
  }

  local filterTimeout = LOG_REPORT_INTERVAL*60+60
  local timeForLogging = ITEMS_IN_LOG*LOG_REPORT_INTERVAL*60+20
  local itemsInLog = ITEMS_IN_LOG

  generic_test_LogReports(logReportXKey, standardReportXKey, properties, filterTimeout, timeForLogging, itemsInLog, LOG_REPORT_INTERVAL)
end

function test_LogReport3_WhenGpsPositionIsSetAndLogFilterEstablished_LogEntriesShouldCollectCorrectDataInCorrectInterval()
  local LOG_REPORT_RATE = 4
  local STANDARD_REPORT_INTERVAL = 4
  local LOG_REPORT_INTERVAL = STANDARD_REPORT_INTERVAL / LOG_REPORT_RATE
  local ITEMS_IN_LOG = 2

  local logReportXKey = "LogReport3"
  local standardReportXKey = "StandardReport3"
  local properties = {}

  local properties = {
    LogReport3Rate = LOG_REPORT_RATE,
    StandardReport3Interval = STANDARD_REPORT_INTERVAL
  }

  local filterTimeout = LOG_REPORT_INTERVAL*60+60
  local timeForLogging = ITEMS_IN_LOG*LOG_REPORT_INTERVAL*60+20
  local itemsInLog = ITEMS_IN_LOG

  generic_test_LogReports(logReportXKey, standardReportXKey, properties, filterTimeout, timeForLogging, itemsInLog, LOG_REPORT_INTERVAL)
end

function generic_test_LogReports(logReportXKey, standardReportXKey, properties, filterTimeout, timeForLogging, itemsInLog, logReportInterval)

  -- prerequisites
  assert_lt(3,itemsInLog,0,"There should be min 2 log items! Configure TC!")

  -- set properties for log interval
  vmsSW:setPropertiesByName(properties)

  -- set position for reports
  gpsPosition = GPS:setRandom()

  --set log filter
  logSW:setLogFilter(
    vmsSW.sin, {
    vmsSW:getMinFrom(logReportXKey)}, 
    os.time()+5, 
    os.time()+filterTimeout, 
    "True"
  )

  --synchronize first standard report
  vmsSW:waitForMessagesByName(standardReportXKey)

  -- wait for log reports
  framework.delay(timeForLogging)

  -- get reports from log
  logEntries = logSW:getLogEntries(itemsInLog)

  -- check if data is correct
  for i=1, #logEntries do
    D:log(logEntries[i].log,"entry "..i)
    -- latitude
    assert_equal(
      GPS:denormalize(gpsPosition.latitude),
      tonumber(logEntries[i].log.Latitude),
      0,
      "Wrong latitude in Log Report, entry: "..i
    )
    assert_equal(
      GPS:denormalize(gpsPosition.longitude),
      tonumber(logEntries[i].log.Longitude),
      0,
      "Wrong longitude in Log Report, entry: "..i
    )
    assert_equal(
      GPS:denormalizeSpeed(gpsPosition.speed),
      tonumber(logEntries[i].log.Speed),
      1,
      "Wrong speed in Log Report, entry: "..i
    )
    -- some of values are being checked just for their existance
    assert_not_nil(
      logEntries[i].log.Timestamp,
      "No timestamp in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.Course,
      "No Course in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.Hdop,
      "No Hdop in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.NumSats,
      "No NumSats in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.IdpCnr,
      "No IdpCnr in Log Entry, entry: " .. i
    )
    if i>1 then
      -- check if timeout between log entries is correct
      local timeDiff = tonumber(logEntries[i-1].log.Timestamp) - tonumber(logEntries[i].log.Timestamp)
      assert_equal(
        logReportInterval*60, 
        timeDiff, 
        5, 
        "Log Report Interval should be "..(logReportInterval*60)
      )
    end
  end

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
    firstReportInterval*60*2
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
    reportInterval*60*2
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
function generic_test_ConfigChangeReportConfigChangeReportIsSent(messageKey,propertiesToChange,propertiesBeforeChange,setConfigMsgKey)
  
  propertiesToChangeValues = {}
  propertiesToChangeValues2 = {}
  propertiesToChangeValuesForMessage = {}

  for i=1, #propertiesToChange do
    propertiesToChangeValues[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 1
    propertiesToChangeValues2[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 2
    table.insert(
      propertiesToChangeValuesForMessage, 
      { Name = propertiesToChange[i],  Value = (propertiesBeforeChange[propertiesToChange[i]] + 2) }
    )
  end

  -- properties must be changedd anyway (the same value after and before properties reset doesn't trigger report)
  vmsSW:setPropertiesByName( propertiesToChangeValues)

  -- testing via message
  if setConfigMsgKey then
    -- raport triggered by setProperties is passed
    vmsSW:waitForMessagesByName(
      {messageKey},
      30
    )
    -- change config to trigger ConfigChange message (SetConfigReportX used)
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      propertiesToChangeValuesForMessage
    )
  end
 
  -- wait for message 
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

  -- checking if raported values are correct
  for i=1, #propertiesToChange do
    local exp
    if setConfigMsgKey then
      exp = tonumber(propertiesToChangeValues2[propertiesToChange[i]])
    else
      exp = tonumber(propertiesToChangeValues[propertiesToChange[i]])
    end
    assert_equal(
      tonumber(configChangeMessage[messageKey][propertiesToChange[i]]),
      exp,  
      0,
      "Property " .. propertiesToChange[i] .. " has not changed!"
    )
  end
end
