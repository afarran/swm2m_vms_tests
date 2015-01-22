-----------------------------------------------------------------------------------------------
-- VMS Normal Reporting test module
-----------------------------------------------------------------------------------------------
-- Contains VMS reporting features (Standard, Accelerated , Log , ConfigChange reports)
-----------------------------------------------------------------------------------------------
-- @module TestNormalReportModule
-----------------------------------------------------------------------------------------------

module("TestNormalReportsModule", package.seeall)
DEBUG_MODE = 1

-----------------------------------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------------------------------
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
  vmsSW:setHighWaterMark()
end

--- teardown function executed after each unit test
function teardown()
  
end
-----------------------------------------------------------------------------------------------
-- Test Cases for STANDARD REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if StandardReport 1 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport1", 
    "StandardReport1", 
    {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    1, 
    1
  )
end

--- TC checks if StandardReport 2 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport2", 
    "StandardReport2", 
    {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    1, 
    1
  )
end

--- TC checks if StandardReport 3 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport3", 
    "StandardReport3", 
    {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    1, 
    1
  )
end

--- TC checks if StandardReport 1 is sent periodically and its values are correct (SetConfigReport1 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. SetConfigReport1 message is sent .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport1 is received.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport1MessageIsSent_StandardReport1IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport1",
    "StandardReport1",
    {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    1,
    1,
    "SetConfigReport1",
    "ConfigChangeReport1",
    {
      {Name = "StandardReport1Interval" , Value = 1},
      {Name = "AcceleratedReport1Rate" , Value = 1}
    }
  )
end

--- TC checks if StandardReport 2 is sent periodically and its values are correct (SetConfigReport2 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. SetConfigReport2 message is sent .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport2 is received.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport2MessageIsSent_StandardReport2IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport2",
    "StandardReport2",
    {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    1,
    1,
    "SetConfigReport2",
    "ConfigChangeReport2",
    {
      {Name = "StandardReport2Interval" , Value = 1},
      {Name = "AcceleratedReport2Rate" , Value = 1}
    }
  )
end

--- TC checks if StandardReport 3 is sent periodically and its values are correct (SetConfigReport3 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. SetConfigReport3 message is sent .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport3 is received.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport3MessageIsSent_StandardReport3IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport3",
    "StandardReport3",
    {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    1,
    1,
    "SetConfigReport3",
    "ConfigChangeReport3",
    {
      {Name = "StandardReport3Interval" , Value = 1},
      {Name = "AcceleratedReport3Rate" , Value = 1}
    }
  )
end

--- TC checks if StandardReport 1 is not sent
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set to 0.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report doesn't come and that is correct.
function test_StandardReportDisabled_WhenStandardReport1IntervalIsSetToZero_StandardReport1IsNotSent()
  generic_test_StandardReportDisabled(
    "StandardReport1",
    {StandardReport1Interval=0, AcceleratedReport1Rate=1},
    70 -- waiting until report not come
  )
end

-- TC checks if StandardReport 2 is not sent
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set to 0.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report doesn't come and that is correct.
function test_StandardReportDisabled_WhenStandardReport2IntervalIsSetToZero_StandardReport2IsNotSent()
  generic_test_StandardReportDisabled(
    "StandardReport2",
    {StandardReport2Interval=0, AcceleratedReport2Rate=1},
    70 -- waiting until report not come
  )
end

-- TC checks if StandardReport 3 is not sent
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set to 0.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report doesn't come and that is correct.
function test_StandardReportDisabled_WhenStandardReport3IntervalIsSetToZero_StandardReport3IsNotSent()
  generic_test_StandardReportDisabled(
    "StandardReport3",
    {StandardReport3Interval=0, AcceleratedReport3Rate=1},
    70 
  )
end

-----------------------------------------------------------------------------------------------
-- Test Cases for ACCELERATED REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if AcceleratedReport 1 is sent periodically and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 2 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport1", 
    "AcceleratedReport1", 
    {StandardReport1Interval=2, AcceleratedReport1Rate=2},
    2, 
    1
  )
end

--- TC checks if AcceleratedReport 2 is sent periodically and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 2 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport2IsSentWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport2", 
    "AcceleratedReport2", 
    {StandardReport2Interval=2, AcceleratedReport2Rate=2},
    2, 
    1
  )
end

--- TC checks if AcceleratedReport 3 is sent periodically and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 2 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport3IsSentWithCorrectValues()
  generic_test_StandardReportContent(
    "StandardReport3", 
    "AcceleratedReport3", 
    {StandardReport3Interval=2, AcceleratedReport3Rate=2},
    2, 
    1
  )
end

--- TC checks if StandardReport 1 is sent and accelerated report is not sent.
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set to 1.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  -- 3. Waiting for Accelerated Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report is sent correctly.
  -- 3. Accelerated Report is not sent and that is correct.
function test_AcceleratedReportDisabledAndStandardReportEnabled_WhenStandardReport1IntervalIsSetAboveZeroAndAcceleratedReportInterval1DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport1",
    "AcceleratedReport1",
    {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    70 -- waiting until report not come
  )
end

--- TC checks if StandardReport 2 is sent and accelerated report is not sent.
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set to 1.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  -- 3. Waiting for Accelerated Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report is sent correctly.
  -- 3. Accelerated Report is not sent and that is correct.
function test_AcceleratedReportDisabledAndStandardReportEnabled_WhenStandardReport2IntervalIsSetAboveZeroAndAcceleratedReportInterval2DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport2",
    "AcceleratedReport2",
    {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    70 -- waiting until report not come
  )
end

--- TC checks if StandardReport 3 is sent and accelerated report is not sent.
  -- Initial Conditions:
  --
  -- * StandardRepor3Interval is set to 1.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  -- 3. Waiting for Accelerated Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report is sent correctly.
  -- 3. Accelerated Report is not sent and that is correct.
function test_AcceleratedReportDisabledAndStandardReportEnabled_WhenStandardReport3IntervalIsSetAboveZeroAndAcceleratedReportInterval3DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport3",
    "AcceleratedReport3",
    {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    70 -- waiting until report not come
  )
end

-----------------------------------------------------------------------------------------------
-- Test Cases for CONFIG CHANGE REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if ConfigChangeReport 1 is sent and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport1Interval and AcceleratedReport1Rate are requested
  -- * Properties are received and used in TC. 
  --
  -- Steps:
  --
  -- 1. Modified properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport1 is performed.
  -- 3. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport is received.
  -- 3. Report values are correct.
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

--- TC checks if ConfigChangeReport 2 is sent and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport2Interval and AcceleratedReport2Rate are requested
  -- * Properties are received and used in TC. 
  --
  -- Steps:
  --
  -- 1. Modified properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport2 is performed.
  -- 3. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport is received.
  -- 3. Report values are correct.
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

--- TC checks if ConfigChangeReport 3 is sent and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport3Interval and AcceleratedReport3Rate are requested
  -- * Properties are received and used in TC. 
  --
  -- Steps:
  --
  -- 1. Modified properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport3 is performed.
  -- 3. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport is received.
  -- 3. Report values are correct.
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

--- TC checks if ConfigChangeReport 1 is sent and its values are correct (message SetConfigReport1 used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport1Interval and AcceleratedReport1Rate are requested
  -- * Properties are received and used in TC. 
  --
  -- Steps:
  --
  -- 1. Properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport1 is performed.
  -- 3. Message SetConfigReport1 is sent (with changed properties)
  -- 4. Waiting for message ConfigChangeReport1 is performed.
  -- 5. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport1 is received.
  -- 3. Message SetConfigReport1 is correctly sent.
  -- 4. Message ConfigChangeReport1 is received.
  -- 5. Report values are correct.
function test_ConfigChangeReport_WhenSetConfigReport1MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport1IsSent()
  
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

--- TC checks if ConfigChangeReport 2 is sent and its values are correct (message SetConfigReport2 used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport2Interval and AcceleratedReport2Rate are requested
  -- * Properties are received and used in TC. 
  --
  -- Steps:
  --
  -- 1. Properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport2 is performed.
  -- 3. Message SetConfigReport2 is sent (with changed properties)
  -- 4. Waiting for message ConfigChangeReport2 is performed.
  -- 5. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport2 is received.
  -- 3. Message SetConfigReport2 is correctly sent.
  -- 4. Message ConfigChangeReport2 is received.
  -- 5. Report values are correct.
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

--- TC checks if ConfigChangeReport 3 is sent and its values are correct (message SetConfigReport3 used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport3Interval and AcceleratedReport3Rate are requested
  -- * Properties are received and used in TC. 
  --
  -- Steps:
  --
  -- 1. Properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport3 is performed.
  -- 3. Message SetConfigReport3 is sent (with changed properties)
  -- 4. Waiting for message ConfigChangeReport3 is performed.
  -- 5. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport3 is received.
  -- 3. Message SetConfigReport3 is correctly sent.
  -- 4. Message ConfigChangeReport3 is received.
  -- 5. Report values are correct.
function test_ConfigChangeReport_WhenSetConfigReport3MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent()
  
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

-----------------------------------------------------------------------------------------------
-- Test Cases for LOG REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if Log Report 1 is sent periodically  and its values are correct.
  -- Initial Conditions:
  --
  -- * There should be min 2 log items configured in TC setup.
  --
  -- Steps:
  --
  -- 1. Properties are set (LogReport1,StandardReport1).
  -- 2. Random gps position is requested via GpsFrontend.
  -- 3. Log filter is configured (Log agent)
  -- 4. Waiting for first standard report is performed.
  -- 5. Delay is performed for collecting logs.
  -- 6. Logs values are checked.
  -- 7. Spacer times between logs are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Gps position is set.
  -- 3. Log filter is set.
  -- 4. Timer is synchronized to the first standard report
  -- 5. Logs are collected.
  -- 6. Logs values are correct.
  -- 7. Spacer times between logs are correct.
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

--- TC checks if Log Report 2 is sent periodically  and its values are correct.
  -- Initial Conditions:
  --
  -- * There should be min 2 log items configured in TC setup.
  --
  -- Steps:
  --
  -- 1. Properties are set (LogReport2,StandardReport2).
  -- 2. Random gps position is requested via GpsFrontend.
  -- 3. Log filter is configured (Log agent)
  -- 4. Waiting for first standard report is performed.
  -- 5. Delay is performed for collecting logs.
  -- 6. Logs values are checked.
  -- 7. Spacer times between logs are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Gps position is set.
  -- 3. Log filter is set.
  -- 4. Timer is synchronized to the first standard report
  -- 5. Logs are collected.
  -- 6. Logs values are correct.
  -- 7. Spacer times between logs are correct.
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

--- TC checks if Log Report 3 is sent periodically  and its values are correct.
  -- Initial Conditions:
  --
  -- * There should be min 2 log items configured in TC setup.
  --
  -- Steps:
  --
  -- 1. Properties are set (LogReport3,StandardReport3).
  -- 2. Random gps position is requested via GpsFrontend.
  -- 3. Log filter is configured (Log agent)
  -- 4. Waiting for first standard report is performed.
  -- 5. Delay is performed for collecting logs.
  -- 6. Logs values are checked.
  -- 7. Spacer times between logs are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Gps position is set.
  -- 3. Log filter is set.
  -- 4. Timer is synchronized to the first standard report
  -- 5. Logs are collected.
  -- 6. Logs values are correct.
  -- 7. Spacer times between logs are correct.
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

-----------------------------------------------------------------------------------------------
-- DEFAULT VALUES tests
-----------------------------------------------------------------------------------------------

function test_DefaultValues_WhenPropertiesAreRequestedAfterPropertiesReset_CorrectDefaultValuesAreGiven()
  -- reset of properties 
  systemSW:resetProperties({vmsSW.sin})

   -- get properties
  local propertiesToCheck = {
    "StandardReport1Interval",
    "AcceleratedReport1Rate", 
    "LogReport1Rate", 
    "StandardReport2Interval",
    "AcceleratedReport2Rate", 
    "LogReport2Rate", 
    "StandardReport3Interval",
    "AcceleratedReport3Rate", 
    "LogReport3Rate", 
  }

  local propertiesValues = {
    StandardReport1Interval = 60,
    AcceleratedReport1Rate = 1,
    LogReport1Rate = 1,
    StandardReport2Interval = 60,
    AcceleratedReport2Rate = 1,
    LogReport2Rate = 1, 
    StandardReport3Interval = 60,
    AcceleratedReport3Rate = 1,
    LogReport3Rate = 1 
  }

  local propertiesFetched = vmsSW:getPropertiesByName(propertiesToCheck)

  for key,value in pairs(propertiesValues) do
    assert_not_nil(propertiesFetched[key],"Property "..key.." not found!")
    assert_equal(value,tonumber(propertiesFetched[key]),"Property "..key.." - wrong default ")
  end
end

-----------------------------------------------------------------------------------------------
-- DRIFT OVER TIME 
-- The Report Capability shall ensure that periodic reports do not drift over time.
-----------------------------------------------------------------------------------------------

 
function test_DriftOverTime_Standard1AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport1Interval=4, AcceleratedReport1Rate=4},
    "ConfigChangeReport1",
    "StandardReport1",
    "AcceleratedReport1",
    4, --min
    1, --min
    3
  )
end

function test_DriftOverTime_Standard2AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport2Interval=4, AcceleratedReport2Rate=4},
    "ConfigChangeReport2",
    "StandardReport2",
    "AcceleratedReport2",
    4, --min
    1, --min
    3
  )
end

function test_DriftOverTime_Standard3AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport3Interval=4, AcceleratedReport3Rate=4},
    "ConfigChangeReport3",
    "StandardReport3",
    "AcceleratedReport3",
    4, --min
    1, --min
    3
  )
end

function generic_test_DriftOverTime_StandardAndAccelerated(properties,configChangeMsgKey,SRKey,ARKey,SRInterval,ARInterval,ARItems)
  
  local tolerance = 40 --secs
  local lastTimestamp = 0
  local dataToAnalysis = {}

  vmsSW:setPropertiesByName(properties)

  vmsSW:waitForMessagesByName(
    {configChangeMsgKey},
    30
  )

  D:log("Waiting for first standard report "..SRKey)
  local message = vmsSW:waitForMessagesByName(
    {SRKey},
    SRInterval*60 + 2 * tolerance
  )
  assert_not_nil(
    message,
    "First Standard Report not received"
  )
  assert_not_nil(
    message[SRKey],
    "First Standard Report not received!"
  )
  assert_not_nil(
    message[SRKey].Timestamp,
    "Timestamp in Standard Report not received! "..SRKey
  )

  lastTimestamp = tonumber(message[SRKey].Timestamp)

  for i=1,ARItems do
    -- simulate system overload to trigger drift 
    if i == 1 then
      D:log("Simulating system overload..")
      local overloadThread = coroutine.create(
        function()
          shellSW:eval("local stime = os.time();while 1 do if os.time() - stime > 90 then break end end")
        end
      )
      coroutine.resume(overloadThread)
    end
    D:log("Waiting for accelerated report "..ARKey)
    local message = vmsSW:waitForMessagesByName(
      {ARKey},
      ARInterval*60 + tolerance
    )
    assert_not_nil(
      message,
      "Accelerated Report not received! Number in sequence: "..i
    )
    assert_not_nil(
      message[ARKey],
      "Accelerated Report not received! Number in sequence: "..i
    )
    assert_not_nil(
      message[ARKey].Timestamp,
      "Timestamp in Accelerated Report not received!"
    )
    local diff = tonumber(message[ARKey].Timestamp) - lastTimestamp
    D:log(diff,"time-diff")
    lastTimestamp = tonumber(message[ARKey].Timestamp)
    table.insert(dataToAnalysis,diff)
  end
    
  D:log("Waiting for last standard report "..SRKey)
  local message = vmsSW:waitForMessagesByName(
    {SRKey},
    ARInterval*60 + tolerance -- last report with AR interval!
  )
  assert_not_nil(
    message,
    "Last Standard Report not received"
  )
  assert_not_nil(
    message[SRKey],
    "Lat Standard Report not received!"
  )
  assert_not_nil(
    message[SRKey].Timestamp,
    "Timestamp in Standard Report not received!"
  )
  local diff = tonumber(message[SRKey].Timestamp) - lastTimestamp

  table.insert(dataToAnalysis,diff)
  D:log(dataToAnalysis,"final-data")

  -- perform data analysis
  require("Infrastructure/DataAnalyse/DriftAnalyse")
  driftAnalyse = DriftAnalyse()
  assert_true(
    driftAnalyse:perform(dataToAnalysis,60,2,-2),
    "Found inconsistency in scheduling reports! Reports: "..SRKey .. " / "..ARKey
  )

end

-----------------------------------------------------------------------------------------------
-- GENERIC LOGIC for test cases
-----------------------------------------------------------------------------------------------

-- generic logic for Log Reports TCs
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
function generic_test_StandardReportContent(firstReportKey,reportKey,properties,firstReportInterval,reportInterval,setConfigMsgKey,configChangeMsgKey,fields)
 
  -- testing via message
  if setConfigMsgKey then
    D:log(setConfigMsgKey,"X1")
    D:log(fields,"X2")
    -- change config to trigger ConfigChange message (SetConfigReportX used)
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      fields
    )
    vmsSW:waitForMessagesByName(
      {configChangeMsgKey},
      30
    )
  else
    vmsSW:setPropertiesByName(properties)
  end
  
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

-- This is generic function for disabled standard reports test
function generic_test_StandardReportDisabled(reportKey,properties,reportInterval,setConfigMsgKey,configChangeMsgKey,fields)
  
  -- setup
  if setConfigMsgKey then
    D:log(setConfigMsgKey,"X1")
    D:log(fields,"X2")
    -- change config
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      fields
    )
    vmsSW:waitForMessagesByName(
      {configChangeMsgKey},
      30
    )
  else
    vmsSW:setPropertiesByName(properties)
  end
  
  D:log("Waiting for report - should not come - "..reportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey},
    reportInterval
  )
  D:log(reportMessage,"reportMessage")
  assert_equal(0,tonumber(reportMessage.count),"Message"..reportKey.." should not come!")
end

-- This is generic function for disabled accelerated reports test (and standard reports enabled)
function generic_test_AcceleratedReportDisabledAndStandardReportEnabled(standardReportKey, reportKey,properties,reportInterval,setConfigMsgKey,configChangeMsgKey,fields)

  -- setup
  if setConfigMsgKey then
    D:log(setConfigMsgKey,"X1")
    D:log(fields,"X2")
    -- change config to trigger ConfigChange message (SetConfigReportX used)
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      fields
    )
    vmsSW:waitForMessagesByName(
      {configChangeMsgKey},
      30
    )
  else
    vmsSW:setPropertiesByName(properties)
  end

  local reportMessageStandard = vmsSW:waitForMessagesByName(
    {standardReportKey},
    reportInterval
  )

  assert_not_nil(
    reportMessageStandard,
    "Standard Report not received"
  )
  assert_not_nil(
    reportMessageStandard[standardReportKey],
    "Standard Report not received!"
  )

  D:log("Waiting for report - should not come - "..reportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey},
    reportInterval
  )
  D:log(reportMessage,"reportMessage")
  assert_equal(0,tonumber(reportMessage.count),"Message"..reportKey.." should not come!")
end

--TODO: when SR is disabled AR is disabled too (4.13)
--TODO: getConfig message (4.15)
--TODO: PollRequest/Response (6.1-6.3)
